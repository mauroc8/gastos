import gleam/bool
import gleam/dynamic
import gleam/dynamic/decode
import gleam/io
import gleam/option.{type Option, None, Some}
import helpers/html_extra
import lib/css
import lib/flexbox
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html.{html}
import lustre/event
import lustre/server_component

pub fn page() {
  html_extra.document("Gastos", [
    element.element(
      "lustre-server-component",
      [server_component.route("/home")],
      [],
    ),
  ])
}

pub fn app() {
  lustre.application(init, update, view)
}

pub opaque type State {
  State(dashboard_name: String, dashboard_name_error: Option(String))
}

fn init(_) {
  #(State(dashboard_name: "", dashboard_name_error: None), effect.none())
}

pub opaque type Msg {
  BluredDashboardName(value: String)
  Submitted
}

fn update(state, msg) -> #(State, effect.Effect(msg)) {
  case msg {
    BluredDashboardName(value) -> {
      #(State(..state, dashboard_name: value), effect.none())
    }
    Submitted -> {
      case state.dashboard_name {
        "" -> #(
          State(..state, dashboard_name_error: Some("Campo requerido")),
          effect.none(),
        )

        _ -> #(state, effect.none())
      }
    }
  }
}

fn blur_handler(event) -> Result(Msg, List(dynamic.DecodeError)) {
  let decoder =
    decode.at(["target", "value"], decode.string)
    |> decode.map(BluredDashboardName)

  decode.run(event, decoder)
  |> html_extra.lustre_decoder_result
}

fn view(state: State) {
  let State(dashboard_name_error: dashboard_name_error, ..) = state

  let error_message_id = "dasboard-name-input-error"

  html_extra.document("Crear tablero | Gastos", [
    html.div(
      [
        attribute.style([#("max-width", "700px"), #("margin", "0 auto")]),
        attribute.style([#("padding", "16px")]),
        flexbox.column(),
        flexbox.stretch_children(),
        flexbox.fill_height(),
        flexbox.center_y(),
        flexbox.spacing(16),
      ],
      [
        html.legend([css.semibold()], [html.text("Crear un tablero nuevo")]),
        html.label([flexbox.column(), flexbox.spacing(8)], [
          html.text("Nombre del tablero"),
          html.input([
            attribute.value(""),
            attribute.autocomplete("one-time-code"),
            flexbox.fill_width(),
            attribute.max("40"),
            server_component.include(["target.value"]),
            attribute.on("blur", blur_handler),
            ..{
              case dashboard_name_error {
                Some(_) -> [
                  attribute.attribute("aria-invalid", "true"),
                  attribute.attribute("aria-describedby", error_message_id),
                ]
                None -> []
              }
            }
          ]),
        ]),
        case dashboard_name_error {
          Some(error_message) ->
            html.div(
              [
                attribute.id(error_message_id),
                attribute.style([#("color", "darkred")]),
                attribute.attribute("role", "alert"),
              ],
              [html.text(error_message)],
            )

          None -> html.text("")
        },
        html.button([event.on_click(Submitted)], [html.text("Crear")]),
      ],
    ),
  ])
}
