import coord.{type Coord}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import gleam/string
import pretty
import util

const show_map = True

pub fn run(input) {
  let #(map, moves) = read_input(input)
  pretty.part1_result_int(part1(map, moves))
  let #(map_p2, moves) = read_input_p2(input)
  pretty.part2_result_int(part2(map_p2, moves))
}

pub fn part1(map, moves) {
  run_robot(map, moves)
  |> dict.keys()
  |> list.map(fn(c) { c.0 + 100 * c.1 })
  |> list.fold(0, int.add)
}

pub fn part2(map, moves) {
  run_robot(map, moves)
  |> dict.filter(fn(_, c) { c == "[" })
  |> dict.keys()
  |> list.map(fn(c) { c.0 + 100 * c.1 })
  |> list.fold(0, int.add)
}

fn run_robot(map, moves) {
  let #(robot, boxes) = get_positions(map)
  let final_state =
    moves
    |> list.fold(State(robot, boxes), fn(state, move) {
      do_move(map, state, move)
    })
  case show_map {
    True -> show(map, final_state)
    False -> Nil
  }
  final_state.boxes
}

fn do_move(map: Dict(Coord, String), state: State, move: String) {
  let direction = get_direction(move)
  let desired = coord.plus(state.robot, direction)
  case dict.get(map, desired) {
    Ok("#") -> state
    Ok(_) -> {
      let new_boxes =
        push_boxes(map, state.boxes, desired, direction)
        |> result.unwrap(state.boxes)
      case dict.get(new_boxes, desired) {
        Error(Nil) -> State(robot: desired, boxes: new_boxes)
        Ok(_) -> state
      }
    }
    Error(_) -> panic as { "Moved off map" }
  }
}

fn push_boxes(map: Dict(Coord, String), boxes: Dict(Coord, String), pos, dir) {
  case dict.get(boxes, pos) {
    Error(Nil) -> {
      case dict.get(map, pos) {
        Ok("#") | Error(Nil) -> Error(Nil)
        Ok(_) -> Ok(boxes)
      }
    }
    Ok(box) -> {
      let desired = coord.plus(pos, dir)
      let new_boxes = case box, dir {
        "[", d if d == coord.north || d == coord.south ->
          push_boxes(map, boxes, desired, dir)
          |> result.try(fn(new_boxes) {
            push_boxes(map, new_boxes, coord.plus(desired, coord.east), dir)
          })
          |> result.map(pair.new(_, [
            #(pos, desired),
            #(coord.plus(pos, coord.east), coord.plus(desired, coord.east)),
          ]))
        "]", d if d == coord.north || d == coord.south ->
          push_boxes(map, boxes, desired, dir)
          |> result.try(fn(new_boxes) {
            push_boxes(map, new_boxes, coord.plus(desired, coord.west), dir)
          })
          |> result.map(pair.new(_, [
            #(pos, desired),
            #(coord.plus(pos, coord.west), coord.plus(desired, coord.west)),
          ]))
        _, _ ->
          push_boxes(map, boxes, desired, dir)
          |> result.map(pair.new(_, [#(pos, desired)]))
      }
      new_boxes
      |> result.then(fn(new_boxes) {
        case dict.get(new_boxes.0, desired) {
          Error(Nil) ->
            Ok(
              list.fold(new_boxes.1, new_boxes.0, fn(acc, update) {
                let #(pos, desired) = update
                let assert Ok(box) = dict.get(acc, pos)
                acc |> dict.delete(pos) |> dict.insert(desired, box)
              }),
            )
          Ok(_) -> Error(Nil)
        }
      })
    }
  }
}

fn get_direction(move) {
  case move {
    "<" -> coord.west
    ">" -> coord.east
    "^" -> coord.north
    "v" -> coord.south
    _ -> panic as { "Unknown move " <> move }
  }
}

type State {
  State(robot: Coord, boxes: Dict(Coord, String))
}

fn get_positions(map) {
  let assert [#(robot, _)] =
    dict.filter(map, fn(_, v) { v == "@" }) |> dict.to_list()
  #(robot, dict.filter(map, fn(_, v) { v == "O" || v == "[" || v == "]" }))
}

pub fn read_input(input) {
  let assert [map, moves] = string.split(input, on: "\n\n")
  #(util.as_grid(map), string.replace(moves, "\n", "") |> string.to_graphemes())
}

pub fn read_input_p2(input) {
  let assert [map, moves] = string.split(input, on: "\n\n")
  let scaled_up =
    string.to_graphemes(map)
    |> list.map(fn(c) {
      case c {
        "#" -> "##"
        "O" -> "[]"
        "." -> ".."
        "@" -> "@."
        _ -> c
      }
    })
    |> string.join("")
    |> util.as_grid()
  #(scaled_up, string.replace(moves, "\n", "") |> string.to_graphemes())
}

fn show(map, state: State) {
  let assert Ok(#(xmax, ymax)) = dict.keys(map) |> list.reduce(coord.max)
  list.range(0, ymax)
  |> list.map(fn(y) {
    list.range(0, xmax)
    |> list.map(fn(x) {
      let pos = #(x, y)
      case state.robot, dict.get(state.boxes, pos), dict.get(map, pos) {
        r, _, _ if r == pos -> "@"
        _, Ok(c), _ -> c
        _, _, Ok("#") -> "#"
        _, _, Ok(_) -> "."
        _, _, Error(_) -> panic as { "Outside map" }
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println()
  io.println("")
}
