import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string
import util

pub fn run(input) {
  let #(ordering, production) = read_input(input)
  io.println("Part 1: " <> int.to_string(part1(ordering, production)))
  io.println("Part 2: " <> int.to_string(part2(ordering, production)))
}

fn part1(ordering, production) {
  production
  |> list.filter(fn(q) { is_ordered(q, ordering) })
  |> list.map(fn(q) { get_middle(q) })
  |> list.fold(0, int.add)
}

fn part2(ordering, production) {
  production
  |> list.filter(fn(q) { !is_ordered(q, ordering) })
  |> list.map(fn(q) { topo_sort(q, ordering) })
  |> list.map(fn(q) { get_middle(q) })
  |> list.fold(0, int.add)
}

fn topo_sort(queue, ordering: List(#(Int, Int))) {
  let nodes = set.from_list(queue)
  let relevant_rules =
    ordering
    |> list.filter(fn(o) {
      set.contains(nodes, o.0) && set.contains(nodes, o.1)
    })
  let no_incoming =
    queue
    |> list.filter(fn(p) {
      !list.contains(list.map(relevant_rules, fn(r) { r.1 }), p)
    })
  do_topo_sort([], no_incoming, queue, relevant_rules)
}

fn do_topo_sort(sorted, no_incoming, nodes, edges: List(#(Int, Int))) {
  case no_incoming {
    [] -> list.reverse(sorted)
    [n, ..rest] -> {
      let new_nodes = nodes |> list.filter(fn(o) { o != n })
      let new_edges = edges |> list.filter(fn(e) { e.0 != n })
      let new_no_inc =
        new_nodes
        |> list.filter(fn(p) {
          !list.contains(list.map(new_edges, fn(r) { r.1 }), p)
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

fn is_ordered(queue, ordering) {
  queue
  |> list.combination_pairs
  |> list.all(fn(p) { list.contains(ordering, p) })
}

fn get_middle(queue) {
  let assert Ok(middle) =
    queue
    |> list.drop(list.length(queue) / 2)
    |> list.first
  middle
}

fn read_input(input) {
  let assert [ordering, production] = string.split(input, "\n\n")
  #(
    ordering
      |> util.lines
      |> list.map(fn(l) {
        let assert [a, b] = string.split(l, "|") |> util.read_as_ints
        #(a, b)
      }),
    production
      |> util.lines
      |> list.map(fn(l) { string.split(l, ",") |> util.read_as_ints }),
  )
}
