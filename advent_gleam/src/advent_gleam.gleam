import argv
import gleam/int
import gleam/result
import runner
import time
import util

pub fn main() {
  run(determine_day())
}

fn run(day: Int) {
  util.read_input_file(day)
  |> result.map_error(fn(_) { "No input file for day " <> int.to_string(day) })
  |> result.try(fn(input) { runner.run(for: day, with: input) })
  |> result.map_error(fn(msg) { panic as msg })
}

fn determine_day() {
  case argv.load().arguments {
    [] -> time.day_of_month()
    [n] -> {
      let assert Ok(day) = int.parse(n)
      day
    }
    _ -> panic as "Too many arguments"
  }
}
