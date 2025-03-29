import lustre/attribute
import lustre/element

pub fn document_title(value: String) {
  element.element(
    "document-title",
    [attribute.attribute("document-value", value)],
    [],
  )
}

pub fn redirect(href: String) {
  element.element("redirect-to", [attribute.attribute("href", href)], [])
}

pub fn create_movement_form(
  first_person_name first_person_name: String,
  second_person_name second_person_name: String,
) {
  element.element(
    "create-movement-form",
    [
      attribute.attribute("first_person_name", first_person_name),
      attribute.attribute("second_person_name", second_person_name),
    ],
    [],
  )
}
