import gleam/int
import lib/flexbox
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
    html.script([attribute.type_("module"), attribute.src("/index.mjs")], "")

  let static_stylesheet =
    html.link([attribute.rel("stylesheet"), attribute.href("/styles.css")])

  let title = html.title([], title)

  html.html([], [
    html.head([], [
      meta_charset,
      title,
      lustre_ui_runtime,
      static_stylesheet,
      flexbox.static_styles(),
      script,
    ]),
    html.body(
      [attribute.style([#("width", "100%"), #("height", "100%")])],
      body,
    ),
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
