import day01
import day02
import day03
import day04
import day05
import day06
import day07
import day08
import day09
import day10
import day11
import day12
import day13
import day14
import gleam/int
import gleam/list
import gleam/result
import pretty

const runners = [
  #("Historian Hysteria", day01.run), #("Red-Nosed Reports", day02.run),
  #("Mull It Over", day03.run), #("Ceres Search", day04.run),
  #("Print Queue", day05.run), #("Guard Gallivant", day06.run),
  #("Bridge Repair", day07.run), #("Resonant Collinearity", day08.run),
  #("Disk Fragmenter", day09.run), #("Hoof It", day10.run),
  #("Plutonian Pebbles", day11.run), #("Garden Groups", day12.run),
  #("Claw Contraption", day13.run), #("Restroom Redoubt", day14.run),
]

pub fn run(for day, with input) {
  runners
  |> list.drop(day - 1)
  |> list.first
  |> result.map(fn(runner) {
    let #(title, run) = runner
    pretty.day_banner(day, title)
    run(input)
  })
  |> result.map_error(fn(_) {
    "Day " <> int.to_string(day) <> " is not supported"
  })
}
