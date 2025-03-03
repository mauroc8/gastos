import gleam/int
import lib/css
import lustre/attribute
import lustre/element/html

pub fn static_styles() {
  html.style(
    [],
    "
.row {
  display: flex;
  /* I don't like the default `align-items: stretch` because it violates component encapsulation principles */
  align-items: flex-start;
}

.column {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
}

.column.align-left { justify-content: flex-start; }
.row.align-left { align-items: flex-start; }

.column.align-right { justify-content: flex-end; }
.row.align-right { align-items: flex-end; }

.column.align-top { align-items: flex-start; }
.row.align-top { justify-content: flex-start; }

.column.align-bottom { align-items: flex-end; }
.row.align-bottom { justify-content: flex-end; }

.column.center-x { align-items: center; }
.row.center-x { justify-content: center; }

.column.center-y { justify-content: center; }
.row.center-y { align-items: center; }

.row > .fill-width { flex-grow: 1; }
:not(.row) > .fill-width { width: 100% }

.column > .fill-height { flex-grow: 1; }
:not(.column) > .fill-height { height: 100% }

    ",
  )
}

pub fn row() {
  attribute.class("row")
}

pub fn column() {
  attribute.class("column")
}

pub fn align_left() {
  attribute.class("align-left")
}

pub fn align_right() {
  attribute.class("align-right")
}

pub fn align_top() {
  attribute.class("align-top")
}

pub fn align_bottom() {
  attribute.class("align-bottom")
}

/// Centers children horizontally (in the x axis)
pub fn center_x() {
  attribute.class("center-x")
}

/// Centers children vertically (in the y axis)
pub fn center_y() {
  attribute.class("center-y")
}

pub fn space_between() {
  attribute.style([#("justify-content", "space-between")])
}

/// The `gap`
pub fn spacing(px) {
  attribute.style([#("gap", css.px_to_string(px))])
}

/// The `gap`. Its pixel value will be translated to `rem` units.
/// Suitable for spacing that scales with font-size, for example spacing
/// between paragraphs.
pub fn text_spacing(px) {
  attribute.style([#("gap", css.px_to_rem_string(px))])
}

pub fn wrap() {
  attribute.style([#("flex-wrap", "wrap")])
}

/// Fills the available horizontal space (either with `flex-grow: 1` or with `width: 100%`)
pub fn fill_width() {
  attribute.class("fill-width")
}

/// Fills the available vertical space (either with `flex-grow: 1` or with `height: 100%`)
pub fn fill_height() {
  attribute.class("fill-height")
}
