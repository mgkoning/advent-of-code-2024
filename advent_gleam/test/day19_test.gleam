import day19
import gleeunit/should

const input = "r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"

pub fn part1_test() {
  let #(towels, designs) = day19.read_input(input)
  day19.part1(towels, designs)
  |> should.equal(6)
}

pub fn part2_test() {
  let #(towels, designs) = day19.read_input(input)
  day19.part2(towels, designs)
  |> should.equal(16)
}
