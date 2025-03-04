import gleam/float
import gleam/int
import lustre/attribute

pub fn px_to_string(value) {
  int.to_string(value) <> "px"
}

pub fn px_to_rem_string(px) {
  float.to_string(int.to_float(px) /. 16.0) <> "rem"
}

pub fn padding(px) {
  attribute.style([#("padding", px_to_string(px))])
}

pub fn padding_xy(x_px, y_px) {
  attribute.style([
    #("padding", px_to_string(y_px) <> " " <> px_to_string(x_px)),
  ])
}

pub fn font_size(px) {
  attribute.style([#("font-size", px_to_rem_string(px))])
}

pub fn line_height(px) {
  attribute.style([#("line-height", px_to_rem_string(px))])
}

pub fn semibold() {
  attribute.style([#("font-weight", "600")])
}
