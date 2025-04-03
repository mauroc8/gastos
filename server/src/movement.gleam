import birl
import birl/duration
import gleam/dynamic/decode
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import lib/id.{type DashboardT, type Id}
import movement_kind
import person
import shork

pub fn migrations() {
  "
create table if not exists gastos.movement (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  person BOOLEAN NOT NULL,
  kind BOOLEAN NOT NULL,
  amount INT UNSIGNED NOT NULL,
  concept VARCHAR(100) NOT NULL,
  date DATE NOT NULL,
  installments TINYINT UNSIGNED NOT NULL,
  dashboard_id INT UNSIGNED NOT NULL,
  primary key (id),
  foreign key (dashboard_id) references gastos.dashboard(id)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8;
  "
}

/// A movement.
/// 
/// It can represent an expense that should be split between the two persons,
/// or a loan that one person grants to the other.
/// 
/// It can be split in installments. The date is the date where the expense was
/// made or the date where the first installment should be paid.
pub type Movement {
  Movement(
    id: Id(Movement),
    person: person.Person,
    kind: movement_kind.Kind,
    amount: Int,
    concept: String,
    date: birl.Time,
    installments: Int,
  )
}

// TODO: Validate `concept` length
pub fn create(
  connection,
  dashboard_id: Id(DashboardT),
  person: person.Person,
  kind: movement_kind.Kind,
  amount: Int,
  concept: String,
  date: birl.Time,
  installments: Int,
) {
  shork.query(
    "
    insert into gastos.movement (
      dashboard_id,
      person,
      kind,
      amount,
      concept,
      date,
      installments
    )
    values (?, ?, ?, ?, ?, ?, ?)
  ",
  )
  |> shork.parameter(id.parameter(dashboard_id))
  |> shork.parameter(shork.text(person.to_string(person)))
  |> shork.parameter(shork.text(movement_kind.to_string(kind)))
  |> shork.parameter(shork.text(int.to_string(amount)))
  |> shork.parameter(shork.text(concept))
  |> shork.parameter(shork.text(birl.to_iso8601(date)))
  |> shork.parameter(shork.text(int.to_string(installments)))
  |> shork.execute(connection)
}

pub fn fetch(with connection, in dashboard_id: Id(DashboardT)) {
  shork.query(
    "
      select
        id,
        person,
        kind,
        amount,
        concept,
        date,
        installments
      from gastos.movement
      where dashboard_id = ?
      sort by date
    ",
  )
  |> shork.parameter(id.parameter(dashboard_id))
  |> shork.returning({
    use id <- decode.field(0, id.decode())
    use person <- decode.field(1, person.decode())
    use kind <- decode.field(2, movement_kind.decode())
    use amount <- decode.field(3, decode.int)
    use concept <- decode.field(4, decode.string)
    use date <- decode.field(5, decode_time())
    use installments <- decode.field(6, decode.int)

    decode.success(Movement(
      id:,
      person:,
      kind:,
      amount:,
      concept:,
      date:,
      installments:,
    ))
  })
  |> shork.execute(connection)
}

fn decode_time() {
  use string <- decode.then(decode.string)

  case birl.parse(string) {
    Ok(time) -> decode.success(time)
    Error(_) ->
      decode.failure(birl.from_unix(0), "decode_time expects an ISO8601 string")
  }
}

/// A balance calculated relative to FirstPerson.
/// E.g. if balance returns `-5000` then FirstPerson lost money, so SecondPerson
/// owes $5000 to FirstPerson to compensate.
pub fn balance(movements: List(Movement), now: birl.Time) -> Int {
  use total, movement <- list.fold(movements, 0)

  let Movement(person:, amount:, kind:, date:, installments:, ..) = movement

  let movement_balance =
    int.to_float(amount)
    *. person.multiplier(person)
    *. movement_kind.multiplier(kind)
    *. installments_multiplier(#(date, installments), now)
    |> float.round()

  total + movement_balance
}

/// Returns how much one person owes to another based on the movements, or None if the debt is
/// settled.
pub fn debt(
  movements: List(Movement),
  now: birl.Time,
) -> Option(#(person.Person, Int)) {
  case balance(movements, now) {
    balance if balance < 0 -> Some(#(person.Second, -balance))

    balance if balance == 0 -> None

    balance -> Some(#(person.First, balance))
  }
}

// --- INSTALLMENTS

fn installments_multiplier(payment: #(birl.Time, Int), now: birl.Time) -> Float {
  let #(date, installments) = payment

  case installments {
    0 -> 1.0

    _ if installments < 0 -> 1.0

    _ ->
      int.to_float(amount_of_months_due(from: date, to: now))
      /. int.to_float(installments)
  }
}

fn amount_of_months_due(from date: birl.Time, to now: birl.Time) -> Int {
  case birl.compare(now, date) {
    order.Lt -> 0
    order.Eq -> 1
    order.Gt ->
      1 + amount_of_months_due(birl.add(date, duration.months(1)), now)
  }
}
