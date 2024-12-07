import gleam/dict
import gleam/int
import gleam/list
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub fn read_input_file(day) {
  let num =
    day
    |> int.to_string
    |> string.pad_start(to: 2, with: "0")
  simplifile.read("../input/day" <> num <> ".txt")
}

pub fn read_as_ints(values: List(String)) -> List(Int) {
  values
  |> list.filter_map(int.parse(_))
}

pub fn get_or_default(dict, key, default) {
  dict.get(dict, key)
  |> result.unwrap(default)
}

pub fn lines(content) -> List(String) {
  string.split(content, "\n")
}

pub fn convert_lines(content, convert: fn(String) -> a) {
  content
  |> lines
  |> list.map(convert)
}

pub fn words(text) {
  let assert Ok(splitter) = regexp.from_string("\\s+")
  text
  |> string.trim
  |> regexp.split(with: splitter)
}

pub fn as_grid(input) {
  input
  |> lines
  |> list.index_map(fn(line, y) { #(y, line) })
  |> list.flat_map(fn(l) {
    string.to_graphemes(l.1)
    |> list.index_map(fn(c, x) { #(#(x, l.0), c) })
  })
  |> dict.from_list()
}
