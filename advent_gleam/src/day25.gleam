import gleam/dict
import gleam/list
import gleam/set
import gleam/string
import pretty
import util

pub fn run(input) {
  let #(locks, keys) = read_locks_and_keys(input)
  pretty.part1_result_int(
    list.fold(locks, 0, fn(acc, lock) {
      acc + list.count(keys, set.is_disjoint(lock, _))
    }),
  )
}

fn read_locks_and_keys(input) {
  string.split(input, "\n\n")
  |> list.fold(#([], []), fn(acc, schematic) {
    let pins =
      util.as_grid(schematic)
      |> dict.filter(fn(_, v) { v == "#" })
      |> dict.keys()
      |> set.from_list()
    let is_lock =
      util.lines(schematic)
      |> list.take(1)
      |> list.flat_map(string.to_graphemes)
      |> list.all(util.equals(_, "#"))
    case is_lock {
      True -> #([pins, ..acc.0], acc.1)
      False -> #(acc.0, [pins, ..acc.1])
    }
  })
}
