use itertools::Itertools;
use std::{
    collections::{HashMap, HashSet, VecDeque},
    io::{self, BufRead},
    iter,
};

type Maze = HashMap<Point, Tile>;

#[derive(PartialEq, Eq, Hash, Clone, Copy, Debug)]
struct Point(isize, isize);

#[derive(PartialEq, Eq, Hash, Clone, Copy, Debug)]
enum Tile {
    Wall,
    Floor,
}

fn parse_input() -> (Maze, Vec<(usize, Point)>) {
    let stdin = io::stdin();

    let mut maze = Maze::new();
    let mut points = Vec::new();

    for (y, line) in stdin.lock().lines().enumerate() {
        for (x, tile) in line.unwrap().chars().enumerate() {
            let point = Point(x as isize, y as isize);

            maze.insert(
                point,
                match tile {
                    '#' => Tile::Wall,
                    _ => Tile::Floor,
                },
            );

            if tile.is_digit(10) {
                points.push((tile.to_digit(10).unwrap() as usize, point));
            }
        }
    }

    (maze, points)
}

fn neighbours(p: Point) -> impl Iterator<Item = Point> {
    let (x, y) = (p.0, p.1);

    [(1, 0), (0, -1), (-1, 0), (0, 1)]
        .iter()
        .map(move |(dx, dy)| Point(*dx + x, *dy + y))
}

fn shortest_path(maze: &Maze, from: Point, to: Point) -> usize {
    let mut queue = VecDeque::new();
    let mut seen = HashSet::new();

    queue.push_back((from, 0));
    seen.insert(from);

    while let Some((next, step)) = queue.pop_front() {
        if next == to {
            return step;
        }
        for neighbour in neighbours(next) {
            if let Some(Tile::Floor) = maze.get(&neighbour) {
                if !seen.contains(&neighbour) {
                    queue.push_back((neighbour, step + 1));
                    seen.insert(neighbour);
                }
            }
        }
    }

    0
}

fn solve_a(maze: &Maze, points: &Vec<(usize, Point)>) -> usize {
    let combinations: HashMap<(usize, usize), usize> = points
        .iter()
        .permutations(2)
        .map(|points| {
            let (i1, p1) = *points[0];
            let (i2, p2) = *points[1];

            ((i1, i2), shortest_path(maze, p1, p2))
        })
        .collect();

    points
        .iter()
        .filter(|(id, _)| *id != 0)
        .map(|&(id, _)| id)
        .permutations(points.len() - 1)
        .map(|perm| {
            (iter::once(&0usize).chain(perm.iter()))
                .zip(perm.iter())
                .map(|(&i1, &i2)| combinations.get(&(i1, i2)).unwrap())
                .sum()
        })
        .min()
        .unwrap()
}

fn solve_b(maze: &Maze, points: &Vec<(usize, Point)>) -> usize {
    let combinations: HashMap<(usize, usize), usize> = points
        .iter()
        .permutations(2)
        .map(|points| {
            let (i1, p1) = *points[0];
            let (i2, p2) = *points[1];

            ((i1, i2), shortest_path(maze, p1, p2))
        })
        .collect();

    points
        .iter()
        .filter(|(id, _)| *id != 0)
        .map(|&(id, _)| id)
        .permutations(points.len() - 1)
        .map(|perm| {
            (iter::once(&0usize).chain(perm.iter()))
                .zip(perm.iter().chain(iter::once(&0usize)))
                .map(|(&i1, &i2)| combinations.get(&(i1, i2)).unwrap())
                .sum()
        })
        .min()
        .unwrap()
}

fn main() {
    let (maze, points) = parse_input();

    println!("{}", solve_a(&maze, &points));
    println!("{}", solve_b(&maze, &points));
}
