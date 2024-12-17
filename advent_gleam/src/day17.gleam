import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/pair
import gleam/regexp
import gleam/string
import pretty
import util

pub fn run(input) {
  let mem = read_program(input)
  pretty.part1_result_str(part1(mem))
  pretty.part2_result_int(part2(mem))
}

fn part1(mem) {
  print_program(run_program(mem, []))
}

// The instructions iterate by doing a div by 8 of the value in the A register, and it
// must end at 0. The output at every iteration is determined only by the last three bits
// of A. We can therefore iterate backwards through the program to build up to the possible
// starting values.
// Because we know the intended output, we can use our knowledge of the program to 
// try all possible combinations of the last three bits (0..7) and remembering which
// of those values result in the correct output for these bits.
// Because it is possible for several values of the last three bits to result in the
// same output, we maintain a list of possible inputs for the next iteration. We remove
// those combinations that we find don't work for a digit in the output.
fn part2(mem: Memory) {
  let reversed_program =
    mem.program
    |> dict.to_list()
    |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
    |> list.map(pair.second)
    |> list.reverse()
  let assert Ok(answer) =
    reversed_program
    |> list.fold([0], fn(possibles, next) {
      possibles
      |> list.flat_map(fn(v) {
        list.range(0, 7)
        |> list.map(fn(i) { 8 * v + i })
        |> list.filter(fn(a) {
          Ok(next) == run_program(Memory(..mem, a: a), []) |> list.first()
        })
      })
    })
    |> list.sort(int.compare)
    |> list.first()
  answer
}

fn print_program(program: List(Int)) {
  program |> list.map(int.to_string) |> string.join(",")
}

fn run_program(mem: Memory, output) {
  case dict.get(mem.program, mem.ip) {
    Error(_) -> list.reverse(output)
    Ok(op) -> {
      let assert Ok(operand) = dict.get(mem.program, mem.ip + 1)
      let #(new_mem, new_output) = run_op(mem, output, op, operand)
      run_program(new_mem, new_output)
    }
  }
}

fn run_op(mem: Memory, output: List(Int), op: Int, operand: Int) {
  let simple_result = fn(mem: Memory) {
    #(Memory(..mem, ip: mem.ip + 2), output)
  }
  case op {
    0 -> simple_result(Memory(..mem, a: run_div(mem, operand)))
    6 -> simple_result(Memory(..mem, b: run_div(mem, operand)))
    7 -> simple_result(Memory(..mem, c: run_div(mem, operand)))
    1 ->
      simple_result(Memory(..mem, b: int.bitwise_exclusive_or(mem.b, operand)))
    2 -> simple_result(Memory(..mem, b: combo_operand(mem, operand) % 8))
    3 ->
      case mem.a {
        0 -> simple_result(mem)
        _ -> #(Memory(..mem, ip: operand), output)
      }
    4 -> simple_result(Memory(..mem, b: int.bitwise_exclusive_or(mem.b, mem.c)))
    5 -> #(Memory(..mem, ip: mem.ip + 2), [
      combo_operand(mem, operand) % 8,
      ..output
    ])
    _ -> panic as { "unknown op " <> int.to_string(op) }
  }
}

fn run_div(mem: Memory, operand) {
  let assert Ok(result) =
    int.power(2, int.to_float(combo_operand(mem, operand)))
  float.truncate(int.to_float(mem.a) /. result)
}

fn combo_operand(mem: Memory, operand: Int) {
  case operand {
    0 | 1 | 2 | 3 -> operand
    4 -> mem.a
    5 -> mem.b
    6 -> mem.c
    7 -> panic as { "hit reserved combo operand" }
    _ -> panic as { "unknown combo operand " <> int.to_string(operand) }
  }
}

type Memory {
  Memory(a: Int, b: Int, c: Int, program: Dict(Int, Int), ip: Int)
}

fn read_program(input) {
  let assert Ok(re) =
    regexp.compile(
      "^Register A: (\\d+)\\nRegister B: (\\d+)\\nRegister C: (\\d+)\\n\\nProgram: ([0-9,]+)$",
      regexp.Options(case_insensitive: False, multi_line: True),
    )
  let assert [regexp.Match(_, sub)] = regexp.scan(re, input)
  let assert #(registers, [program]) =
    sub
    |> option.values()
    |> list.split(3)
  let assert [a, b, c] = util.read_as_ints(registers)
  let program =
    program
    |> string.split(",")
    |> util.read_as_ints()
    |> list.index_map(fn(a, i) { #(i, a) })
    |> dict.from_list()
  Memory(a, b, c, program, 0)
}
