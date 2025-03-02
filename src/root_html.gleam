import lustre/attribute
import lustre/element.{element}
import lustre/element/html.{html}
import lustre/server_component

pub fn root_html() {
  html([], [
    html.head([], [
      // Lustre UI static stylesheet
      html.link([attribute.rel("stylesheet"), attribute.href("/lustre_ui.css")]),
      html.script(
        [
          attribute.type_("module"),
          attribute.src("/lustre-server-component.mjs"),
        ],
        "",
      ),
    ]),
    html.body([], [
      element("lustre-server-component", [server_component.route("/counter")], [
        html.p([], [html.text("This is a slot")]),
      ]),
    ]),
  ])
}
