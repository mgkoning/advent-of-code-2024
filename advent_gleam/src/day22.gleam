import gleam/dict
import gleam/int
import gleam/list
import gleam/result
import gleam/yielder
import pretty
import util

pub fn run(input) {
  let secrets = input |> util.lines() |> util.read_as_ints()
  pretty.part1_result_int(part1(secrets))
  pretty.part2_result_int(part2(secrets))
}

fn part1(secrets) {
  secrets
  |> list.map(fn(secret) {
    yielder.iterate(secret, evolve_secret)
    |> yielder.drop(2000)
    |> yielder.first()
  })
  |> result.values()
  |> list.fold(0, int.add)
}

fn part2(secrets) {
  let assert Ok(max) =
    secrets
    |> list.map(prices_and_changes(_, 2000))
    |> list.map(fn(seq) {
      // take all windows of 4 per sequence and keep their first associated price
      seq
      |> list.window(4)
      |> list.fold(dict.new(), fn(acc, w) {
        let assert [#(_, a), #(_, b), #(_, c), #(price, d)] = w
        let key = #(a, b, c, d)
        case dict.has_key(acc, key) {
          True -> acc
          False -> dict.insert(acc, key, price)
        }
      })
    })
    // add up the best prices per window over all sequences
    |> list.fold(dict.new(), fn(acc, prices) {
      dict.combine(acc, prices, int.add)
    })
    |> dict.values()
    |> list.reduce(int.max)
  max
}

fn prices_and_changes(initial, count) {
  yielder.iterate(initial, evolve_secret)
  |> yielder.take(count + 1)
  |> yielder.map(fn(s) { s % 10 })
  |> yielder.to_list()
  |> list.window_by_2()
  |> list.map(fn(p) { #(p.1, p.1 - p.0) })
}

fn evolve_secret(value) {
  value
  |> mix_and_prune(fn(s) { s * 64 })
  |> mix_and_prune(fn(x) { x / 32 })
  |> mix_and_prune(fn(s) { s * 2048 })
}

fn mix_and_prune(value, transform) {
  int.bitwise_exclusive_or(value, transform(value)) % 16_777_216
}
