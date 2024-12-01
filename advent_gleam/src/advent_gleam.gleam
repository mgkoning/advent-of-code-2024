import day01
import gleam/int
import util

pub fn main() {
  run(2)
}

fn run(day: Int) {
  let assert Ok(input) = util.read_input_file(day)
  case day {
    1 -> day01.run(input)
    other -> panic as { "Day " <> int.to_string(other) <> " is not supported" }
  }
}
