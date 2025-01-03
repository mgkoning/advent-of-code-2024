import day04
import gleeunit/should
import util

const input = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"

pub fn part1_test() {
  let grid = util.as_grid(input)
  day04.part1(grid)
  |> should.equal(18)
}

pub fn part2_test() {
  let grid = util.as_grid(input)
  day04.part2(grid)
  |> should.equal(9)
}
