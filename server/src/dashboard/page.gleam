import client_components/document_title
import client_components/redirect
import dashboard/table.{type Dashboard}
import gleam/dict
import gleam/dynamic
import gleam/option.{type Option, None, Some}
import helpers/html_extra
import lib/flexbox
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/server_component
import shork
import youid/uuid

pub fn document(id: String) {
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

// ---

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
    dashboard: Option(Result(Dashboard, table.GetDashboardError)),
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
          let response = table.get_by_uuid(connection, id)

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
  let State(redirect_to:, dashboard:, ..) = state

  // Redirects client-side through a custom element
  let redirect_component = case redirect_to {
    Some(href) -> redirect.to(href)
    None -> html.text("")
  }

  // Changes document title through a custom element
  let title_component =
    document_title.value(case dashboard {
      None -> "Cargando… | Gastos"
      Some(Ok(dashboard_data)) -> dashboard_data.title <> " | Gastos"
      Some(Error(_)) -> "Error | Gastos"
    })

  html.main(
    [
      flexbox.column(),
      flexbox.center_x(),
      flexbox.center_y(),
      attribute.style([#("max-width", "700px"), #("margin", "0 auto")]),
    ],
    [
      title_component,
      redirect_component,
      html.text(case dashboard {
        None -> "Cargando…"
        Some(Ok(dashboard_data)) -> dashboard_data.title
        Some(Error(table.DashboardNotFound)) ->
          "El tablero solicitado no existe"
        Some(Error(_)) -> "Error desconocido"
      }),
    ],
  )
}
