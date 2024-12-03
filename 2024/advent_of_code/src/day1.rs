use bevy::prelude::*;
use std::{collections::HashMap, fs};

#[derive(Component, Ord, PartialOrd, Eq, PartialEq)]
struct Location(u32);

#[derive(Component)]
struct Page(u32);

#[derive(Component)]
struct Page1;

#[derive(Component)]
struct Page2;

#[derive(Component, Ord, PartialOrd, Eq, PartialEq)]
struct Index(u32);

#[derive(Component)]
struct Sorted;

pub struct Part1;

impl Plugin for Part1 {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, add_locations);
        app.add_systems(Update, (sort_locations, compare_pages));
    }
}

pub struct Part2;

impl Plugin for Part2 {
    fn build(&self, app: &mut App) {
        app.add_systems(Startup, add_locations_2);
        app.add_systems(Update, find_similarity);
    }
}

fn add_locations(mut commands: Commands) {
    let contents = fs::read_to_string("src/day1_input_sample.txt")
        .expect("Should have been able to read the file.");

    for line in contents.split('\n') {
        if !line.is_empty() {
            let locs = line.split("   ").collect::<Vec<_>>();
            commands.spawn((Location(locs[0].parse().unwrap()), Page(1)));
            commands.spawn((Location(locs[1].parse().unwrap()), Page(2)));
        }
    }
}

fn add_locations_2(mut commands: Commands) {
    let contents =
        fs::read_to_string("src/day1_input.txt").expect("Should have been able to read the file.");

    for line in contents.split('\n') {
        if !line.is_empty() {
            let locs = line.split("   ").collect::<Vec<_>>();
            commands.spawn((Location(locs[0].parse().unwrap()), Page1));
            commands.spawn((Location(locs[1].parse().unwrap()), Page2));
        }
    }
}

fn find_similarity(
    query_page1: Query<(Entity, &Location), With<Page1>>,
    query_page2: Query<(Entity, &Location), With<Page2>>,
    mut commands: Commands,
) {
    let mut similarity = 0;
    for (entity_id, loc) in &query_page1 {
        let mut simil_count = 0;

        for (entity_id_2, loc_2) in &query_page2 {
            if loc.0 == loc_2.0 {
                simil_count += 1;
            }
            commands.entity(entity_id_2).despawn();
        }

        similarity += simil_count * loc.0;

        commands.entity(entity_id).despawn();
    }

    if similarity != 0 {
        println!("score: {similarity}");
    }
}

fn sort_locations(
    query: Query<(Entity, &Page, &Location), Without<Sorted>>,
    mut commands: Commands,
) {
    let mut indexes = HashMap::new();

    for (entity_id, page, _loc) in query.iter().sort::<&Location>() {
        let page_index = indexes.get(&page.0).copied().unwrap_or(0);
        commands
            .entity(entity_id)
            .insert(Sorted)
            .insert(Index(page_index));
        indexes.insert(page.0, page_index + 1);
    }
}

fn compare_pages(query: Query<(Entity, &Index, &Location), With<Sorted>>, mut commands: Commands) {
    let mut locations = Vec::new();
    let mut distances = Vec::new();
    let mut current_index;
    let mut last_index = 0;

    for (entity_id, i, loc) in query.iter().sort::<&Index>() {
        // println!("location: {}, in page: {}, index: {}", loc.0, page.0, i.0);
        current_index = i.0;
        if current_index != last_index {
            // println!("{:?}", locations);
            let d = compare_distances(locations.clone());
            distances.push(d);
            // println!("{}", d);
            locations.clear();
        }
        last_index = current_index;

        locations.push(loc.0);

        commands.entity(entity_id).despawn();
    }

    if !locations.is_empty() {
        // println!("{:?}", locations);
        let d = compare_distances(locations.clone());
        distances.push(d);
        // println!("{}", d);

        let sum: u32 = distances.iter().sum();
        println!("sum: {sum}");
    }
}

fn compare_distances(mut locations: Vec<u32>) -> u32 {
    locations.sort();
    locations[1] - locations[0]
}
