import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util

pub fn run(input) {
  let equations = read_equations(input)
  io.println("Part 1: " <> int.to_string(part1(equations)))
  io.println("Part 2: " <> int.to_string(part2(equations)))
}

fn part1(equations) {
  calibrate([int.add, int.multiply], equations)
}

pub fn part2(equations) {
  calibrate([int.add, int.multiply, concat], equations)
}

fn calibrate(operators, equations: List(Equation)) {
  equations
  |> list.filter(fn(eq) { is_solvable(operators, eq.target, eq.operands) })
  |> list.map(fn(eq) { eq.target })
  |> list.fold(0, int.add)
}

fn is_solvable(operators, target, operands) {
  case operands {
    [s] if target == s -> True
    [a, b, ..rest] ->
      operators
      |> list.any(fn(op) { is_solvable(operators, target, [op(a, b), ..rest]) })
    _ -> False
  }
}

pub fn concat(a, b) {
  run_concat(a, b, 10)
}

fn run_concat(a, b, factor) {
  case b % factor {
    r if r == b -> a * factor + b
    _ -> run_concat(a, b, factor * 10)
  }
}

pub type Equation {
  Equation(target: Int, operands: List(Int))
}

pub fn read_equations(input) {
  input
  |> util.convert_lines(fn(l) {
    let assert [lhs, rhs] = string.split(l, ": ")
    let assert Ok(target) = int.parse(lhs)
    Equation(target, rhs |> util.words |> util.read_as_ints)
  })
}
