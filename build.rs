use std::env;
use std::path::Path;

fn main() {
    let manifest = env::var("CARGO_MANIFEST_DIR").unwrap();
    println!("cargo:rustc-check-cfg=cfg(lurek2d_has_splash)");
    println!("cargo:rerun-if-changed=build.rs");

    let splash = Path::new(&manifest).join("assets").join("splash.png");
    if splash.exists() {
        println!("cargo:rustc-cfg=lurek2d_has_splash");
        println!("cargo:rerun-if-changed=assets/splash.png");
    }

    #[cfg(windows)]
    {
        let icon = Path::new(&manifest).join("assets").join("favicon.ico");
        if icon.exists() {
            println!("cargo:rerun-if-changed=assets/favicon.ico");
            let mut res = winresource::WindowsResource::new();
            res.set_icon(icon.to_string_lossy().as_ref());
            res.compile()
                .expect("failed to embed Windows icon resource");
        }
    }
}
