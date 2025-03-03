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
  State
}

fn init(_) {
  #(State, effect.none())
}

pub opaque type Msg {
  OnSubmit
}

fn update(state, msg) -> #(State, effect.Effect(msg)) {
  todo
}

fn view(state) {
  let submit_handler = fn(event) {
    event.prevent_default(event)
    Ok(OnSubmit)
  }

  html_extra.document("Crear tablero | Gastos", [
    html_extra.max_width_wrapper(
      700,
      [
        css.padding(16),
        flexbox.column(),
        flexbox.fill_height(),
        flexbox.center_x(),
        flexbox.center_y(),
      ],
      [
        html.form(
          [
            flexbox.column(),
            flexbox.spacing(16),
            attribute.on("submit", submit_handler),
          ],
          [
            html.legend([css.semibold()], [html.text("Crear un tablero nuevo")]),
            html.label([flexbox.column(), flexbox.spacing(8)], [
              html.text("Nombre del tablero"),
              html.input([attribute.id("board-name"), attribute.max("40")]),
            ]),
            html.button([attribute.type_("submit")], [html.text("Crear")]),
          ],
        ),
      ],
    ),
  ])
}
