import lustre/attribute
import lustre/element

pub fn value(value: String) {
  element.element(
    "document-title",
    [attribute.attribute("document-value", value)],
    [],
  )
}
