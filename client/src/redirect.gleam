import gleam/dict
import gleam/dynamic
import lustre
import lustre/effect
import lustre/element/html

pub fn register() {
  lustre.component(init, update, view, update_attributes())
  |> lustre.register("redirect-to")
}

@external(javascript, "./index.mjs", "redirect")
fn client_side_redirect(href: String) -> Nil

fn init(_) {
  #(Nil, effect.none())
}

fn update(_state, href: String) {
  #(Nil, effect.from(fn(_) { client_side_redirect(href) }))
}

fn view(_) {
  html.text("")
}

fn update_attributes() -> dict.Dict(
  String,
  fn(dynamic.Dynamic) -> Result(String, List(dynamic.DecodeError)),
) {
  dict.from_list([#("href", dynamic.string)])
}
