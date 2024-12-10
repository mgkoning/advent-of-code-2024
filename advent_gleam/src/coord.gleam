import gleam/int
import gleam/list
import gleam/order

pub type Coord =
  #(Int, Int)

const east = #(1, 0)

const south = #(0, 1)

const west = #(-1, 0)

const north = #(0, -1)

pub fn compare(a: Coord, b: Coord) {
  int.compare(a.0, b.0)
  |> order.lazy_break_tie(fn() { int.compare(a.1, b.1) })
}

pub fn plus(a: Coord, b: Coord) {
  #(a.0 + b.0, a.1 + b.1)
}

pub fn minus(a: Coord, b: Coord) {
  #(a.0 - b.0, a.1 - b.1)
}

pub fn negate(c: Coord) {
  #(-c.0, -c.1)
}

pub fn max(a: Coord, b: Coord) {
  case compare(a, b) {
    order.Gt -> a
    _ -> b
  }
}

pub fn neighbours4(a: Coord) {
  [east, south, west, north]
  |> list.map(plus(a, _))
}
