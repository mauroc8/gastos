import dashboard
import movement
import shork

pub fn run(connection) {
  let query = dashboard.migrations() <> movement.migrations()

  let assert Ok(_) =
    shork.query(query)
    |> shork.execute(connection)
}
