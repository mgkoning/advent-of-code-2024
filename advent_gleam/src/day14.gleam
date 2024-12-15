import coord.{type Coord}
import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import gleam/yielder
import pretty
import util

const puzzle_grid_size = #(101, 103)

// set this to true to also show the tree at part 2 output ("ooooooh")
const show_tree = False

pub fn run(input) {
  let robots = read_robots(input)
  pretty.part1_result_int(part1(robots, puzzle_grid_size))
  pretty.part2_result_int(part2(robots, puzzle_grid_size))
}

pub fn part1(robots: List(Robot), grid_size: Coord) {
  let assert Ok(part1) =
    robots
    |> yielder.iterate(list.map(_, move(_, grid_size)))
    |> yielder.drop(100)
    |> yielder.first()
    |> result.map(safety_factor(_, grid_size))
  part1
}

pub fn part2(robots: List(Robot), grid_size: Coord) {
  let assert Ok(#(tree, index)) =
    robots
    |> yielder.iterate(list.map(_, move(_, grid_size)))
    |> yielder.index()
    |> yielder.drop_while(fn(l) { !maybe_tree(l.0, grid_size) })
    |> yielder.first()
  let _ = case show_tree {
    True -> show(tree, grid_size)
    False -> Nil
  }
  index
}

fn maybe_tree(robots: List(Robot), grid_size: Coord) {
  let half_x = grid_size.0 / 2
  let inside_tree =
    robots
    |> list.map(fn(r) { r.pos })
    |> list.count(fn(p) {
      half_x < coord.manhattan_dist(#(0, 0), p)
      && half_x < coord.manhattan_dist(p, #(grid_size.0 - 1, 0))
    })
  // kind of arbitrary, but this works for my input
  inside_tree > 460
}

fn safety_factor(robots: List(Robot), grid_size: Coord) {
  quadrants(grid_size)
  |> list.map(fn(quad) {
    robots
    |> list.count(fn(r) { within(r.pos, quad) })
  })
  |> list.fold(1, int.multiply)
}

fn quadrants(grid_size: Coord) {
  let #(quad_x, quad_y) = #(grid_size.0 / 2, grid_size.1 / 2)
  [0, quad_x + 1]
  |> list.flat_map(fn(x) { [0, quad_y + 1] |> list.map(fn(y) { #(x, y) }) })
  |> list.map(fn(top_left) {
    let bottom_right = coord.plus(top_left, #(quad_x, quad_y))
    #(top_left, bottom_right)
  })
}

fn within(pos: Coord, quadrant: #(Coord, Coord)) {
  let #(top_left, bottom_right) = quadrant
  top_left.0 <= pos.0
  && pos.0 < bottom_right.0
  && top_left.1 <= pos.1
  && pos.1 < bottom_right.1
}

fn move(robot: Robot, grid_size: Coord) {
  Robot(..robot, pos: coord.plus(robot.pos, robot.vel) |> wrap(grid_size))
}

fn wrap(coord: Coord, grid_size: Coord) {
  let assert Ok(x) = int.modulo(coord.0, grid_size.0)
  let assert Ok(y) = int.modulo(coord.1, grid_size.1)
  #(x, y)
}

pub type Robot {
  Robot(pos: Coord, vel: Coord)
}

pub fn read_robots(input) {
  let assert Ok(re) =
    regexp.compile(
      "p=(-?\\d+),(-?\\d+) v=(-?\\d+),(-?\\d+)",
      regexp.Options(case_insensitive: False, multi_line: True),
    )
  regexp.scan(re, input)
  |> list.map(fn(r) {
    let assert [px, py, vx, vy] =
      option.values(r.submatches)
      |> util.read_as_ints
    Robot(#(px, py), #(vx, vy))
  })
}

fn show(robots: List(Robot), grid_size: Coord) {
  let positions =
    list.map(robots, fn(r) { r.pos }) |> list.group(function.identity)
  list.range(0, grid_size.1)
  |> list.map(fn(y) {
    list.range(0, grid_size.0)
    |> list.map(fn(x) {
      case dict.get(positions, #(x, y)) {
        Ok(l) -> l |> list.length() |> int.to_string()
        _ -> "."
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println()
  io.println("")
}
