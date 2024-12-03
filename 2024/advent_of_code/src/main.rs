use bevy::prelude::*;

mod day1;

fn main() {
    App::new()
        .add_plugins(MinimalPlugins)
        // .add_plugins(day1::Part1)
        .add_plugins(day1::Part2)
        .run();
}
