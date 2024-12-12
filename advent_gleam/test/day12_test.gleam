import day12
import gleam/dict
import gleeunit/should

const input = "RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"

pub fn count_contiguous_test() {
  day12.count_contiguous([1, 2, 3, 4, 6, 8, 12, 13])
  |> should.equal(4)
}

pub fn part2_test() {
  let garden_map = day12.read_plots(input)
  let plots = day12.find_plots(garden_map, dict.keys(garden_map), [])
  day12.part2(garden_map, plots)
  |> should.equal(1206)
}
