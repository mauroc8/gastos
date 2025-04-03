import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/result

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

pub fn target_value_decoder(
  decoder,
  msg,
) -> fn(dynamic.Dynamic) -> Result(msg, List(dynamic.DecodeError)) {
  fn(event) {
    let decoder =
      decode.at(["target", "value"], decoder)
      |> decode.map(msg)

    decode.run(event, decoder)
    |> lustre_decoder_result
  }
}
