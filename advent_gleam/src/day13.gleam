import coord.{type Coord}
import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import pretty
import util

pub fn run(input) {
  let machines = read_machines(input)
  pretty.part1_result_int(part1(machines))
  pretty.part2_result_int(part2(machines))
}

pub fn part1(machines) {
  machines
  |> list.map(solve)
  |> result.values
  |> list.fold(0, int.add)
}

fn part2(machines) {
  machines
  |> list.map(correct_prize)
  |> part1()
}

const prize_correction = 10_000_000_000_000

fn correct_prize(machine: Machine) {
  let #(px, py) = machine.prize
  Machine(..machine, prize: #(px + prize_correction, py + prize_correction))
}

fn solve(machine: Machine) {
  let #(ax, ay) = floatify(machine.a)
  let #(bx, by) = floatify(machine.b)
  let #(px, py) = floatify(machine.prize)
  let af = { py -. px *. by /. bx } /. { ay -. { ax *. by /. bx } }
  let bf = { px -. af *. ax } /. bx
  let #(a, b) = #(float.round(af), float.round(bf))
  let result =
    coord.times(machine.a, a)
    |> coord.plus(coord.times(machine.b, b))
  case 0 <= a && 0 <= b && result == machine.prize {
    True -> Ok(a * 3 + b)
    False -> Error(Nil)
  }
}

fn floatify(c: Coord) {
  #(int.to_float(c.0), int.to_float(c.1))
}

pub type Machine {
  Machine(a: Coord, b: Coord, prize: Coord)
}

pub fn read_machines(input) {
  let assert Ok(re) =
    regexp.compile(
      "Button A: X\\+(\\d+), Y\\+(\\d+)\\nButton B: X\\+(\\d+), Y\\+(\\d+)\\nPrize: X=(\\d+), Y=(\\d+)",
      regexp.Options(case_insensitive: False, multi_line: True),
    )
  regexp.scan(re, input)
  |> list.map(fn(m) {
    let assert [ax, ay, bx, by, px, py] =
      m.submatches |> option.values |> util.read_as_ints
    Machine(#(ax, ay), #(bx, by), #(px, py))
  })
}
