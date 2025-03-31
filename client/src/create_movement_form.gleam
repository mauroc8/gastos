import css
import gleam/dict
import gleam/dynamic
import gleam/json
import gleam/result
import layout
import local_storage
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event

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
  SubmittedForm
  NoOp
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

    SubmittedForm -> #(
      state,
      event.emit(
        "submit",
        // todo
        json.null(),
      ),
    )

    NoOp -> #(state, effect.none())
  }
}

fn view(state) -> element.Element(Msg) {
  let State(first_person_name:, second_person_name:) = state

  html.form(
    [
      layout.column(),
      layout.fill_width(),
      layout.spacing(16),
      event.on_submit(SubmittedForm),
      attribute.class("create-movement-form"),
    ],
    [
      static_styles(),
      html.legend([css.semibold()], [html.text("Crear movimiento")]),
      html.label([layout.column(), layout.spacing(4), layout.fill_width()], [
        html.div([css.font_size(14)], [html.text("Descripción")]),
        html.input([layout.fill_width()]),
      ]),
      html.div(
        [
          layout.row(),
          layout.baseline(),
          layout.spacing(12),
          layout.fill_width(),
          layout.wrap(),
        ],
        [
          html.label([layout.column(), layout.spacing(8)], [
            html.div([css.visually_hidden()], [html.text("Persona")]),
            html.select(
              local_storage.save_input_value("selected_person", NoOp),
              [
                html.option([attribute.value("0")], first_person_name),
                html.option([attribute.value("1")], second_person_name),
              ],
            ),
          ]),
          html.label([layout.column(), layout.spacing(8)], [
            html.div([css.visually_hidden()], [html.text("Tipo de movimiento")]),
            html.select([], [
              html.option([attribute.value("0")], "gastó"),
              html.option([attribute.value("1")], "tomó prestado"),
            ]),
          ]),
          html.label(
            [
              layout.row(),
              layout.spacing(8),
              layout.baseline(),
              layout.fill_width(),
            ],
            [
              html.div([css.visually_hidden()], [html.text("Monto")]),
              html.div([], [html.text("$")]),
              html.input([
                layout.fill_width(),
                attribute.type_("number"),
                attribute.min("0"),
                attribute.required(True),
                attribute.style([#("width", css.px_to_rem_string(80))]),
              ]),
            ],
          ),
        ],
      ),
      html.div(
        [
          layout.row(),
          layout.baseline(),
          layout.spacing(12),
          attribute.style([#("font-size", css.px_to_rem_string(14))]),
        ],
        [
          html.label([layout.row(), layout.spacing(8), layout.baseline()], [
            html.div([], [html.text("El día")]),
            html.input([
              attribute.placeholder("de hoy"),
              attribute.style([
                #("width", css.px_to_rem_string(90)),
                #("text-align", "center"),
              ]),
            ]),
          ]),
          html.label([layout.row(), layout.spacing(8), layout.baseline()], [
            html.div([], [html.text("pagado en")]),
            html.input([
              attribute.type_("number"),
              attribute.min("1"),
              attribute.placeholder("1"),
              attribute.style([
                #("width", css.px_to_rem_string(40)),
                #("text-align", "center"),
              ]),
            ]),
            html.span([], [html.text("cuota(s)")]),
          ]),
        ],
      ),
      html.div([layout.fill_width(), layout.row(), layout.align_right()], [
        html.button([attribute.type_("submit")], [html.text("Crear")]),
      ]),
    ],
  )
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

// --- Styles

fn focus_ring_implemented_with_border() {
  "&:focus {
      outline: 0;
      border-color: var(--blue, blue);
    }"
}

fn input_styles() {
  "& input {
    border-bottom: 2px solid var(--lightgray, lightgray);

    " <> focus_ring_implemented_with_border() <> "
  }"
}

fn select_styles() {
  "& select {
    padding: 6px 8px;
    border: 2px solid var(--lightgray, lightgray);
    border-radius: 8px;

    " <> focus_ring_implemented_with_border() <> "
  }"
}

fn submit_button_styles() {
  "& button[type='submit'] {
    background-color: var(--blue, blue);
    color: white;
    padding: 8px 12px;
    text-transform: uppercase;

    &:hover {
      background-color: var(--darkblue, darkblue);
    }

    &:focus-visible {
      outline: 2px solid var(--blue, blue);
      outline-offset: 2px;
    }
  }"
}

fn static_styles() {
  html.style([], ".create-movement-form {
  " <> input_styles() <> "

  " <> select_styles() <> "

  " <> submit_button_styles() <> "
}")
}
