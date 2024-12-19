import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import pretty
import util

pub fn run(input) {
  let #(towels, designs) = read_input(input)
  pretty.part1_result_int(part1(towels, designs))
  pretty.part2_result_int(part2(towels, designs))
}

pub fn part1(towels, designs) {
  designs
  |> list.count(fn(d) { 0 < pair.second(count_possible(d, towels, dict.new())) })
}

pub fn part2(towels, designs) {
  designs
  |> list.map(count_possible(_, towels, dict.new()))
  |> list.map(pair.second)
  |> list.fold(0, int.add)
}

fn count_possible(design: String, towels: List(String), memo: Dict(String, Int)) {
  case string.byte_size(design) {
    0 -> #(memo, 1)
    size ->
      case dict.get(memo, design) {
        Ok(count) -> #(memo, count)
        _ -> {
          let #(new_memo, possible) =
            towels
            |> list.filter(string.starts_with(design, _))
            |> list.fold(#(memo, 0), fn(acc, towel) {
              let #(new_memo2, n) =
                count_possible(
                  string.slice(design, string.byte_size(towel), size),
                  towels,
                  acc.0,
                )
              #(new_memo2, acc.1 + n)
            })
          #(dict.insert(new_memo, design, possible), possible)
        }
      }
  }
}

pub fn read_input(input) {
  let assert [towels, designs] = string.split(input, "\n\n")
  #(towels |> string.split(", "), designs |> util.lines())
}
