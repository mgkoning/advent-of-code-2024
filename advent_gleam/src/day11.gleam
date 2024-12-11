import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder
import pretty
import util

type StoneMemo =
  Dict(#(Int, Int), Int)

pub fn run(input) {
  let stones = read_stones(input)
  let #(memo, part1) = part1_memo(stones)
  pretty.part1_result_int(part1)
  let #(_, part2) = part2_memo(stones, memo)
  pretty.part2_result_int(part2)
}

pub fn part1_memo(stones) {
  stones
  |> evo_all(dict.new(), 25)
}

fn part2_memo(stones, memo) {
  stones
  |> evo_all(memo, 75)
}

pub fn part1_naive(stones) {
  let assert Ok(v) =
    stones
    |> evolution()
    |> yielder.drop(25)
    |> yielder.first()
  list.length(v)
}

fn evolution(stones) {
  yielder.iterate(stones, fn(v) { list.flat_map(v, evolve(_)) })
}

fn evo_memo(memo: StoneMemo, stone, steps) {
  case steps {
    n if n < 0 -> panic
    0 -> #(memo, 1)
    _ -> {
      case dict.get(memo, #(stone, steps)) {
        Ok(n) -> #(memo, n)
        _ -> {
          let #(new_memo, count) = evo_all(evolve(stone), memo, steps - 1)
          #(dict.insert(new_memo, #(stone, steps), count), count)
        }
      }
    }
  }
}

fn evo_all(stones, memo: StoneMemo, steps) -> #(StoneMemo, Int) {
  stones
  |> list.fold(#(memo, 0), fn(acc, new_stone) {
    let #(new_memo, new_size) = evo_memo(acc.0, new_stone, steps)
    #(new_memo, acc.1 + new_size)
  })
}

fn evolve(stone) {
  case stone {
    0 -> [1]
    _ -> {
      split_even(int.to_string(stone))
      |> result.lazy_unwrap(fn() { [stone * 2024] })
    }
  }
}

fn split_even(stone) {
  let length = string.length(stone)
  case length % 2 {
    0 -> {
      let half = length / 2
      [string.slice(stone, 0, half), string.slice(stone, half, half)]
      |> util.read_as_ints()
      |> Ok
    }
    _ -> Error(Nil)
  }
}

pub fn read_stones(input) {
  input |> util.words |> util.read_as_ints
}
