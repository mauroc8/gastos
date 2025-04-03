import gleam/dynamic/decode

pub type Kind {
  /// A shared expense divided equally between the two persons
  Expense
  /// A loan that one person has to pay to the other
  GrantedLoan
}

pub fn to_string(kind: Kind) -> String {
  case kind {
    Expense -> "0"
    GrantedLoan -> "1"
  }
}

pub fn decode() {
  use string <- decode.then(decode.string)

  case string {
    "0" -> decode.success(Expense)
    "1" -> decode.success(GrantedLoan)
    _ -> decode.failure(Expense, "decode_kind expects a '0' or '1'")
  }
}

pub fn multiplier(kind: Kind) {
  case kind {
    // Expenses are shared 50% between the two persons, so the other person only owes half of its amount
    Expense -> 0.5
    GrantedLoan -> 1.0
  }
}
