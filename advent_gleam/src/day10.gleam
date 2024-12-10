import coord.{type Coord}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import pretty
import util

pub fn run(input) {
  let topo = read_topo(input)
  pretty.part1_result_int(part1(topo))
  pretty.part2_result_int(part2(topo))
}

pub fn part1(topo: Dict(coord.Coord, Int)) {
  topo
  |> dict.map_values(fn(c, h) {
    case h {
      0 -> trails(topo, c, h) |> fn(t) { t.summits |> set.size() }
      _ -> 0
    }
  })
  |> dict.values()
  |> list.fold(0, int.add)
}

pub fn part2(topo: Dict(coord.Coord, Int)) {
  topo
  |> dict.map_values(fn(c, h) {
    case h {
      0 -> trails(topo, c, h) |> fn(t) { t.paths }
      _ -> 0
    }
  })
  |> dict.values()
  |> list.fold(0, int.add)
}

fn trails(topo: Dict(coord.Coord, Int), from: Coord, height: Int) {
  case height {
    9 -> summit_score(from)
    h ->
      coord.neighbours4(from)
      |> list.map(fn(n) { #(n, util.get_or_default(topo, n, -1)) })
      |> list.filter(fn(neighbour) { neighbour.1 == h + 1 })
      |> list.fold(get_empty_score(), fn(acc, neighbour) {
        add_score(acc, trails(topo, neighbour.0, neighbour.1))
      })
  }
}

type TrailScore {
  TrailScore(paths: Int, summits: Set(Coord))
}

fn get_empty_score() {
  TrailScore(0, set.new())
}

fn summit_score(from: Coord) {
  TrailScore(1, set.from_list([from]))
}

fn add_score(one: TrailScore, other: TrailScore) {
  TrailScore(one.paths + other.paths, set.union(one.summits, other.summits))
}

pub fn read_topo(input) {
  util.as_grid(input)
  |> dict.map_values(fn(_, v) {
    int.parse(v)
    |> result.lazy_unwrap(fn() { panic as { "Not an int: " <> v } })
  })
}
