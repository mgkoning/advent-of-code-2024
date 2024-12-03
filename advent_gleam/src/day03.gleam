import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/regexp
import pretty
import util

const mul_regexp = "mul\\((\\d{1,3}),(\\d{1,3})\\)"

const mul_cond_regexp = mul_regexp <> "|do(n't)?\\(\\)"

pub fn run(input) {
  pretty.day_banner(3, "Mull It Over")
  io.println("Part 1: " <> int.to_string(part1(input)))
  io.println("Part 2: " <> int.to_string(part2(input)))
}

fn part1(memory) {
  let assert Ok(mul_finder) = regexp.from_string(mul_regexp)
  regexp.scan(mul_finder, memory)
  |> list.map(get_mul_result(_))
  |> list.fold(0, int.add)
}

fn part2(memory) {
  let assert Ok(instr_finder) = regexp.from_string(mul_cond_regexp)
  let result =
    regexp.scan(instr_finder, memory)
    |> list.fold(#(True, 0), fn(acc, next) {
      // fold with a very basic state machine using a bool for 'enabled'
      case acc.0, next.content {
        _, "don't()" -> #(False, acc.1)
        _, "do()" -> #(True, acc.1)
        False, _ -> acc
        True, _ -> #(acc.0, acc.1 + get_mul_result(next))
      }
    })
  result.1
}

fn get_mul_result(mul_match: regexp.Match) {
  mul_match.submatches
  |> option.values
  |> util.read_as_ints
  |> list.fold(1, int.multiply)
}
