import gleam/dynamic/decode

pub opaque type Id(entity) {
  Id(id: Int)
}

pub fn decode_id() -> decode.Decoder(Id(a)) {
  decode.int
  |> decode.map(Id)
}

pub fn to_int(id: Id(a)) {
  let Id(value) = id
  value
}
