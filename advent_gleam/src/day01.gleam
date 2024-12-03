import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import pretty
import util

pub fn run(input) {
  pretty.day_banner(1, "Historian Hysteria")
  let location_lists = read_location_lists(input)

  let part1 = part1(location_lists)
  io.println("Part 1: " <> int.to_string(part1))

  let part2 = part2(location_lists)
  io.println("Part 2: " <> int.to_string(part2))
}

pub fn part1(location_lists: List(List(Int))) {
  let assert [left, right] =
    location_lists
    |> list.map(list.sort(_, by: int.compare))
  list.zip(left, right)
  |> list.map(fn(pair) { int.absolute_value(pair.0 - pair.1) })
  |> list.fold(0, int.add)
}

pub fn part2(location_lists: List(List(Int))) {
  let assert [left, right] = location_lists
  let counts =
    right
    |> list.group(function.identity)
    |> dict.map_values(fn(_, xs) { list.length(xs) })
  left
  |> list.map(fn(k) { k * util.get_or_default(counts, k, 0) })
  |> list.fold(0, int.add)
}

pub fn read_location_lists(input) {
  input
  |> util.lines
  |> list.map(util.words(_))
  |> list.map(util.read_as_ints)
  |> list.transpose
}
