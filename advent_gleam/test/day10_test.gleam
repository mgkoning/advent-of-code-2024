import day10
import gleeunit/should

const input = "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"

pub fn part1_test() {
  let topo = day10.read_topo(input)
  day10.part1(topo)
  |> should.equal(36)
}

pub fn part2_test() {
  let topo = day10.read_topo(input)
  day10.part2(topo)
  |> should.equal(81)
}
