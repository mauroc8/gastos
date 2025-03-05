import dashboard/table as dashboard_table
import shork

pub fn run(connection) {
  let query = dashboard_table.migrations()

  let assert Ok(_) =
    shork.query(query)
    |> shork.execute(connection)
}
