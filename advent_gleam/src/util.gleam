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

pub fn words(text) {
  let assert Ok(splitter) = regexp.from_string("\\s+")
  text
  |> string.trim
  |> regexp.split(with: splitter)
}
