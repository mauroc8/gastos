import client_components
import css
import dashboard
import gleam/dynamic/decode
import gleam/int
import gleam/option.{type Option, None, Some}
import helpers/html_extra
import layout
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html.{html}
import lustre/event
import lustre/server_component
import shork
import ui_kit
import utils
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
    form_error: Option(String),
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
      form_error: None,
      is_submitting: False,
      connection:,
      redirect_to: None,
    ),
    effect.none(),
  )
}

// ---

pub opaque type Msg {
  BluredDashboardTitle(dashboard_title: String)
  BluredFirstPersonName(first_person_name: String)
  BluredSecondPersonName(second_person_name: String)
  SubmittedForm
}

fn update(state: State, msg: Msg) -> #(State, effect.Effect(Msg)) {
  case msg {
    BluredDashboardTitle(dashboard_title:) -> {
      #(State(..state, dashboard_title:, form_error: None), effect.none())
    }
    BluredFirstPersonName(first_person_name:) -> {
      #(State(..state, first_person_name:, form_error: None), effect.none())
    }
    BluredSecondPersonName(second_person_name:) -> {
      #(State(..state, second_person_name:, form_error: None), effect.none())
    }
    SubmittedForm -> {
      case
        state.dashboard_title,
        state.first_person_name,
        state.second_person_name
      {
        a, b, c if a == "" || b == "" || c == "" -> #(
          State(
            ..state,
            form_error: Some("Por favor, completá todos los campos"),
          ),
          effect.none(),
        )

        title, first_person_name, second_person_name -> {
          let res =
            dashboard.create(
              state.connection,
              dashboard.CreateDashboardParams(
                title:,
                first_person_name:,
                second_person_name:,
              ),
            )

          case res {
            Ok(id) -> #(
              State(..state, redirect_to: Some("/" <> uuid.to_string(id))),
              effect.none(),
            )

            Error(dashboard.InvalidTitle) -> #(
              State(..state, form_error: Some("El título no es válido")),
              effect.none(),
            )

            Error(_) -> #(
              State(..state, form_error: Some("Hubo un error")),
              effect.none(),
            )
          }
        }
      }
    }
  }
}

// ---

fn view(state: State) {
  let State(form_error:, is_submitting:, redirect_to:, ..) = state

  let input = fn(max, blur_msg) {
    ui_kit.input([
      layout.fill_width(),
      attribute.autocomplete("one-time-code"),
      attribute.max(int.to_string(max)),
      server_component.include(["target.value"]),
      attribute.on("blur", utils.target_value_decoder(decode.string, blur_msg)),
    ])
  }

  let title_input = input(50, BluredDashboardTitle)
  let first_person_name_input = input(40, BluredFirstPersonName)
  let second_person_name_input = input(40, BluredSecondPersonName)

  let error_message = case form_error {
    Some(error_message) ->
      html.div(
        [
          attribute.style([#("color", "darkred")]),
          attribute.attribute("role", "alert"),
        ],
        [html.text(error_message)],
      )

    None -> html.text("")
  }

  // Performs a client-side redirect through a custom element
  let redirect_element = case redirect_to {
    Some(href) -> client_components.redirect(href)
    None -> html.text("")
  }

  let field = fn(label, input) {
    html.label([layout.column(), layout.spacing(8)], [html.text(label), input])
  }

  html_extra.document("Crear tablero | Gastos", [
    html.div(
      [
        attribute.style([#("max-width", "700px"), #("margin", "0 auto")]),
        css.padding(16),
        layout.column(),
        layout.fill_height(),
        layout.center_y(),
        layout.spacing(16),
      ],
      [
        html.legend([css.semibold()], [html.text("Crear un tablero nuevo")]),
        field("Título del tablero", title_input),
        field("Tu nombre", first_person_name_input),
        field(
          "Nombre de la persona con la que compartís gastos",
          second_person_name_input,
        ),
        error_message,
        ui_kit.action_button(
          [
            event.on_click(SubmittedForm),
            html_extra.server_side_disabled(is_submitting),
          ],
          [html.text("Crear")],
        ),
      ],
    ),
    redirect_element,
  ])
}
