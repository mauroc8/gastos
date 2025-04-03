import gleam/dynamic/decode

pub type Person {
  First
  Second
}

pub fn to_string(person: Person) -> String {
  case person {
    First -> "0"
    Second -> "1"
  }
}

pub fn decode() {
  use string <- decode.then(decode.string)

  case string {
    "0" -> decode.success(First)
    "1" -> decode.success(Second)
    _ -> decode.failure(First, "decode_person expects a '0' or '1'")
  }
}

pub fn multiplier(person: Person) {
  case person {
    First -> -1.0
    Second -> 1.0
  }
}
