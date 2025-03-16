import gleam/dynamic/decode
import gleam/int
import shork

pub opaque type Id(entity) {
  Id(id: Int)
}

pub fn decode() -> decode.Decoder(Id(a)) {
  decode.int
  |> decode.map(Id)
}

pub fn to_int(id: Id(a)) {
  let Id(value) = id
  value
}

pub fn parameter(id: Id(a)) {
  shork.text(int.to_string(to_int(id)))
}

pub type DashboardT
