fn main() {
    methods.add_method_mut(
        "addClip",
        |_, this, (name, indices_tbl, fps, looping): (String, LuaTable, f32, bool)| {
            println!("test");
        },
    );
}
