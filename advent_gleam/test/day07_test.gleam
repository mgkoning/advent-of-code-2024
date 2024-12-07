import day07
import gleeunit/should

const input = "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"

pub fn part2_test() {
  day07.part2(day07.read_equations(input))
  |> should.equal(11_387)
}
