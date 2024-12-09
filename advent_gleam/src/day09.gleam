import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import gleam/yielder
import util

pub fn run(input) {
  let disk = build_disk(input)
  io.println("Part 1: " <> int.to_string(part1(disk)))
  io.println("Part 2: " <> int.to_string(part2(disk)))
}

pub fn part1(disk: Dict(Int, Int)) {
  run_fragmenter(disk, 0, dict.size(disk) - 1)
  |> checksum()
}

pub fn part2(disk: Dict(Int, Int)) {
  run_defragmenter(disk, set.new(), dict.size(disk) - 1)
  |> checksum()
}

fn checksum(disk: Dict(Int, Int)) {
  disk
  |> dict.to_list
  |> list.filter_map(fn(p) {
    case p {
      #(_, -1) -> Error(Nil)
      #(a, b) -> Ok(a * b)
    }
  })
  |> list.fold(0, int.add)
}

fn run_fragmenter(disk: Dict(Int, Int), left, right) {
  case right <= left {
    True -> disk
    False ->
      case dict.get(disk, left), dict.get(disk, right) {
        Error(_), _ | _, Error(_) -> panic
        Ok(-1), Ok(-1) -> run_fragmenter(disk, left, right - 1)
        Ok(-1), Ok(r) -> {
          let new_disk =
            disk
            |> dict.insert(left, r)
            |> dict.insert(right, -1)
          run_fragmenter(new_disk, left + 1, right - 1)
        }
        Ok(_), _ -> run_fragmenter(disk, left + 1, right)
      }
  }
}

fn run_defragmenter(disk: Dict(Int, Int), moved: Set(Int), right) {
  let #(from, size) = find_file(disk, right)
  case from {
    -1 -> disk
    _ -> {
      let assert Ok(id) = dict.get(disk, from)
      case set.contains(moved, id) {
        True -> run_defragmenter(disk, moved, from - 1)
        False -> {
          let new_moved = set.insert(moved, id)
          case find_free(disk, 0, size, from) {
            -1 -> run_defragmenter(disk, new_moved, from - 1)
            index -> {
              let new_disk =
                disk
                |> write(index, id, size)
                |> write(from, -1, size)
              run_defragmenter(new_disk, new_moved, from - 1)
            }
          }
        }
      }
    }
  }
}

fn write(disk: Dict(Int, Int), from, id, size) {
  yielder.range(from, from + size - 1)
  |> yielder.fold(disk, fn(d, i) { dict.insert(d, i, id) })
}

fn find_free(disk: Dict(Int, Int), left, size, max) {
  case left {
    _ if max <= left -> -1
    _ ->
      case dict.get(disk, left) {
        Error(_) -> -1
        Ok(-1) -> {
          let free_size =
            yielder.iterate(left, int.add(_, 1))
            |> yielder.take_while(fn(i) { dict.get(disk, i) == Ok(-1) })
            |> yielder.length()
          case free_size {
            _ if size <= free_size -> left
            _ -> find_free(disk, left + free_size, size, max)
          }
        }
        Ok(_) -> find_free(disk, left + 1, size, max)
      }
  }
}

fn find_file(disk: Dict(Int, Int), from) {
  case dict.get(disk, from) {
    Error(_) -> #(-1, 0)
    Ok(-1) -> find_file(disk, from - 1)
    Ok(id) -> {
      let size =
        yielder.iterate(from, int.subtract(_, 1))
        |> yielder.take_while(fn(i) { dict.get(disk, i) == Ok(id) })
        |> yielder.length()
      #(from - { size - 1 }, size)
    }
  }
}

pub fn build_disk(input) {
  input
  |> string.to_graphemes()
  |> util.read_as_ints()
  |> yielder.from_list()
  |> yielder.zip(
    yielder.iterate(0, int.add(_, 1))
    |> yielder.intersperse(with: -1),
  )
  |> yielder.flat_map(fn(p) { yielder.repeat(p.1) |> yielder.take(p.0) })
  |> yielder.index()
  |> yielder.map(fn(p) { #(p.1, p.0) })
  |> yielder.to_list()
  |> dict.from_list()
}
