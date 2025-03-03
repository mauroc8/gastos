import gleam/int
import lustre
import lustre/attribute
import lustre/element.{type Element, element}
import lustre/element/html
import lustre/event
import lustre/server_component

pub fn component(children) {
  element(
    "lustre-server-component",
    [server_component.route("/counter")],
    children,
  )
}

// MAIN ------------------------------------------------------------------------

pub fn app() {
  lustre.simple(init, update, view)
}

// MODEL -----------------------------------------------------------------------

type Model =
  Int

fn init(initial_count: Int) -> Model {
  case initial_count < 0 {
    True -> 0
    False -> initial_count
  }
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  Incr
  Decr
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    Incr -> model + 1
    Decr -> model - 1
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]
  let count = int.to_string(model)

  html.div([attribute.style(styles)], [
    html.div([], [
      html.button([event.on_click(Incr)], [element.text("+")]),
      html.slot([]),
      html.p([attribute.style([#("text-align", "center")])], [
        element.text(count),
      ]),
      html.button([event.on_click(Decr)], [element.text("-")]),
    ]),
  ])
}
