import gleam/int
import gleam/io

pub fn day_banner(day, title) {
  io.println("--- Day " <> int.to_string(day) <> ": " <> title <> " ---")
}
