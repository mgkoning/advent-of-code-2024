import coord.{type Coord}
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/pair
import gleam/set
import gleam/string
import pretty
import util

type Step {
  Step(
    position: Coord,
    direction: Coord,
    score: Int,
    estimate: Int,
    path: List(#(Coord, Coord)),
  )
}

pub type MazeResult {
  MazeResult(score: Int, paths: List(List(#(Coord, Coord))))
}

pub fn run(input) {
  let maze = util.as_grid(input)
  let assert Ok(MazeResult(part1_score, paths)) = part1(maze)
  pretty.part1_result_int(part1_score)
  let part2 =
    paths
    |> list.flatten()
    |> list.map(pair.first)
    |> set.from_list()
    |> set.size
  pretty.part2_result_int(part2)
}

pub fn part1(maze: Dict(Coord, String)) {
  let assert [start, end] =
    dict.filter(maze, fn(_, v) { v == "S" || v == "E" })
    |> dict.to_list()
    |> list.sort(fn(a, b) { string.compare(a.1, b.1) |> order.negate() })
    |> list.map(pair.first)
  find_shortest(maze, start, end)
}

fn find_shortest(maze, start, end) {
  let estimate = coord.manhattan_dist(start, end)
  let start_step = Step(start, coord.east, 0, estimate, [#(start, coord.east)])
  do_find_shortest(
    maze,
    end,
    Error(Nil),
    [start_step],
    add_step(dict.new(), start_step),
  )
}

fn do_find_shortest(maze, target, maze_result, to_visit, visited) {
  case to_visit {
    [] -> maze_result
    [Step(pos, _, score, _, path) as step, ..rest] -> {
      case pos == target, maze_result {
        True, Error(_) ->
          do_find_shortest(
            maze,
            target,
            Ok(MazeResult(score, [path])),
            rest,
            visited,
          )
        True, Ok(MazeResult(s, paths)) if score == s -> {
          do_find_shortest(
            maze,
            target,
            Ok(MazeResult(s, [path, ..paths])),
            rest,
            visited,
          )
        }
        True, Ok(_) -> maze_result
        False, _ -> {
          let possible =
            next_moves(step, target)
            |> list.filter(fn(s) {
              case dict.get(maze, s.position) {
                Error(Nil) | Ok("#") -> False
                _ -> True
              }
            })
            |> list.filter(fn(s) {
              case dict.get(visited, #(s.position, s.direction)) {
                Error(Nil) -> True
                Ok(score) if s.score <= score -> True
                _ -> False
              }
            })
          let new_to_visit =
            list.append(possible, rest)
            |> list.sort(shortest_step)
          let new_visited = list.fold(possible, visited, add_step)
          do_find_shortest(maze, target, maze_result, new_to_visit, new_visited)
        }
      }
    }
  }
}

fn add_step(visited, step: Step) {
  dict.insert(visited, #(step.position, step.direction), step.score)
}

fn shortest_step(a: Step, b: Step) {
  int.compare(a.score + a.estimate, b.score + b.estimate)
}

fn next_moves(from: Step, target: Coord) {
  let next_pos = coord.plus(from.position, from.direction)
  let straight =
    Step(
      next_pos,
      from.direction,
      from.score + 1,
      coord.manhattan_dist(next_pos, target),
      [#(next_pos, from.direction), ..from.path],
    )
  [turn_clockwise(from.direction), turn_counterclockwise(from.direction)]
  |> list.map(fn(dir) {
    Step(from.position, dir, from.score + 1000, from.estimate, from.path)
  })
  |> list.prepend(straight)
}

fn turn_clockwise(dir: Coord) {
  case dir {
    #(0, 1) -> #(-1, 0)
    #(-1, 0) -> #(0, -1)
    #(0, -1) -> #(1, 0)
    #(1, 0) -> #(0, 1)
    d -> panic as { "Unknown direction " <> coord.to_string(d) }
  }
}

fn turn_counterclockwise(dir: Coord) {
  case dir {
    #(0, 1) -> #(1, 0)
    #(1, 0) -> #(0, -1)
    #(0, -1) -> #(-1, 0)
    #(-1, 0) -> #(0, 1)
    d -> panic as { "Unknown direction " <> coord.to_string(d) }
  }
}

pub fn show(map, path) {
  let path_dict = dict.from_list(path)
  let assert Ok(#(xmax, ymax)) = dict.keys(map) |> list.reduce(coord.max)
  list.range(0, ymax)
  |> list.map(fn(y) {
    list.range(0, xmax)
    |> list.map(fn(x) {
      let pos = #(x, y)
      case dict.get(path_dict, pos), dict.get(map, pos) {
        Ok(c), _ -> show_dir(c)
        _, Ok(m) -> m
        _, Error(_) -> panic as { "Outside map" }
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
  |> io.println()
  io.println("")
}

fn show_dir(c) {
  case c {
    #(0, 1) -> "v"
    #(-1, 0) -> "<"
    #(0, -1) -> "^"
    #(1, 0) -> ">"
    d -> panic as { "Unknown direction " <> coord.to_string(d) }
  }
}
