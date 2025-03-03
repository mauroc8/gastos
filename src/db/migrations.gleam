import db/board
import shork

pub fn run(connection) {
  let query = board.create_table_query()

  shork.query(query)
  |> shork.execute(connection)
}
