import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util

pub fn run(input) {
  let grid = as_grid(input)
  io.println("Part 1: " <> int.to_string(part1(grid)))
  io.println("Part 2: " <> int.to_string(part2(grid)))
}

pub fn part1(grid: dict.Dict(#(Int, Int), String)) {
  let target = ["X", "M", "A", "S"]
  let searches = get_xmas_searches(list.length(target))
  dict.keys(grid)
  |> list.map(fn(coord) {
    searches
    |> list.count(fn(offsets) { is_match(grid, target, coord, offsets) })
  })
  |> list.fold(0, int.add)
}

fn get_xmas_searches(word_length) {
  [#(1, 0), #(1, 1), #(0, 1), #(-1, 1), #(-1, 0), #(-1, -1), #(0, -1), #(1, -1)]
  |> list.map(fn(dir) {
    list.range(0, word_length - 1)
    |> list.map(fn(f) { #(dir.0 * f, dir.1 * f) })
  })
}

fn is_match(grid, target, from, offsets) {
  target
  |> list.zip(get_letters(grid, from, offsets))
  |> list.all(fn(p) { p.0 == p.1 })
}

fn get_letters(
  grid: dict.Dict(#(Int, Int), String),
  from: #(Int, Int),
  offsets: List(#(Int, Int)),
) {
  offsets
  |> list.map(fn(offset) { #(from.0 + offset.0, from.1 + offset.1) })
  |> list.map(fn(coord) { util.get_or_default(grid, coord, ".") })
}

pub fn part2(grid: dict.Dict(#(Int, Int), String)) {
  let target = ["M", "A", "S"]
  let cross = [[#(-1, -1), #(0, 0), #(1, 1)], [#(-1, 1), #(0, 0), #(1, -1)]]
  dict.keys(grid)
  |> list.count(fn(coord) {
    list.all(cross, fn(leg) {
      [leg, list.reverse(leg)]
      |> list.any(fn(offsets) { is_match(grid, target, coord, offsets) })
    })
  })
}

pub fn as_grid(input) {
  input
  |> util.lines
  |> list.index_map(fn(line, y) { #(y, line) })
  |> list.flat_map(fn(l) {
    string.to_graphemes(l.1)
    |> list.index_map(fn(c, x) { #(#(x, l.0), c) })
  })
  |> dict.from_list()
}
