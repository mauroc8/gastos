import gleam/int
import layout
import lustre/attribute
import lustre/element/html

pub fn document(title, body) {
  let meta_charset = html.meta([attribute.charset("UTF-8")])

  let lustre_ui_runtime =
    html.script(
      [attribute.type_("module"), attribute.src("/lustre-server-component.mjs")],
      "",
    )

  let script =
    html.script([attribute.type_("module"), attribute.src("/script.mjs")], "")

  let static_stylesheets = [
    html.link([attribute.rel("stylesheet"), attribute.href("/reset.css")]),
    html.link([attribute.rel("stylesheet"), attribute.href("/ui-kit.css")]),
    html.link([
      attribute.rel("stylesheet"),
      attribute.href(
        "https://fonts.googleapis.com/css2?family=Noto+Sans:ital,wght@0,100..900;1,100..900&display=swap",
      ),
    ]),
  ]

  let meta_viewport =
    html.meta([
      attribute.name("viewport"),
      attribute.content("width=device-width, initial-scale=1"),
    ])

  let title = html.title([], title)

  html.html([], [
    html.head([], [
      meta_charset,
      title,
      meta_viewport,
      lustre_ui_runtime,
      layout.static_styles(),
      script,
      ..static_stylesheets
    ]),
    html.body([], body),
  ])
}

pub fn max_width_wrapper(px, attributes, children) {
  html.div(
    [
      attribute.style([
        #("max-width", int.to_string(px) <> "px"),
        #("margin", "0 auto"),
      ]),
      ..attributes
    ],
    children,
  )
}

/// See https://github.com/lustre-labs/lustre/issues/224
/// Note: This may not work to switch from enabled to disabled, but
/// it works the other way around.
pub fn server_side_disabled(value) {
  case value {
    True -> attribute.attribute("disabled", "true")
    False -> attribute.none()
  }
}
