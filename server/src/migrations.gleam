import dashboard
import movement
import shork

pub fn run(connection) {
  let assert Ok(_) =
    shork.query(dashboard.migrations())
    |> shork.execute(connection)

  let assert Ok(_) =
    shork.query(movement.migrations())
    |> shork.execute(connection)
}
