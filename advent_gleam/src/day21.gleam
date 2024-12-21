import coord.{type Coord}
import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleam/string
import pretty
import util

const num_pad_layout = "789
456
123
.0A"

const dir_pad_layout = ".^A
<v>"

pub fn run(input) {
  let codes = util.lines(input)
  let path_cache = get_path_cache()
  pretty.part1_result_int(run_part(codes, path_cache, 3))
  pretty.part2_result_int(run_part(codes, path_cache, 26))
}

fn run_part(codes, path_cache, levels) {
  codes
  |> list.map(fn(code) {
    string.to_graphemes(code)
    |> find_min_presses(levels, path_cache, dict.new())
    |> pair.map_second(int.multiply(_, extract_nums(code)))
    |> pair.second()
  })
  |> list.fold(0, int.add)
}

fn extract_nums(code) {
  let assert Ok(code_nums) =
    int.parse(string.slice(code, 0, string.byte_size(code) - 1))
  code_nums
}

fn find_min_presses(seq, level, path_cache, memo) {
  case level {
    n if n < 1 -> #(memo, list.length(seq))
    _ -> {
      ["A", ..seq]
      |> list.window_by_2()
      |> list.fold(#(memo, 0), fn(acc, p) {
        let #(from, to) = p
        let #(memo, sum) = acc
        let memo_key = #(from, to, level)
        case dict.get(memo, memo_key) {
          Ok(min) -> #(memo, sum + min)
          _ -> {
            let assert Ok(paths) = dict.get(path_cache, p)
            let assert #(new_memo, Ok(min)) =
              paths
              |> list.fold(#(memo, Error(Nil)), fn(acc, path) {
                find_min_presses(path, level - 1, path_cache, acc.0)
                |> pair.map_second(fn(len) {
                  acc.1 |> result.map(int.min(len, _)) |> result.or(Ok(len))
                })
              })
            #(new_memo |> dict.insert(memo_key, min), sum + min)
          }
        }
      })
    }
  }
}

fn get_path_cache() {
  build_pad_path_cache(get_pad(num_pad_layout))
  |> dict.merge(build_pad_path_cache(get_pad(dir_pad_layout)))
}

fn build_pad_path_cache(keypad) {
  let locs = dict.values(keypad) |> set.from_list()
  let keys = dict.to_list(keypad)
  keys
  |> list.flat_map(fn(a) {
    keys
    |> list.map(fn(b) { #(#(a.0, b.0), get_possible_moves(locs, a.1, b.1)) })
  })
  |> dict.from_list()
}

fn get_pad(pad_layout) {
  util.as_grid(pad_layout)
  |> dict.filter(fn(_, v) { v != "." })
  |> dict.fold(dict.new(), fn(acc, k, v) { dict.insert(acc, v, k) })
}

fn get_possible_moves(keypad, from: Coord, to: Coord) {
  let #(x_moves, y_moves) =
    coord.minus(to, from)
    |> pair.map_first(get_presses(_, "<", ">"))
    |> pair.map_second(get_presses(_, "^", "v"))
  list.append(x_moves, y_moves)
  |> list.permutations()
  |> list.unique()
  |> list.filter(fn(seq) {
    list.scan(seq, from, fn(pos, dir) { coord.plus(pos, to_dir(dir)) })
    |> list.all(set.contains(keypad, _))
  })
  |> list.map(fn(l) { list.append(l, ["A"]) })
}

fn get_presses(diff, neg_move, pos_move) {
  case diff {
    _ if diff < 0 -> neg_move
    _ -> pos_move
  }
  |> list.repeat(int.absolute_value(diff))
}

fn to_dir(value) {
  case value {
    "<" -> coord.left
    ">" -> coord.right
    "^" -> coord.up
    "v" -> coord.down
    _ -> panic as { "No such direction: " <> value }
  }
}
