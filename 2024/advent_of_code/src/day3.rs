use regex::Regex;
use std::fs;

use bevy::prelude::*;

#[derive(Component)]
struct Instruction {
    a: i32,
    b: i32,
}

#[derive(Component)]
struct Answer(i32);

pub struct Part1;

impl Plugin for Part1 {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, parse_memory);
        app.add_systems(Update, (execute_instructions, sum_answers));
    }
}

pub struct Part2;

impl Plugin for Part2 {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, parse_memory_2);
        app.add_systems(Update, (execute_instructions, sum_answers));
    }
}

fn parse_memory(mut commands: Commands) {
    let contents =
        fs::read_to_string("src/day3_input.txt").expect("Should have been able to read the file.");

    let re = Regex::new(r"(mul\(([0-9]+),([0-9]+)\))").unwrap();

    for (_, [_, first, second]) in re.captures_iter(&contents).map(|c| c.extract()) {
        commands.spawn(Instruction {
            a: first.parse::<i32>().unwrap(),
            b: second.parse::<i32>().unwrap(),
        });
    }
}

fn parse_memory_2(mut commands: Commands) {
    let contents =
        fs::read_to_string("src/day3_input.txt").expect("Should have been able to read the file.");

    let re = Regex::new(r"(mul\(([0-9]+),([0-9]+)\))").unwrap();

    for do_part in contents.split("do()") {
        for (pos, dont_part) in do_part.split("don't()").enumerate() {
            if pos == 0 {
                println!("do: {}", dont_part);
                for (_, [_, first, second]) in re.captures_iter(dont_part).map(|c| c.extract()) {
                    commands.spawn(Instruction {
                        a: first.parse::<i32>().unwrap(),
                        b: second.parse::<i32>().unwrap(),
                    });
                }
            } else {
                println!("don't: {}", dont_part);
            }
        }
    }
}

fn execute_instructions(
    query: Query<(Entity, &Instruction), Without<Answer>>,
    mut commands: Commands,
) {
    for (entity_id, ins) in &query {
        let ans = ins.a * ins.b;

        commands.entity(entity_id).insert(Answer(ans));
    }
}

fn sum_answers(query: Query<&Answer>) {
    let sum: i32 = query.iter().map(|a| a.0).sum();

    println!("Sum: {sum}");
}
