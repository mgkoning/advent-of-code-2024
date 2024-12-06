import day06
import gleeunit/should
import util

const input = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."

pub fn part1_test() {
  let grid = util.as_grid(input)
  day06.part1(grid)
  |> should.equal(41)
}

pub fn part2_test() {
  let grid = util.as_grid(input)
  day06.part2(grid)
  |> should.equal(6)
}
