import lustre/attribute
import lustre/element

pub fn to(href: String) {
  element.element("redirect-to", [attribute.attribute("href", href)], [])
}
