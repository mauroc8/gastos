import gleam/option
import lustre/attribute
import lustre/event

pub fn save_input_value(key: String, nil: msg, value: option.Option(String)) {
  let value = value |> option.unwrap(local_storage_get_string(key))

  let change_handler = fn(value) {
    local_storage_set_string(key, value)
    nil
  }

  [
    case value {
      "" -> attribute.class("")
      _ -> attribute.value(value)
    },
    event.on_input(change_handler),
  ]
}

@external(javascript, "./index.mjs", "localStorageGetString")
fn local_storage_get_string(key: String) -> String

@external(javascript, "./index.mjs", "localStorageSetString")
fn local_storage_set_string(key: String, value: String) -> Nil
