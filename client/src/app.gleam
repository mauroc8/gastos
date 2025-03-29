import create_movement_form
import document_title
import redirect

pub fn main() {
  let _ = redirect.register()
  let _ = document_title.register()
  let _ = create_movement_form.register()

  Nil
}
