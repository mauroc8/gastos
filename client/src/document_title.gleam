import gleam/dict
import gleam/dynamic
import lustre
import lustre/effect
import lustre/element/html

pub fn register() {
  lustre.component(init, update, view, update_attributes())
  |> lustre.register("document-title")
}

@external(javascript, "./index.mjs", "setDocumentTitle")
fn set_document_title(value: String) -> Nil

fn init(_) {
  #(Nil, effect.none())
}

fn update(_state, href: String) {
  #(Nil, effect.from(fn(_) { set_document_title(href) }))
}

fn view(_) {
  html.text("")
}

fn update_attributes() -> dict.Dict(
  String,
  fn(dynamic.Dynamic) -> Result(String, List(dynamic.DecodeError)),
) {
  dict.from_list([#("document-value", dynamic.string)])
}
