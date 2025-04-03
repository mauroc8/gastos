import lustre/attribute
import lustre/element/html

pub fn visually_hidden() {
  attribute.class("visually-hidden")
}

pub fn input(attrs) {
  html.input([
    attribute.class("input focus-ring-implemented-with-border-color"),
    ..attrs
  ])
}

pub fn select(attrs, children) {
  html.select(
    [
      attribute.class("select focus-ring-implemented-with-border-color"),
      ..attrs
    ],
    children,
  )
}

pub fn action_button(attrs, children) {
  html.button([attribute.class("action-button"), ..attrs], children)
}
