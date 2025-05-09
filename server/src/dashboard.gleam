import client_components
import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/string
import helpers/html_extra
import layout
import lib/id.{type DashboardT, type Id}
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/server_component
import movement
import shork
import youid/uuid.{type Uuid}

// --- DATABASE

pub fn migrations() {
  "
CREATE TABLE IF NOT EXISTS gastos.dashboard (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  uuid VARCHAR(36) NOT NULL,
  title VARCHAR(50) NOT NULL,
  first_person_name VARCHAR(40) NOT NULL,
  second_person_name VARCHAR(40) NOT NULL,
  PRIMARY KEY (id)
) ENGINE = InnoDB DEFAULT CHARACTER SET = utf8;
  "
}

pub type Dashboard {
  Dashboard(
    id: Id(DashboardT),
    title: String,
    first_person_name: String,
    second_person_name: String,
  )
}

// ---

pub type CreateDashboardParams {
  CreateDashboardParams(
    title: String,
    first_person_name: String,
    second_person_name: String,
  )
}

pub fn create(
  connection,
  params: CreateDashboardParams,
) -> Result(Uuid, CreateDashboardError) {
  let CreateDashboardParams(title:, first_person_name:, second_person_name:) =
    params

  case string.trim(title) == "" || string.length(title) > 50 {
    True -> Error(InvalidTitle)
    False -> {
      let id = uuid.v1()
      case
        shork.query(
          "INSERT INTO gastos.dashboard (uuid, title, first_person_name, second_person_name) VALUES (?, ?, ?, ?)",
        )
        |> shork.parameter(shork.text(id |> uuid.to_string))
        |> shork.parameter(shork.text(title))
        |> shork.parameter(shork.text(first_person_name))
        |> shork.parameter(shork.text(second_person_name))
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
    |> shork.returning({
      use id <- decode.field(0, id.decode())
      use title <- decode.field(1, decode.string)
      use first_person_name <- decode.field(2, decode.string)
      use second_person_name <- decode.field(3, decode.string)

      decode.success(Dashboard(
        id:,
        title:,
        first_person_name:,
        second_person_name:,
      ))
    })
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

// --- PAGE

pub fn page(id: String) {
  html_extra.document("Cargando… | Gastos", [
    element.element(
      "lustre-server-component",
      [
        server_component.route("/dashboard"),
        attribute.attribute("dashboard-id", id),
      ],
      [],
    ),
  ])
}

// --- COMPONENT

pub fn app() {
  lustre.component(init, update, view, on_attribute_change())
}

/// Receives the `uuid` via attributes
fn on_attribute_change() {
  dict.from_list([
    #("dashboard-id", fn(dynamic) {
      case dynamic.string(dynamic) {
        Ok(string_id) -> Ok(GotUuid(string_id))
        Error(error) -> Error(error)
      }
    }),
  ])
}

// ---

pub opaque type State {
  State(
    connection: shork.Connection,
    redirect_to: Option(String),
    dashboard: Option(Result(Dashboard, GetDashboardError)),
  )
}

fn init(connection) {
  #(State(connection:, redirect_to: None, dashboard: None), effect.none())
}

// ---

pub opaque type Msg {
  GotUuid(id: String)
}

fn update(state: State, msg: Msg) -> #(State, effect.Effect(Msg)) {
  case msg {
    GotUuid(id) ->
      case uuid.from_string(id) {
        Ok(id) -> {
          let State(connection:, ..) = state
          let response = get_by_uuid(connection, id)

          case response {
            Ok(dashboard) -> #(
              State(..state, dashboard: Some(Ok(dashboard))),
              effect.none(),
            )
            Error(board_load_error) -> #(
              State(..state, dashboard: Some(Error(board_load_error))),
              effect.none(),
            )
          }
        }
        Error(_) -> #(State(..state, redirect_to: Some("/")), effect.none())
      }
  }
}

// ---

fn view(state) {
  let State(redirect_to:, dashboard:, connection:) = state

  // Redirects client-side through a custom element
  let redirect_component = case redirect_to {
    Some(href) -> client_components.redirect(href)
    None -> html.text("")
  }

  // Changes document title through a custom element
  let title_component =
    client_components.document_title(case dashboard {
      None -> "Cargando… | Gastos"
      Some(Ok(dashboard_data)) -> dashboard_data.title <> " | Gastos"
      Some(Error(_)) -> "Error | Gastos"
    })

  html.main(
    [
      layout.column(),
      layout.center_x(),
      layout.center_y(),
      attribute.style([#("max-width", "700px"), #("margin", "0 auto")]),
    ],
    [
      title_component,
      redirect_component,
      case dashboard {
        None -> html.text("Cargando…")
        Some(Ok(Dashboard(first_person_name:, second_person_name:, title:, id:))) ->
          html.div([layout.column(), layout.spacing(40)], [
            html.h1([], [html.text(title)]),
            client_components.create_movement_form(
              first_person_name: first_person_name,
              second_person_name: second_person_name,
            ),
            view_movements(connection, id),
          ])
        Some(Error(DashboardNotFound)) ->
          html.text("El tablero solicitado no existe")
        Some(Error(_)) -> html.text("Error desconocido")
      },
    ],
  )
}

// --- view_movements

fn view_movements(connection: shork.Connection, dashboard_id: Id(DashboardT)) {
  let movements = movement.fetch(connection, dashboard_id)

  html.div([layout.column(), layout.fill_width()], [
    // TODO:
  ])
}
