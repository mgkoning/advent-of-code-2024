import coord.{type Coord}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/yielder
import util

pub fn run(input) {
  let #(antennae, max) = read_antennae(input)
  let grouped_antennae = group_antennae(antennae)
  io.println("Part 1: " <> int.to_string(part1(grouped_antennae, max)))
  io.println("Part 2: " <> int.to_string(part2(grouped_antennae, max)))
}

fn part1(grouped_antennae: List(List(Coord)), max: Coord) {
  run_part(grouped_antennae, max, antinodes)
}

fn part2(grouped_antennae: List(List(Coord)), max: Coord) {
  run_part(grouped_antennae, max, antinodes_resonant_harmonics)
}

fn antinodes(a: Coord, b: Coord, max: Coord) {
  let diff = coord.minus(a, b)
  [coord.plus(a, diff), coord.plus(b, coord.negate(diff))]
  |> list.filter(within_bounds(_, max))
}

fn antinodes_resonant_harmonics(a: Coord, b: Coord, max: Coord) {
  let diff = coord.minus(a, b)
  yielder.iterate(a, coord.plus(_, diff))
  |> yielder.take_while(within_bounds(_, max))
  |> yielder.append(
    yielder.iterate(b, coord.plus(_, coord.negate(diff)))
    |> yielder.take_while(within_bounds(_, max)),
  )
  |> yielder.to_list
}

fn run_part(grouped_antennae, max, calculate_antinodes) {
  grouped_antennae
  |> list.flat_map(fn(coords) {
    coords
    |> list.combination_pairs
    |> list.flat_map(fn(p) { calculate_antinodes(p.0, p.1, max) })
  })
  |> set.from_list
  |> set.size
}

fn group_antennae(antennae: Dict(Coord, String)) {
  antennae
  |> dict.to_list
  |> list.group(fn(e) { e.1 })
  |> dict.map_values(fn(_, v) { list.map(v, fn(e) { e.0 }) })
  |> dict.values
}

fn within_bounds(c: Coord, max: Coord) {
  0 <= c.0 && 0 <= c.1 && c.0 <= max.0 && c.1 <= max.1
}

fn read_antennae(input) {
  let grid = util.as_grid(input)
  #(
    dict.filter(grid, fn(_, v) { v != "." }),
    dict.keys(grid)
      |> list.fold(#(0, 0), coord.max),
  )
}
