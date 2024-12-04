use std::fs;

use bevy::prelude::*;

#[derive(Component)]
struct Report(Vec<i32>);

#[derive(Component)]
struct Safe;

#[derive(Component)]
struct Unsafe;

pub struct Part1;

impl Plugin for Part1 {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, add_reports);
        app.add_systems(Update, (check_reports, count_safe));
    }
}

pub struct Part2;

impl Plugin for Part2 {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, add_reports);
        app.add_systems(Update, (check_reports_2, count_safe));
    }
}

fn add_reports(mut commands: Commands) {
    let contents =
        fs::read_to_string("src/day2_input.txt").expect("Should have been able to read the file.");

    for line in contents.split('\n') {
        if !line.is_empty() {
            let levels: Vec<i32> = line
                .trim()
                .split(' ')
                .map(|i| i.parse::<i32>())
                .map(Result::unwrap)
                .collect();

            commands.spawn(Report(levels));
        }
    }
}

fn check_reports(
    query: Query<(Entity, &Report), (Without<Safe>, Without<Unsafe>)>,
    mut commands: Commands,
) {
    for (entity_id, report) in &query {
        if determine_safe(report.0.to_vec()) {
            commands.entity(entity_id).insert(Safe);
            // println!("Safe: {:?}", report.0.to_vec());
        } else {
            commands.entity(entity_id).insert(Unsafe);
            // println!("Unsafe: {:?}", report.0.to_vec());
        }
    }
}

fn determine_safe(levels: Vec<i32>) -> bool {
    let mut last = levels[0];
    let mut last_sign = (levels[1] - levels[0]).signum();

    for level in levels.iter().skip(1) {
        let sign = (level - last).signum();
        // println!("({last}, {level}) - {sign}");
        if level.abs_diff(last) > 3 || sign != last_sign || sign == 0 {
            return false;
        }
        last = *level;
        last_sign = sign;
    }

    true
}

fn check_reports_2(
    query: Query<(Entity, &Report), (Without<Safe>, Without<Unsafe>)>,
    mut commands: Commands,
) {
    for (entity_id, report) in &query {
        if determine_safe_2(report.0.to_vec()) {
            commands.entity(entity_id).insert(Safe);
            // println!("Safe: {:?}", report.0.to_vec());
        } else {
            commands.entity(entity_id).insert(Unsafe);
            // println!("Unsafe: {:?}", report.0.to_vec());
        }
    }
}

fn determine_safe_2(levels: Vec<i32>) -> bool {
    if determine_safe(levels.to_vec()) {
        println!("Safe: {:?}", levels);
        return true;
    }

    for n in 0..levels.len() {
        let mut l = levels.to_vec();
        l.remove(n);

        if determine_safe(l.to_vec()) {
            return true;
        }
    }

    false
}

fn count_safe(query: Query<&Report, With<Safe>>) {
    println!("Safe: {}", query.iter().len())
}
