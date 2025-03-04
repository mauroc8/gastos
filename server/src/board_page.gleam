import db/board
import gleam/io
import helpers/html_extra
import youid/uuid

pub fn document(connection, id: uuid.Uuid) {
  // TODO: fetch board inside a custom element
  case board.get_by_uuid(connection, id) {
    Ok(my_board) -> html_extra.document(my_board.title <> " | Gastos", [])
    Error(board.NotFound) -> html_extra.document("Not Found | Gastos", [])
    Error(board.GetBoardQueryError(query_error)) -> {
      io.debug(query_error)
      html_extra.document("Error interno | Gastos", [])
    }
  }
}
