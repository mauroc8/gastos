import lib/css
import lustre/attribute
import lustre/element/html

pub fn static_styles() {
  html.style(
    [],
    "
.row {
  display: flex;
  /* Note: I discourage the use of the default `align-items: stretch` because it violates component encapsulation principles */
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

.column.stretch-x { align-items: stretch; }
.row.stretch-x > *:not(.fixed-width) { flex-grow: 1; }

.column.stretch-y > *:not(.fixed-height) { flex-grow: 1; }
.row.stretch-y { align-items: stretch; }

.row > .fixed-width { flex-shrink: 0; }

.column > .fixed-height { flex-shrink: 0; }
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

/// The `gap` between children, in pixels.
pub fn spacing(px) {
  attribute.style([#("gap", css.px_to_string(px))])
}

/// The `gap` between children, expressed in pixels.
/// 
/// Its pixel value will be translated to `rem` units. Suitable for spacing that should scale
/// with font-size, for example spacing between paragraphs.
/// 
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

/// Stretches its children to fill all the available horizontal space.
/// 
/// Use carefully. This property can override the children's attributes. For example, a button
/// with `width: 50px;` could be ignoring its `width` attribute and rendering at `width: 100%`
/// if a parent column uses this property.
/// 
/// The main purpose of this function is to avoid being too repetitive with `fill_width`.
pub fn stretch_x() {
  attribute.class("stretch-x")
}

/// Stretches its children to fill all the available vertical space.
/// 
/// Use carefully. This property can override the children's attributes.
/// 
/// The main purpose of this function is to avoid being too repetitive with `fill_height`.
pub fn stretch_y() {
  attribute.class("stretch-y")
}

/// Ensures a fixed width in px.
/// 
/// Elements in flexbox layout don't always respect their `width` CSS property. They are
/// free to shrink if needed. Use this function to force a specific width.
///
/// In the following example, the use of `width()` also applies `flex-shrink: 0` to the element:
/// 
/// ```
/// html.div(
///   [layout.row(), layout.center_y(), layout.spacing(8)],
///   [
///     html.div([..width(24), ..height(24)], [contacts_icon]),
///     html.span([], [html.text("Contacts")])
///   ]
/// )
/// ```
pub fn width(px) {
  [
    attribute.class("fixed-width"),
    attribute.style([#("width", css.px_to_string(px))]),
  ]
}

/// Ensures a fixed height in px.
/// 
/// See comment in `width`.
pub fn height(px) {
  [
    attribute.class("fixed-height"),
    attribute.style([#("height", css.px_to_string(px))]),
  ]
}
