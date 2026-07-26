//! Defines the deterministic render surface/device failure state machine.
//! App orchestration owns window lifecycle, while this owner classifies renderer failures
//! into safe submission, reconfiguration, recovery, or controlled shutdown actions.

/// Renderer availability state visible to the app integration layer.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RenderRecoveryState {
    /// A configured surface and device can accept render submissions.
    Ready,
    /// Surface capabilities/configuration must be refreshed before submitting again.
    SurfaceReconfigurePending,
    /// Device-owned resources must be recreated before rendering can resume.
    DeviceRecoveryPending,
    /// Allocation/submission is prohibited and the app must begin controlled shutdown.
    OutOfMemory,
    /// The app has started teardown and no new recovery is attempted.
    ShuttingDown,
}

/// A backend-independent failure signal consumed by the recovery state machine.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RenderRecoveryEvent {
    /// Surface was lost or became outdated.
    SurfaceLostOrOutdated,
    /// Surface acquisition timed out; the current frame is skipped.
    SurfaceTimeout,
    /// The backend reported out-of-memory.
    OutOfMemory,
    /// The device or an uncaptured validation path requires resource recreation.
    DeviceLostOrValidationError,
    /// A zero-sized or suspended window cannot accept a surface configuration.
    Suspended,
    /// A non-zero extent is available again.
    Resumed,
    /// The application begins its own teardown.
    Shutdown,
    /// Reconfiguration completed successfully.
    Reconfigured,
    /// Device recreation completed successfully.
    DeviceRecovered,
}

/// Required app-side action after a transition.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RenderRecoveryAction {
    /// Continue normal frame processing.
    Submit,
    /// Skip exactly this frame without blocking or retry looping.
    SkipFrame,
    /// Reconfigure surface-dependent GPU resources.
    ReconfigureSurface,
    /// Recreate device-owned resources from retained CPU descriptors.
    RecoverDevice,
    /// Stop rendering and request controlled app shutdown.
    Shutdown,
}

impl RenderRecoveryState {
    /// Apply one event and return the resulting state plus the required next action.
    pub fn transition(self, event: RenderRecoveryEvent) -> (Self, RenderRecoveryAction) {
        if self == Self::ShuttingDown || self == Self::OutOfMemory {
            return (self, RenderRecoveryAction::Shutdown);
        }
        match event {
            RenderRecoveryEvent::Shutdown => (Self::ShuttingDown, RenderRecoveryAction::Shutdown),
            RenderRecoveryEvent::OutOfMemory => (Self::OutOfMemory, RenderRecoveryAction::Shutdown),
            RenderRecoveryEvent::SurfaceLostOrOutdated => (
                Self::SurfaceReconfigurePending,
                RenderRecoveryAction::ReconfigureSurface,
            ),
            RenderRecoveryEvent::SurfaceTimeout => (self, RenderRecoveryAction::SkipFrame),
            RenderRecoveryEvent::DeviceLostOrValidationError => (
                Self::DeviceRecoveryPending,
                RenderRecoveryAction::RecoverDevice,
            ),
            RenderRecoveryEvent::Suspended => (
                Self::SurfaceReconfigurePending,
                RenderRecoveryAction::SkipFrame,
            ),
            RenderRecoveryEvent::Resumed if self == Self::SurfaceReconfigurePending => (
                Self::SurfaceReconfigurePending,
                RenderRecoveryAction::ReconfigureSurface,
            ),
            RenderRecoveryEvent::Resumed => (Self::Ready, RenderRecoveryAction::Submit),
            RenderRecoveryEvent::Reconfigured if self == Self::SurfaceReconfigurePending => {
                (Self::Ready, RenderRecoveryAction::Submit)
            }
            RenderRecoveryEvent::DeviceRecovered if self == Self::DeviceRecoveryPending => {
                (Self::Ready, RenderRecoveryAction::Submit)
            }
            RenderRecoveryEvent::Reconfigured | RenderRecoveryEvent::DeviceRecovered => {
                (self, RenderRecoveryAction::SkipFrame)
            }
        }
    }
}

/// Classify one `wgpu` surface error using the same policy as the persistent state machine.
pub fn surface_error_action(error: &wgpu::SurfaceError) -> RenderRecoveryAction {
    let event = match error {
        wgpu::SurfaceError::Lost | wgpu::SurfaceError::Outdated => {
            RenderRecoveryEvent::SurfaceLostOrOutdated
        }
        wgpu::SurfaceError::Timeout => RenderRecoveryEvent::SurfaceTimeout,
        wgpu::SurfaceError::OutOfMemory => RenderRecoveryEvent::OutOfMemory,
    };
    RenderRecoveryState::Ready.transition(event).1
}
