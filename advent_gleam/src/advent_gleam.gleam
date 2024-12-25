import argv
import gleam/int
import gleam/io
import gleam/result
import gleam/yielder
import runner
import time
import util

pub fn main() {
  case determine_day() {
    Day(n) -> run(n)
    All -> {
      yielder.range(1, 25)
      |> yielder.map(run)
      |> yielder.each(fn(_) { io.println("") })
      |> Ok()
    }
  }
}

fn run(day: Int) {
  util.read_input_file(day)
  |> result.map_error(fn(_) { "No input file for day " <> int.to_string(day) })
  |> result.try(fn(input) { runner.run(for: day, with: input) })
  |> result.map_error(fn(msg) { panic as msg })
}

fn determine_day() {
  case argv.load().arguments {
    [] -> Day(time.day_of_month())
    ["all"] -> All
    [n] -> {
      let assert Ok(day) = int.parse(n)
      Day(day)
    }
    _ -> panic as "Too many arguments"
  }
}

type Mode {
  Day(n: Int)
  All
}
