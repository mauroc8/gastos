import client_components/redirect
import dashboard
import gleam/dynamic
import gleam/dynamic/decode
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
import shork
import youid/uuid

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

// ---

pub opaque type State {
  State(
    dashboard_title: String,
    first_person_name: String,
    second_person_name: String,
    dashboard_title_error: Option(String),
    is_submitting: Bool,
    connection: shork.Connection,
    redirect_to: Option(String),
  )
}

fn init(connection) {
  #(
    State(
      dashboard_title: "",
      first_person_name: "",
      second_person_name: "",
      dashboard_title_error: None,
      is_submitting: False,
      connection:,
      redirect_to: None,
    ),
    effect.none(),
  )
}

// ---

pub opaque type Msg {
  BluredDashboardName(value: String)
  Submitted
  CreateDashboardResponse(Result(uuid.Uuid, dashboard.CreateDashboardError))
}

fn update(state: State, msg: Msg) -> #(State, effect.Effect(Msg)) {
  case msg {
    BluredDashboardName(value) -> {
      #(
        State(..state, dashboard_title: value, dashboard_title_error: None),
        effect.none(),
      )
    }
    Submitted -> {
      case
        state.dashboard_title,
        state.first_person_name,
        state.second_person_name
      {
        a, b, c if a == "" || b == "" || c == "" -> #(
          State(..state, dashboard_title_error: Some("Campo requerido")),
          effect.none(),
        )

        title, first_person_name, second_person_name -> {
          #(
            State(..state, is_submitting: True),
            effect.from(fn(dispatch) {
              dispatch(
                CreateDashboardResponse(dashboard.create(
                  state.connection,
                  dashboard.CreateDashboardParams(
                    title:,
                    first_person_name:,
                    second_person_name:,
                  ),
                )),
              )
            }),
          )
        }
      }
    }
    CreateDashboardResponse(res) ->
      case res {
        Ok(id) -> #(
          State(..state, redirect_to: Some("/" <> { id |> uuid.to_string })),
          effect.none(),
        )

        Error(dashboard.InvalidTitle) -> #(
          State(..state, dashboard_title_error: Some("El título no es válido")),
          effect.none(),
        )

        Error(_) -> #(
          State(..state, dashboard_title_error: Some("Hubo un error")),
          effect.none(),
        )
      }
  }
}

// ---

fn view(state: State) {
  let State(dashboard_title_error:, is_submitting:, redirect_to:, ..) = state

  let error_message_id = "dasboard-name-input-error"

  let error_message_attrs = case dashboard_title_error {
    Some(_) -> [
      attribute.attribute("aria-invalid", "true"),
      attribute.attribute("aria-describedby", error_message_id),
    ]
    None -> []
  }

  let input =
    html.input([
      flexbox.fill_width(),
      attribute.value(""),
      attribute.autocomplete("one-time-code"),
      attribute.max("40"),
      server_component.include(["target.value"]),
      attribute.on("blur", blur_handler),
      ..error_message_attrs
    ])

  let error_message = case dashboard_title_error {
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
  }

  // Performs a client-side redirect through a custom element
  let redirect_element = case redirect_to {
    Some(href) -> redirect.to(href)
    None -> html.text("")
  }

  html_extra.document("Crear tablero | Gastos", [
    html.div(
      [
        attribute.style([#("max-width", "700px"), #("margin", "0 auto")]),
        css.padding(16),
        flexbox.column(),
        flexbox.fill_height(),
        flexbox.center_y(),
        flexbox.spacing(16),
      ],
      [
        html.legend([css.semibold()], [html.text("Crear un tablero nuevo")]),
        html.label([flexbox.column(), flexbox.spacing(8)], [
          html.text("Nombre del tablero"),
          input,
        ]),
        error_message,
        html.button(
          [
            event.on_click(Submitted),
            html_extra.server_side_disabled(is_submitting),
          ],
          [html.text("Crear")],
        ),
      ],
    ),
    redirect_element,
  ])
}

fn blur_handler(event) -> Result(Msg, List(dynamic.DecodeError)) {
  let decoder =
    decode.at(["target", "value"], decode.string)
    |> decode.map(BluredDashboardName)

  decode.run(event, decoder)
  |> html_extra.lustre_decoder_result
}
