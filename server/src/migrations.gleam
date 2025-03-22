import dashboard
import gleam/result
import movement
import shork

pub fn run(connection) {
  result.all([
    shork.query(dashboard.migrations())
      |> shork.execute(connection),
    shork.query(movement.migrations())
      |> shork.execute(connection),
  ])
}
