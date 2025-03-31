import gleam/dynamic
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/result
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

  let static_stylesheet =
    html.link([attribute.rel("stylesheet"), attribute.href("/styles.css")])

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
      static_stylesheet,
      layout.static_styles(),
      script,
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

/// Lustre uses `dynamic.DecodeError` that appears to be deprecated. This function makes the conversion
/// from `decode.DecodeError`
pub fn lustre_decoder_result(
  res: Result(a, List(decode.DecodeError)),
) -> Result(a, List(dynamic.DecodeError)) {
  res
  |> result.map_error(fn(decode_errors) {
    decode_errors
    |> list.map(fn(decode_error) {
      case decode_error {
        decode.DecodeError(a, b, c) -> dynamic.DecodeError(a, b, c)
      }
    })
  })
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
