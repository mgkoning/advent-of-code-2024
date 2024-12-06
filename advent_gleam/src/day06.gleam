import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import util

pub fn run(input) {
  let grid = util.as_grid(input)
  io.println("Part 1: " <> int.to_string(part1(grid)))
  io.println("Part 2: " <> int.to_string(part2(grid)))
}

pub fn part1(grid) {
  let assert Ok(#(guard_pos, _)) =
    grid |> dict.to_list |> list.filter(fn(e) { e.1 == "^" }) |> list.first
  let #(visited, _) = run_patrol(grid, guard_pos)
  visited
  |> set.map(fn(s) { s.pos })
  |> set.size
}

pub fn part2(grid) {
  let assert Ok(#(guard_pos, _)) =
    grid |> dict.to_list |> list.filter(fn(e) { e.1 == "^" }) |> list.first
  let candidates =
    grid
    |> dict.to_list
    |> list.filter_map(fn(e) {
      case e.1 {
        "." -> Ok(e.0)
        x -> Error(x)
      }
    })
  candidates
  |> list.filter(fn(c) {
    run_patrol(dict.upsert(grid, c, fn(_) { "#" }), guard_pos).1
  })
  |> list.length
}

fn run_patrol(grid, start) {
  let start = Step(start, #(0, -1))
  patrol(grid, start, set.from_list([start]))
}

type Step {
  Step(pos: #(Int, Int), dir: #(Int, Int))
}

fn patrol(grid, step: Step, visited: set.Set(Step)) {
  let next = move(step)
  case set.contains(visited, next) {
    True -> #(visited, True)
    False ->
      case dict.get(grid, next.pos) {
        Error(_) -> #(visited, False)
        Ok("#") -> patrol(grid, turn_right(step), visited)
        Ok(_) -> {
          patrol(grid, next, set.insert(visited, next))
        }
      }
  }
}

fn try_obstr(grid, visited, step) {
  let next = move(step)
  case set.contains(visited, next) {
    True -> True
    False -> {
      case dict.get(grid, next.pos) {
        Error(_) -> False
        Ok("#") -> {
          let turned = turn_right(step)
          try_obstr(grid, set.insert(visited, turned), turned)
        }
        Ok(_) -> try_obstr(grid, set.insert(visited, next), next)
      }
    }
  }
}

fn move(step: Step) {
  Step(#(step.pos.0 + step.dir.0, step.pos.1 + step.dir.1), step.dir)
}

fn turn_right(step: Step) {
  case step.dir {
    #(0, -1) -> Step(step.pos, #(1, 0))
    #(1, 0) -> Step(step.pos, #(0, 1))
    #(0, 1) -> Step(step.pos, #(-1, 0))
    #(-1, 0) -> Step(step.pos, #(0, -1))
    _ -> panic as "Unknown direction"
  }
}
