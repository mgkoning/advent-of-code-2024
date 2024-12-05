import day01
import day02
import day03
import day04
import day05
import gleam/int
import gleam/list
import gleam/result
import pretty

const runners = [
  #("Historian Hysteria", day01.run), #("Red-Nosed Reports", day02.run),
  #("Mull It Over", day03.run), #("Ceres Search", day04.run),
  #("Print Queue", day05.run),
]

pub fn run(for day, with input) {
  runners
  |> list.drop(day - 1)
  |> list.first
  |> result.map(fn(runner) {
    pretty.day_banner(day, runner.0)
    runner.1(input)
  })
  |> result.map_error(fn(_) {
    "Day " <> int.to_string(day) <> " is not supported"
  })
}
