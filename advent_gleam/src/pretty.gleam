import gleam/int
import gleam/io

pub fn day_banner(day, title) {
  io.println("--- Day " <> int.to_string(day) <> ": " <> title <> " ---")
}

pub fn part1_result_int(result) {
  io.println("Part 1: " <> int.to_string(result))
}

pub fn part2_result_int(result) {
  io.println("Part 2: " <> int.to_string(result))
}
