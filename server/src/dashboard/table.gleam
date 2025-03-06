import gleam/dynamic/decode.{type Decoder}
import gleam/io
import gleam/option.{type Option}
import gleam/string
import lib/id.{type Id}
import shork
import youid/uuid.{type Uuid}

pub fn migrations() {
  "
CREATE TABLE IF NOT EXISTS gastos.dashboard (
  id INT NOT NULL AUTO_INCREMENT,
  uuid VARCHAR(36) NOT NULL,
  title VARCHAR(50) NOT NULL,
  first_person_name VARCHAR(40),
  second_person_name VARCHAR(40),
  PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8;
  "
}

pub type Dashboard {
  Dashboard(
    id: Id(Dashboard),
    title: String,
    first_person_name: Option(String),
    second_person_name: Option(String),
  )
}

fn row_decoder() -> Decoder(Dashboard) {
  // We don't decode the UUID because we already have it and it's supposed to be private, like a password.
  // We'll only need the `id` from now on.
  use id <- decode.field(0, id.decode_id())
  use title <- decode.field(1, decode.string)
  use first_person_name <- decode.field(2, decode.optional(decode.string))
  use second_person_name <- decode.field(2, decode.optional(decode.string))

  decode.success(Dashboard(id:, title:, first_person_name:, second_person_name:))
}

pub fn create(connection, title: String) -> Result(Uuid, CreateDashboardError) {
  case string.trim(title) == "" || string.length(title) > 50 {
    True -> Error(InvalidTitle)
    False -> {
      let id = uuid.v1()
      case
        shork.query("INSERT INTO gastos.dashboard (uuid, title) VALUES (?, ?)")
        |> shork.parameter(shork.text(id |> uuid.to_string))
        |> shork.parameter(shork.text(title))
        |> shork.execute(connection)
      {
        Ok(_) -> Ok(id)
        Error(query_error) -> {
          io.print("Create Dashboard query error: ")
          io.debug(query_error)
          Error(CreateDashboardQueryError(query_error))
        }
      }
    }
  }
}

pub type CreateDashboardError {
  InvalidTitle
  CreateDashboardQueryError(shork.QueryError)
}

pub fn get_by_uuid(
  connection,
  dashboard_uuid: Uuid,
) -> Result(Dashboard, GetDashboardError) {
  let return =
    shork.query(
      "SELECT id, title, first_person_name, second_person_name FROM gastos.dashboard WHERE uuid = ?",
    )
    |> shork.parameter(shork.text(uuid.to_string(dashboard_uuid)))
    |> shork.returning(row_decoder())
    |> shork.execute(connection)

  case return {
    Ok(shork.Returend(_, [dashboard])) -> Ok(dashboard)
    Ok(error) -> {
      io.print("Get Dashboard Not found: ")
      io.debug(error)
      Error(DashboardNotFound)
    }
    Error(query_error) -> {
      io.print("Get Dashboard query error: ")
      io.debug(query_error)
      Error(GetDashboardQueryError(query_error))
    }
  }
}

pub type GetDashboardError {
  DashboardNotFound
  GetDashboardQueryError(shork.QueryError)
}
