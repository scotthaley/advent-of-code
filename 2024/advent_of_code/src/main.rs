use bevy::prelude::*;

mod day1;
mod day2;
mod day3;

fn main() {
    App::new()
        .add_plugins(MinimalPlugins)
        // .add_plugins(day1::Part1)
        // .add_plugins(day1::Part2)
        // .add_plugins(day2::Part1)
        // .add_plugins(day2::Part2)
        // .add_plugins(day3::Part1)
        .add_plugins(day3::Part2)
        .run();
}
