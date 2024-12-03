import gleam/int
import gleam/io
import gleam/list
import pretty
import util

pub fn run(input) {
  pretty.day_banner(2, "Red-Nosed Reports")
  let reports = read_reports(input)
  io.println("Part 1: " <> int.to_string(part1(reports)))
  io.println("Part 2: " <> int.to_string(part2(reports)))
}

pub fn part1(reports) {
  reports
  |> list.count(is_safe(_))
}

pub fn part2(reports) {
  reports
  |> list.count(fn(report) {
    is_safe(report) || skip_one(report) |> list.any(is_safe(_))
  })
}

fn is_safe(report) {
  let diffs =
    report
    |> list.window_by_2
    |> list.map(fn(pair) { pair.1 - pair.0 })
  list.all(diffs, fn(diff) { 1 <= diff && diff <= 3 })
  || list.all(diffs, fn(diff) { -3 <= diff && diff <= -1 })
}

fn skip_one(report) {
  list.range(from: 1, to: list.length(report))
  |> list.map(fn(i) {
    report
    |> list.take(i - 1)
    |> list.append(list.drop(report, i))
  })
}

pub fn read_reports(input) {
  input
  |> util.lines
  |> list.map(fn(line) {
    line
    |> util.words
    |> util.read_as_ints
  })
}
