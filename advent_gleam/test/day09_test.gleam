import day09
import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleeunit/should

const input = "2333133121414131402"

pub fn read_disk_test() {
  let x = day09.build_disk(input)
  stringify_disk(x)
  |> should.equal("00...111...2...333.44.5555.6666.777.888899")
}

pub fn part1_test() {
  let disk = day09.build_disk(input)
  day09.part1(disk)
  |> should.equal(1928)
}

pub fn part2_test() {
  let disk = day09.build_disk(input)
  day09.part2(disk)
  |> should.equal(2858)
}

fn stringify_disk(disk) {
  dict.keys(disk)
  |> list.sort(int.compare)
  |> list.map(fn(i) { dict.get(disk, i) })
  |> result.values()
  |> list.map(fn(i) {
    case i {
      -1 -> "."
      _ -> int.to_string(i)
    }
  })
  |> string.join("")
}
