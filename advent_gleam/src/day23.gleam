import gleam/dict
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import pretty
import util

pub fn run(input) {
  let topo = read_network_topo(input)
  pretty.part1_result_int(part1(topo))
  pretty.part2_result_str(part2(topo))
}

fn part1(topo) {
  topo
  |> dict.fold(set.new(), fn(acc, k, v) {
    list.combination_pairs(v)
    |> list.filter_map(fn(p) {
      let #(a, b) = p
      case is_connected(topo, a, b) {
        True -> Ok(list.sort([k, a, b], string.compare))
        False -> Error(Nil)
      }
    })
    |> set.from_list()
    |> set.union(acc)
  })
  |> set.filter(list.any(_, string.starts_with(_, "t")))
  |> set.size()
}

fn part2(topo) {
  topo
  |> dict.fold(#([], 0), fn(acc, k, v) {
    let best = find_largest_network(topo, [k, ..v], [])
    case acc.1 < best.1 {
      True -> best
      False -> acc
    }
  })
  |> pair.first()
  |> list.sort(string.compare)
  |> string.join(",")
}

fn find_largest_network(topo, candidates, result) -> #(List(String), Int) {
  case candidates {
    [] -> #(result, list.length(result))
    [c, ..cs] -> {
      case list.all(result, is_connected(topo, c, _)) {
        False -> find_largest_network(topo, cs, result)
        True -> {
          let without = find_largest_network(topo, cs, result)
          let with = find_largest_network(topo, cs, [c, ..result])
          case without.1 < with.1 {
            True -> with
            False -> without
          }
        }
      }
    }
  }
}

fn is_connected(topo, a, b) {
  dict.get(topo, a)
  |> result.map(list.contains(_, b))
  |> result.unwrap(False)
}

fn read_network_topo(input) {
  let add_connection = fn(current, new) {
    option.map(current, list.prepend(_, new)) |> option.unwrap([new])
  }
  input
  |> util.convert_lines(fn(l) {
    let assert Ok(c) = string.split_once(l, "-")
    c
  })
  |> list.fold(dict.new(), fn(acc, n) {
    let #(a, b) = n
    acc
    |> dict.upsert(a, add_connection(_, b))
    |> dict.upsert(b, add_connection(_, a))
  })
}
