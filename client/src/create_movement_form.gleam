import css
import gleam/dict
import gleam/dynamic
import gleam/result
import layout
import lustre
import lustre/attribute
import lustre/effect
import lustre/element/html

pub fn register() {
  lustre.component(init, update, view, update_attributes())
  |> lustre.register("create-movement-form")
}

type State {
  State(first_person_name: String, second_person_name: String)
}

fn init(_) {
  #(State(first_person_name: "", second_person_name: ""), effect.none())
}

type Msg {
  UpdateFirstPersonName(String)
  UpdateSecondPersonName(String)
}

fn update(state, msg: Msg) {
  case msg {
    UpdateFirstPersonName(first_person_name) -> #(
      State(..state, first_person_name:),
      effect.none(),
    )

    UpdateSecondPersonName(second_person_name) -> #(
      State(..state, second_person_name:),
      effect.none(),
    )
  }
}

fn view(state) {
  let State(first_person_name:, second_person_name:) = state

  html.fieldset([layout.column(), layout.fill_width(), layout.spacing(16)], [
    html.legend([], [html.text("Crear movimiento")]),
    html.div([layout.row(), layout.center_y(), layout.spacing(12)], [
      html.label([layout.column(), layout.spacing(8)], [
        html.div([css.visually_hidden()], [html.text("Persona")]),
        html.select([], [
          html.option([attribute.value("0")], first_person_name),
          html.option([attribute.value("1")], second_person_name),
        ]),
      ]),
      html.label([layout.column(), layout.spacing(8)], [
        html.div([css.visually_hidden()], [html.text("Tipo de movimiento")]),
        html.select([], [
          html.option([attribute.value("0")], "gastó"),
          html.option([attribute.value("1")], "tomó prestado"),
        ]),
      ]),
      html.label([layout.row(), layout.spacing(8), layout.center_y()], [
        html.div([css.visually_hidden()], [html.text("Monto")]),
        html.div([], [html.text("$")]),
        html.input([
          attribute.type_("number"),
          attribute.min("0"),
          attribute.required(True),
        ]),
      ]),
    ]),
    html.label([layout.row(), layout.spacing(8), layout.center_y()], [
      html.div([], [html.text("En concepto de")]),
      html.input([]),
    ]),
    html.div([layout.row(), layout.center_y(), layout.spacing(12)], [
      html.label([layout.row(), layout.spacing(8), layout.center_y()], [
        html.div([], [html.text("El día")]),
        html.input([attribute.placeholder("de hoy")]),
      ]),
      html.label([layout.row(), layout.spacing(8), layout.center_y()], [
        html.div([], [html.text("pagado en")]),
        html.input([
          attribute.type_("number"),
          attribute.min("1"),
          attribute.placeholder("1"),
        ]),
        html.span([], [html.text("cuota(s)")]),
      ]),
    ]),
    html.div([layout.fill_width(), layout.row(), layout.align_right()], [
      html.button([], [html.text("Crear")]),
    ]),
  ])
}

fn update_attributes() -> dict.Dict(
  String,
  fn(dynamic.Dynamic) -> Result(Msg, List(dynamic.DecodeError)),
) {
  dict.from_list([
    #("first_person_name", fn(value) {
      dynamic.string(value) |> result.map(UpdateFirstPersonName)
    }),
    #("second_person_name", fn(value) {
      dynamic.string(value) |> result.map(UpdateSecondPersonName)
    }),
  ])
}
