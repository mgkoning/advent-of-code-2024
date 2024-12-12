import coord.{type Coord}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set.{type Set}
import pretty
import util

type GardenMap =
  Dict(Coord, String)

pub fn run(input) {
  let garden_map = read_plots(input)
  let plots = find_plots(garden_map, dict.keys(garden_map), [])
  pretty.part1_result_int(part1(garden_map, plots))
  pretty.part2_result_int(part2(garden_map, plots))
}

fn part1(garden_map: GardenMap, plots: List(Set(Coord))) {
  plots
  |> list.map(price_fencing_p1(garden_map, _))
  |> list.fold(0, int.add)
}

pub fn part2(garden_map: GardenMap, plots: List(Set(Coord))) {
  plots
  |> list.map(price_fencing_p2(garden_map, _))
  |> list.fold(0, int.add)
}

fn price_fencing_p1(garden_map: GardenMap, plot: Set(Coord)) {
  let perimeter =
    plot
    |> set.to_list()
    |> list.map(fn(c) {
      coord.neighbours4(c)
      |> list.filter(fn(n) {
        dict.get(garden_map, c) != dict.get(garden_map, n)
      })
      |> list.length()
    })
    |> list.fold(0, int.add)
  perimeter * set.size(plot)
}

fn price_fencing_p2(garden_map: GardenMap, plot: Set(Coord)) {
  let tiles = set.to_list(plot)
  let assert Ok(target) =
    tiles |> list.first() |> result.then(dict.get(garden_map, _))
  let sides =
    count_horizontal(garden_map, target, tiles, coord.north)
    + count_horizontal(garden_map, target, tiles, coord.south)
    + count_vertical(garden_map, target, tiles, coord.west)
    + count_vertical(garden_map, target, tiles, coord.east)

  sides * set.size(plot)
}

fn count_horizontal(garden_map, target, tiles, direction) {
  list.map(tiles, fn(t) { coord.plus(t, direction) })
  |> list.filter(fn(c) { dict.get(garden_map, c) != Ok(target) })
  |> list.group(pair.second)
  |> dict.map_values(fn(_, v) {
    list.map(v, pair.first)
    |> count_contiguous()
  })
  |> dict.values
  |> list.fold(0, int.add)
}

fn count_vertical(garden_map, target, tiles, direction) {
  list.map(tiles, fn(t) { coord.plus(t, direction) })
  |> list.filter(fn(c) { dict.get(garden_map, c) != Ok(target) })
  |> list.group(pair.first)
  |> dict.map_values(fn(_, v) {
    list.map(v, pair.second)
    |> count_contiguous()
  })
  |> dict.values
  |> list.fold(0, int.add)
}

pub fn count_contiguous(values: List(Int)) {
  let assert [v, ..vs] = list.sort(values, int.compare)
  list.fold(vs, #(v, 1), fn(acc, next) {
    case next {
      _ if next == acc.0 + 1 -> #(next, acc.1)
      _ -> #(next, acc.1 + 1)
    }
  })
  |> pair.second()
}

pub fn find_plots(
  garden_map: GardenMap,
  to_visit: List(Coord),
  plots: List(Set(Coord)),
) {
  case to_visit {
    [] -> plots
    [v, ..vs] -> {
      let assert Ok(target) = dict.get(garden_map, v)
      let plot = find_plot(garden_map, target, [v], set.from_list([v]))
      find_plots(garden_map, list.filter(vs, fn(c) { !set.contains(plot, c) }), [
        plot,
        ..plots
      ])
    }
  }
}

fn find_plot(garden_map, target, to_visit, plot) {
  case to_visit {
    [] -> plot
    [v, ..vs] -> {
      let neighbours =
        coord.neighbours4(v)
        |> list.filter(fn(n) {
          !set.contains(plot, n) && Ok(target) == dict.get(garden_map, n)
        })
      find_plot(
        garden_map,
        target,
        list.append(neighbours, vs),
        set.union(set.from_list(neighbours), plot),
      )
    }
  }
}

pub fn read_plots(input) {
  util.as_grid(input)
}
