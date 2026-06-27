use std::env;
use std::path::Path;

fn main() {
    let manifest = env::var("CARGO_MANIFEST_DIR").unwrap();
    println!("cargo:rustc-check-cfg=cfg(lurek2d_has_splash)");

    let splash = Path::new(&manifest).join("assets").join("splash.png");
    if splash.exists() {
        println!("cargo:rustc-cfg=lurek2d_has_splash");
        println!("cargo:rerun-if-changed=assets/splash.png");
    }
}
