import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/order
import gleam/pair
import gleam/regexp
import gleam/result
import gleam/set
import gleam/string
import pretty
import util

pub fn run(input) {
  let #(initial_wires, gates) = read_wires_and_gates(input)
  let circuit = build_circuit(initial_wires, gates)
  pretty.part1_result_int(part1(initial_wires, circuit))
  pretty.part2_result_str(part2(circuit))
}

fn part1(initial_wires, circuit: Circuit) {
  run_circuit(initial_wires, circuit)
}

fn run_circuit(initial, circuit: Circuit) {
  circuit.ordering
  |> list.fold(initial, fn(values, output) {
    case dict.has_key(values, output) {
      True -> values
      False -> {
        let assert Ok([gate]) = dict.get(circuit.gate_lookup, output)
        let assert Ok(in0_val) = dict.get(values, gate.in0)
        let assert Ok(in1_val) = dict.get(values, gate.in1)
        values
        |> dict.insert(output, get_output(gate.op, in0_val, in1_val))
      }
    }
  })
  |> dict.to_list()
  |> get_values_for("z")
  |> get_int()
}

fn part2(circuit: Circuit) {
  list.range(0, 44)
  |> list.map(fn(i) {
    get_diff(build_add_expr(i), expr_from_circuit(value_name(i, "z"), circuit))
  })
  |> list.fold(set.new(), fn(acc, next) {
    case next {
      Ok(_) -> acc
      Error(es) -> {
        acc |> set.union(set.from_list(es))
      }
    }
  })
  |> set.to_list()
  |> list.sort(string.compare)
  |> string.join(",")
}

fn expr_from_circuit(value, circuit: Circuit) {
  case value {
    "x" <> _ | "y" <> _ -> Literal(value)
    _ -> {
      let assert Ok([Gate(in0, in1, op, out)]) =
        dict.get(circuit.gate_lookup, value)
      BinOp(
        op,
        expr_from_circuit(in0, circuit),
        expr_from_circuit(in1, circuit),
        out,
      )
    }
  }
}

fn get_diff(expected, actual) {
  case expected, actual {
    Literal(e), Literal(a) if e == a -> Ok(Nil)
    Literal(_), Literal(a) -> Error([a])
    Literal(_), BinOp(_, _, _, note) -> Error([note])
    BinOp(_, _, _, _), Literal(a) -> Error([a])
    BinOp(op_e, _, _, _), BinOp(op_a, _, _, note) if op_e != op_a ->
      Error([note])
    BinOp(_, lhs_e, rhs_e, _), BinOp(_, lhs_a, rhs_a, _) -> {
      case
        get_diff(lhs_e, lhs_a),
        get_diff(lhs_e, rhs_a),
        get_diff(rhs_e, lhs_a),
        get_diff(rhs_e, rhs_a)
      {
        Ok(_), _, _, Ok(_) | _, Ok(_), Ok(_), _ -> Ok(Nil)
        Error(l), _, _, Ok(_) | _, Ok(_), Error(l), _ -> Error(l)
        _, Error(r), Ok(_), _ | Ok(_), _, _, Error(r) -> Error(r)
        Error(e1), Error(e2), Error(e3), Error(e4) -> {
          case lhs_e, rhs_e, lhs_a, rhs_a {
            BinOp(el, _, _, _),
              BinOp(er, _, _, _),
              BinOp(al, _, _, _),
              BinOp(ar, _, _, _)
            -> {
              // try to determine the most likely error ... possibly only works for my input
              case el == al, er == ar, el == ar, er == al {
                True, False, _, _ -> Error(e4)
                _, _, True, False -> Error(e3)
                False, True, _, _ -> Error(e1)
                _, _, False, True -> Error(e2)
                _, _, _, _ ->
                  Error(
                    e1 |> list.append(e2) |> list.append(e3) |> list.append(e4),
                  )
              }
            }
            _, _, _, _ ->
              Error(e1 |> list.append(e2) |> list.append(e3) |> list.append(e4))
          }
        }
      }
    }
  }
}

fn build_add_expr(i) {
  let input_x = Literal(value_name(i, "x"))
  let input_y = Literal(value_name(i, "y"))
  case i {
    0 -> BinOp("XOR", input_x, input_y, "")
    _ ->
      BinOp(
        "XOR",
        BinOp("XOR", input_x, input_y, ""),
        build_carry_expr(i - 1),
        "",
      )
  }
}

fn build_carry_expr(i) {
  let input_x = Literal(value_name(i, "x"))
  let input_y = Literal(value_name(i, "y"))
  case i {
    0 -> BinOp("AND", input_x, input_y, "")
    _ ->
      BinOp(
        "OR",
        BinOp("AND", input_x, input_y, ""),
        BinOp(
          "AND",
          BinOp("XOR", input_x, input_y, ""),
          build_carry_expr(i - 1),
          "",
        ),
        "",
      )
  }
}

fn value_name(index, prefix) {
  prefix <> index |> int.to_string() |> string.pad_start(2, "0")
}

fn get_values_for(values: List(#(String, Int)), prefix: String) {
  values |> list.filter(fn(p) { string.starts_with(p.0, prefix) })
}

fn build_circuit(initial_wires, gates: List(Gate)) {
  let inputs = initial_wires |> dict.keys()
  let connections =
    gates
    |> list.flat_map(fn(g) { [#(g.in0, g.out), #(g.in1, g.out)] })
    |> list.filter(fn(p) { !list.contains(inputs, p.0) })
  let nodes = gates |> list.map(fn(g) { g.out })
  let ordering = do_topo_sort([], inputs, nodes, connections)
  Circuit(
    ordering,
    gates |> list.group(fn(g) { g.out }),
    gates |> list.flat_map(fn(g) { [#(g.out, g.in0), #(g.out, g.in1)] }),
  )
}

fn get_int(outputs: List(#(String, Int))) {
  outputs
  |> list.sort(fn(p0, p1) { string.compare(p0.0, p1.0) |> order.negate() })
  |> list.fold(0, fn(acc, p) { acc * 2 + p.1 })
}

fn get_output(op, in1, in2) {
  case op {
    "AND" -> int.bitwise_and(in1, in2)
    "OR" -> int.bitwise_or(in1, in2)
    "XOR" -> int.bitwise_exclusive_or(in1, in2)
    _ -> panic as { "Unknown op: " <> op }
  }
}

type Expr {
  BinOp(op: String, lhs: Expr, rhs: Expr, note: String)
  Literal(value: String)
}

type Circuit {
  Circuit(
    ordering: List(String),
    gate_lookup: Dict(String, List(Gate)),
    reverse_connections: List(#(String, String)),
  )
}

type Gate {
  Gate(in0: String, in1: String, op: String, out: String)
}

fn do_topo_sort(sorted, no_incoming, nodes, edges: List(#(a, a))) {
  case no_incoming {
    [] -> list.reverse(sorted)
    [n, ..rest] -> {
      let new_nodes = nodes |> list.filter(fn(o) { o != n })
      let new_edges = edges |> list.filter(fn(e) { e.0 != n })
      let new_no_inc =
        new_nodes
        |> list.filter(fn(p) {
          !list.contains(list.map(new_edges, fn(r) { r.1 }), p)
          && !list.contains(rest, p)
        })
      do_topo_sort(
        [n, ..sorted],
        list.append(rest, new_no_inc),
        new_nodes,
        new_edges,
      )
    }
  }
}

fn read_wires_and_gates(input) {
  let assert Ok(gates_re) =
    regexp.compile(
      "([a-z0-9]+) (AND|OR|XOR) ([a-z0-9]+) -> ([a-z0-9]+)",
      regexp.Options(False, False),
    )
  let assert [wires, gates] = string.split(input, "\n\n")
  #(
    wires
      |> util.convert_lines(string.split_once(_, ": "))
      |> result.values()
      |> list.map(pair.map_second(_, must_read_int))
      |> dict.from_list(),
    regexp.scan(gates_re, gates)
      |> list.map(fn(m) {
        let assert [in1, op, in2, out] = m.submatches |> option.values()
        Gate(in1, in2, op, out)
      }),
  )
}

fn must_read_int(value) {
  let assert Ok(res) = int.parse(value)
  res
}

fn show_expr(expr, indent) {
  let at_indent = fn(v) { string.repeat(" ", indent * 2) <> v }
  case expr {
    Literal(a) -> [at_indent(a)]
    BinOp(op, lhs, rhs, note) -> {
      let addition = case note {
        "" -> ""
        _ -> " (" <> note <> ")"
      }
      let here = at_indent(op <> addition)
      let left = show_expr(lhs, indent + 1)
      let right = show_expr(rhs, indent + 1)
      case list.length(left) < list.length(right) {
        True -> {
          list.append(left, [here, ..right])
        }
        False -> {
          list.append(right, [here, ..left])
        }
      }
    }
  }
}
