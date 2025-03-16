import birl
import gleam/dynamic/decode
import gleam/int
import gleam/string

pub fn decode() {
  use string <- decode.then(decode.string)

  case string.split(string, "-") {
    [year, month, day] ->
      case int.parse(year), int.parse(month), int.parse(day) {
        Ok(year), Ok(month), Ok(day)
          if 1 <= month && month <= 12 && 1 <= day && day <= 31
        -> decode.success(#(year, month, day))

        _, _, _ -> decode.failure(#(0, 0, 0), "YYYY-MM-DD")
      }
    _ -> decode.failure(#(0, 0, 0), "YYYY-MM-DD")
  }
}

pub fn add_months(to date: #(Int, Int, Int), add months: Int) {
  let #(year, month, day) = date

  case month + months {
    new_month if new_month < 1 ->
      add_months(#(year - 1, new_month + 12, day), 0)
    new_month if new_month > 12 ->
      add_months(#(year + 1, new_month - 12, day), 0)
    new_month -> #(year, new_month, day)
  }
}

pub fn of(year: Int, month: Int, day: Int) {
  case year, month, day {
    year, month, day if month < 1 -> of(year - 1, month + 12, day)
    year, month, day if month > 12 -> of(year + 1, month - 12, day)

    year, month, day if day < 1 ->
      of(year, month - 1, last_day_of_month(year, month))

    year, month, day ->
      case day > last_day_of_month(year, month) {
        True -> of(year, month + 1, day - last_day_of_month(year, month))
        False -> #(year, month, day)
      }
  }
}

fn last_day_of_month(year: Int, month: Int) {
  case month {
    1 -> 31
    2 ->
      case is_leap(year) {
        True -> 29
        False -> 28
      }
    3 -> 31
    4 -> 30
    5 -> 31
    6 -> 30
    7 -> 31
    8 -> 31
    9 -> 30
    10 -> 31
    11 -> 30
    12 | _ -> 31
  }
}

fn is_leap(year) {
  year % 400 == 0 || year % 4 == 0 && year % 100 != 0
}
