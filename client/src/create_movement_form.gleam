import css
import gleam/dict
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import layout
import local_storage
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/event
import movement_kind
import person
import ui_kit
import utils

pub fn register() {
  lustre.component(init, update, view, update_attributes())
  |> lustre.register("create-movement-form")
}

type State {
  State(
    first_person_name: String,
    second_person_name: String,
    description: String,
    person: Option(person.Person),
    kind: Option(movement_kind.Kind),
    amount: String,
    date: String,
    installments: String,
  )
}

fn init(_) {
  #(
    State(
      first_person_name: "",
      second_person_name: "",
      description: "",
      person: None,
      kind: None,
      amount: "",
      date: "",
      installments: "",
    ),
    effect.none(),
  )
}

type Msg {
  UpdateFirstPersonName(String)
  UpdateSecondPersonName(String)
  SubmittedForm
  ChangedDescription(description: String)
  ChangedPerson(person: person.Person)
  ChangedKind(kind: movement_kind.Kind)
  ChangedAmount(amount: String)
  ChangedDate(date: String)
  ChangedInstallments(installments: String)
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

    ChangedDescription(description:) -> #(
      State(..state, description:),
      effect.none(),
    )

    ChangedPerson(person:) -> #(
      State(..state, person: Some(person)),
      effect.none(),
    )

    ChangedKind(kind:) -> #(State(..state, kind: Some(kind)), effect.none())

    ChangedAmount(amount:) -> #(State(..state, amount:), effect.none())

    ChangedDate(date:) -> #(State(..state, date:), effect.none())

    ChangedInstallments(installments:) -> #(
      State(..state, installments:),
      effect.none(),
    )

    NoOp -> #(state, effect.none())
  }
}

fn view(state) -> element.Element(Msg) {
  let State(
    first_person_name:,
    second_person_name:,
    description:,
    person:,
    kind:,
    amount:,
    date:,
    installments:,
  ) = state

  let description_field =
    html.label([layout.column(), layout.spacing(4), layout.fill_width()], [
      html.div([css.font_size(14)], [html.text("Descripción")]),
      ui_kit.input([
        layout.fill_width(),
        attribute.value(description),
        event.on(
          "blur",
          utils.target_value_decoder(decode.string, ChangedDescription),
        ),
      ]),
    ])

  let person_field =
    html.label([layout.column(), layout.spacing(8)], [
      html.div([ui_kit.visually_hidden()], [html.text("Persona")]),
      ui_kit.select(
        [
          event.on(
            "change",
            utils.target_value_decoder(person.decode(), ChangedPerson),
          ),
          ..local_storage.save_input_value(
            "selected_person",
            NoOp,
            option.map(person, person.to_string),
          )
        ],
        [
          html.option(
            [attribute.value(person.to_string(person.First))],
            first_person_name,
          ),
          html.option(
            [attribute.value(person.to_string(person.Second))],
            second_person_name,
          ),
        ],
      ),
    ])

  let kind_field =
    html.label([layout.column(), layout.spacing(8)], [
      html.div([ui_kit.visually_hidden()], [html.text("Tipo de movimiento")]),
      ui_kit.select(
        [
          event.on(
            "blur",
            utils.target_value_decoder(movement_kind.decode(), ChangedKind),
          ),
          attribute.value(
            kind |> option.map(movement_kind.to_string) |> option.unwrap(""),
          ),
        ],
        [
          html.option(
            [attribute.value(movement_kind.to_string(movement_kind.Expense))],
            "gastó",
          ),
          html.option(
            [
              attribute.value(movement_kind.to_string(movement_kind.GrantedLoan)),
            ],
            "tomó prestado",
          ),
        ],
      ),
    ])

  let amount_field =
    html.label(
      [layout.row(), layout.spacing(8), layout.baseline(), layout.fill_width()],
      [
        html.div([ui_kit.visually_hidden()], [html.text("Monto")]),
        html.div([], [html.text("$")]),
        ui_kit.input([
          layout.fill_width(),
          attribute.type_("number"),
          attribute.min("0"),
          attribute.required(True),
          attribute.style([#("width", css.px_as_rem(80))]),
          event.on_input(ChangedAmount),
          attribute.value(amount),
        ]),
      ],
    )

  let date_field =
    html.label([layout.row(), layout.spacing(8), layout.baseline()], [
      html.span([], [html.text("El día")]),
      ui_kit.input([
        attribute.placeholder("de hoy"),
        attribute.style([#("width", css.px_as_rem(90))]),
        event.on_input(ChangedDate),
        attribute.value(date),
      ]),
    ])

  let installments_field =
    html.label([layout.row(), layout.spacing(8), layout.baseline()], [
      html.span([], [html.text("pagado en")]),
      ui_kit.input([
        attribute.type_("number"),
        attribute.min("1"),
        attribute.placeholder("1"),
        attribute.style([#("width", css.px_as_rem(40))]),
        event.on_input(ChangedInstallments),
        attribute.value(installments),
      ]),
      html.span([], [html.text("cuota(s)")]),
    ])

  html.form(
    [
      layout.column(),
      layout.fill_width(),
      layout.spacing(16),
      event.on_submit(SubmittedForm),
      attribute.class("create-movement-form"),
    ],
    [
      description_field,
      html.div(
        [
          layout.row(),
          layout.baseline(),
          layout.spacing(12),
          layout.fill_width(),
          layout.wrap(),
        ],
        [person_field, kind_field, amount_field],
      ),
      html.div(
        [
          layout.row(),
          layout.baseline(),
          layout.spacing(12),
          attribute.style([#("font-size", css.px_as_rem(14))]),
        ],
        [date_field, installments_field],
      ),
      html.div([layout.fill_width(), layout.row(), layout.align_right()], [
        ui_kit.action_button([attribute.type_("submit")], [
          html.text("Crear movimiento"),
        ]),
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
