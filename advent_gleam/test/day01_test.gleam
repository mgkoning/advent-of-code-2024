import day01
import gleeunit/should

const input = "3   4
4   3
2   5
1   3
3   9
3   3"

pub fn part1_test() {
  let location_lists = day01.read_location_lists(input)
  day01.part1(location_lists)
  |> should.equal(11)
}

pub fn part2_test() {
  let location_lists = day01.read_location_lists(input)
  day01.part2(location_lists)
  |> should.equal(31)
}
