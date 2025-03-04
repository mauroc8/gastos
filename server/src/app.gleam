import board_page
import counter
import db/migrations
import gleam/erlang/process
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response}
import helpers/server
import home_page
import mist.{type Connection, type ResponseData}
import shork
import youid/uuid

pub fn main() {
  // Start database connection
  let connection =
    shork.default_config()
    |> shork.user("root")
    |> shork.password("root")
    |> shork.database("gastos")
    |> shork.connect

  let _ = migrations.run(connection)

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        // Set up the websocket connection to the client. This is how we send
        // DOM updates to the browser and receive events from the client.
        ["counter"] -> server.define_server_component(req, counter.app, 0)

        ["home"] ->
          server.define_server_component(req, home_page.app, connection)

        // We need to serve the server component runtime.
        ["lustre-server-component.mjs"] -> {
          // If lustre@v4 is installed as a gleam package the correct way to do this is:
          // let assert Ok(priv) = erlang.priv_directory("lustre")
          // let path = priv <> "src/lustre/lustre-server-component.mjs"

          let path = "src/lustre/lustre-server-component.mjs"

          server.serve_static_file(path, "application/javascript")
        }

        ["styles.css"] -> server.serve_static_file("src/styles.css", "text/css")

        ["index.mjs"] ->
          server.serve_static_file(
            "../client/priv/static/app.mjs",
            "application/javascript",
          )

        [""] -> server.serve_html(home_page.page())

        [id] ->
          case uuid.from_string(id) {
            Ok(id) -> server.serve_html(board_page.document(connection, id))
            Error(_) -> server.serve_html(home_page.page())
          }

        _ -> {
          server.serve_html(home_page.page())
        }
      }
    }
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}
