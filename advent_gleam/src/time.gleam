@external(erlang, "erlang", "date")
fn today() -> #(Int, Int, Int)

pub fn day_of_month() {
  let #(_, _, day) = today()
  day
}
