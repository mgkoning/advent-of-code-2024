import coord.{type Coord}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import gleam/set.{type Set}
import gleam/string
import gleam/yielder
import pretty
import util

const show_map_p2 = False

const max_coord = 70

pub fn run(input) {
  let falling_bytes = read_falling_bytes(input)
  pretty.part1_result_int(part1(max_coord, list.take(falling_bytes, 1024)))
  pretty.part2_result_str(part2(max_coord, falling_bytes))
}

type Space {
  Safe
  Corrupted
}

type Step {
  Step(pos: Coord, score: Int, steps: List(Coord))
}

fn part1(max_coord: Int, fallen_bytes: List(Coord)) {
  let memory_map = build_memory_map(max_coord, fallen_bytes)
  let target = #(max_coord, max_coord)
  let start = Step(coord.origin, 0, [coord.origin])
  let assert Ok(#(length, _)) =
    find_shortest(memory_map, target, [start], set.from_list([coord.origin]))
  length
}

fn part2(max_coord: Int, fallen_bytes: List(Coord)) {
  let memory_map = build_memory_map(max_coord, [])
  let target = #(max_coord, max_coord)
  let start = Step(coord.origin, 0, [coord.origin])
  let assert Ok(#(_, path)) =
    find_shortest(memory_map, target, [start], set.from_list([coord.origin]))
  let assert Ok(#(final_map, _, _, which)) =
    fallen_bytes
    |> yielder.from_list()
    |> yielder.scan(#(memory_map, path, True, #(-1, -1)), fn(state, next) {
      let #(memory_map, prev_path, _, _) = state
      let new_memory_map = dict.insert(memory_map, next, Corrupted)
      case list.take_while(prev_path, fn(c) { c != next }) |> list.last() {
        // re-use the previous path if it's not blocked
        Ok(c) if c == target -> #(new_memory_map, prev_path, True, next)
        _ -> {
          let result =
            find_shortest(
              new_memory_map,
              target,
              [start],
              set.from_list([coord.origin]),
            )
          case result {
            Ok(#(_, path)) -> #(new_memory_map, path, True, next)
            _ -> #(new_memory_map, [], False, next)
          }
        }
      }
    })
    |> yielder.drop_while(fn(state) { state.2 })
    |> yielder.first()
  case show_map_p2 {
    True -> show_map(final_map, max_coord)
    False -> Nil
  }
  int.to_string(which.0) <> "," <> int.to_string(which.1)
}

fn find_shortest(
  memory_map: Dict(Coord, Space),
  target: Coord,
  to_visit: List(Step),
  visited: Set(Coord),
) {
  case to_visit {
    [] -> Error(Nil)
    [next, ..rest] -> {
      case next {
        Step(pos, score, path) if pos == target ->
          Ok(#(score, list.reverse(path)))
        Step(pos, score, path) -> {
          let steps =
            coord.neighbours4(pos)
            |> list.filter(fn(n) { Ok(Safe) == dict.get(memory_map, n) })
            |> list.filter(fn(n) { !set.contains(visited, n) })
          let new_to_visit =
            steps
            |> list.fold(rest, fn(acc, n) {
              insert_sorted(acc, Step(n, score + 1, [n, ..path]))
            })
          let new_visited =
            steps |> list.fold(visited, fn(acc, n) { set.insert(acc, n) })
          find_shortest(memory_map, target, new_to_visit, new_visited)
        }
      }
    }
  }
}

fn insert_sorted(values: List(Step), value: Step) {
  case values {
    [] -> [value]
    [Step(_, l, _) as head, ..rest] if l <= value.score -> [
      head,
      ..insert_sorted(rest, value)
    ]
    _ -> [value, ..values]
  }
}

fn build_memory_map(max_coord: Int, fallen_bytes: List(Coord)) {
  let memory_map =
    list.range(0, max_coord)
    |> list.flat_map(fn(y) {
      list.range(0, max_coord)
      |> list.map(fn(x) { #(#(x, y), Safe) })
    })
    |> dict.from_list()
  fallen_bytes
  |> list.fold(memory_map, fn(acc, next) { dict.insert(acc, next, Corrupted) })
}

fn read_falling_bytes(input) {
  let assert Ok(re) =
    regexp.compile(
      "(\\d+),(\\d+)",
      regexp.Options(case_insensitive: False, multi_line: True),
    )
  regexp.scan(re, input)
  |> list.map(fn(match) {
    let assert [x, y] = option.values(match.submatches) |> util.read_as_ints()
    #(x, y)
  })
}

fn show_map(memory_map: Dict(Coord, Space), max_coord: Int) {
  list.range(0, max_coord)
  |> list.map(fn(y) {
    list.range(0, max_coord)
    |> list.map(fn(x) {
      case dict.get(memory_map, #(x, y)) {
        Ok(Corrupted) -> "#"
        _ -> "."
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println()
}
