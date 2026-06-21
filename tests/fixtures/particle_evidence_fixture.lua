local Fixture = {}

Fixture.scenes = {
    cluster = {
        seed = 1001,
        maxParticles = 180,
        emissionRate = 120,
        shape = "circle",
        lifetimeMin = 1.0,
        lifetimeMax = 2.0,
        sizeMin = 2,
        sizeMax = 6,
        speedMin = 20,
        speedMax = 80,
    },
    burst = {
        seed = 1003,
        maxParticles = 220,
        emissionRate = 0,
        shape = "shrapnel",
        lifetimeMin = 0.6,
        lifetimeMax = 1.3,
        sizeMin = 2,
        sizeMax = 5,
        speedMin = 70,
        speedMax = 140,
        spread = 360,
    },
    attractor = {
        seed = 1004,
        maxParticles = 240,
        emissionRate = 220,
        shape = "puff",
        lifetimeMin = 2.0,
        lifetimeMax = 2.0,
        speedMin = 40,
        speedMax = 90,
        sizeMin = 3,
        sizeMax = 7,
    },
}

function Fixture.trail_points(count, width, height)
    local points = {}
    for i = 1, count do
        local t = i / count
        points[i] = {
            x = 20 + t * (width - 40),
            y = height * 0.5 + math.sin(t * math.pi * 3) * (height * 0.18),
        }
    end
    return points
end

return Fixture
