import coord.{type Coord}
import gleam/dict
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/result
import gleam/string
import pretty
import util

pub fn run(input) {
  let route = find_route(util.as_grid(input))
  pretty.part1_result_int(part1(route))
  pretty.part2_result_int(part2(route))
}

pub fn part1(route: List(Coord)) {
  find_cheats(route, 2)
}

pub fn part2(route: List(Coord)) {
  find_cheats(route, 20)
}

fn find_cheats(route: List(Coord), max_length: Int) {
  route
  |> list.index_map(fn(x, i) { #(x, i) })
  |> list.combination_pairs()
  |> list.filter_map(fn(p) {
    let #(#(a_loc, a_idx), #(b_loc, b_idx)) = p
    case coord.manhattan_dist(a_loc, b_loc) {
      n if n <= max_length -> Ok(int.absolute_value(b_idx - a_idx) - n)
      _ -> Error(Nil)
    }
  })
  |> list.count(fn(saved) { 100 <= saved })
}

fn find_route(track) {
  let assert [start, end] =
    dict.filter(track, fn(_, v) { v == "S" || v == "E" })
    |> dict.to_list()
    |> list.sort(fn(a, b) { string.compare(a.1, b.1) |> order.negate() })
    |> list.map(pair.first)
  do_find_route(track, [start], end)
}

fn do_find_route(track, path, end) {
  case path {
    [start] -> {
      let assert Ok(next) =
        coord.neighbours4(start)
        |> list.filter(fn(n) { dict.get(track, n) == Ok(".") })
        |> list.first()
      do_find_route(track, [next, start], end)
    }
    [p, ..] if p == end -> list.reverse(path)
    [current, previous, ..] -> {
      let assert Ok(next) =
        coord.neighbours4(current)
        |> list.filter(fn(n) {
          n != previous
          && dict.get(track, n)
          |> result.map(fn(s) { s != "#" })
          |> result.unwrap(False)
        })
        |> list.first()
      do_find_route(track, [next, ..path], end)
    }
    [] -> panic as { "path empty" }
  }
}
