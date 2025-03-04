import client_components/document_title
import client_components/redirect
import db/board
import gleam/dict
import gleam/dynamic
import gleam/option.{type Option, None, Some}
import helpers/html_extra
import lib/flexbox
import lustre
import lustre/attribute
import lustre/effect
import lustre/element
import lustre/element/html
import lustre/server_component
import shork
import youid/uuid

pub fn document(id: String) {
  html_extra.document("Cargando… | Gastos", [
    element.element(
      "lustre-server-component",
      [server_component.route("/board"), attribute.attribute("board-id", id)],
      [],
    ),
  ])
}

pub fn app() {
  lustre.component(init, update, view, on_attribute_change())
}

// ---

/// Receives the `uuid` via attributes
fn on_attribute_change() {
  dict.from_list([
    #("board-id", fn(dynamic) {
      case dynamic.string(dynamic) {
        Ok(string_id) -> Ok(GotUuid(string_id))
        Error(error) -> Error(error)
      }
    }),
  ])
}

// ---

pub opaque type State {
  State(
    connection: shork.Connection,
    redirect_to: Option(String),
    board: BoardStatus,
  )
}

fn init(connection) {
  #(State(connection:, redirect_to: None, board: LoadingBoard), effect.none())
}

type BoardStatus {
  LoadingBoard
  LoadBoardError(board.GetBoardError)
  LoadedBoard(board.Board)
}

// ---

pub opaque type Msg {
  GotUuid(id: String)
  ReceivedBoardResponse(result: Result(board.Board, board.GetBoardError))
}

fn update(state: State, msg: Msg) -> #(State, effect.Effect(Msg)) {
  case msg {
    GotUuid(id) ->
      case uuid.from_string(id) {
        Ok(id) -> #(state, fetch_board(state.connection, id))
        Error(_) -> #(State(..state, redirect_to: Some("/")), effect.none())
      }
    ReceivedBoardResponse(result) ->
      case result {
        Ok(board) -> #(State(..state, board: LoadedBoard(board)), effect.none())
        Error(board_load_error) -> #(
          State(..state, board: LoadBoardError(board_load_error)),
          effect.none(),
        )
      }
  }
}

fn fetch_board(connection, id) {
  effect.from(fn(dispatch) {
    dispatch(ReceivedBoardResponse(board.get_by_uuid(connection, id)))
  })
}

// ---

fn view(state) {
  let State(redirect_to:, board:, ..) = state

  let redirect_component = case redirect_to {
    Some(href) -> redirect.to(href)
    None -> html.text("")
  }

  let title_component =
    document_title.value(case board {
      LoadingBoard -> "Cargando… | Gastos"
      LoadedBoard(board_data) -> board_data.title <> " | Gastos"
      LoadBoardError(_) -> "Error | Gastos"
    })

  html.main(
    [
      flexbox.column(),
      flexbox.center_x(),
      flexbox.center_y(),
      attribute.style([#("max-width", "700px"), #("margin", "0 auto")]),
    ],
    [
      title_component,
      redirect_component,
      html.text(case board {
        LoadingBoard -> "Cargando…"
        LoadedBoard(board_data) -> board_data.title
        LoadBoardError(_) -> "Error"
      }),
    ],
  )
}
