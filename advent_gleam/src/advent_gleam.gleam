import argv
import day01
import day02
import day03
import day04
import gleam/int
import time
import util

pub fn main() {
  run(determine_day())
}

fn run(day: Int) {
  let input = case util.read_input_file(day) {
    Ok(contents) -> contents
    _ -> panic as { "No input file for day " <> int.to_string(day) }
  }
  case day {
    1 -> day01.run(input)
    2 -> day02.run(input)
    3 -> day03.run(input)
    4 -> day04.run(input)
    other -> panic as { "Day " <> int.to_string(other) <> " is not supported" }
  }
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
