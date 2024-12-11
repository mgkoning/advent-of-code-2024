import day11
import gleam/pair
import gleeunit/should

const input = "125 17"

pub fn part1_test() {
  let s = day11.read_stones(input)
  day11.part1_naive(s)
  |> should.equal(55_312)
}

pub fn part1_memo_test() {
  let s = day11.read_stones(input)
  day11.part1_memo(s)
  |> pair.second()
  |> should.equal(55_312)
}
