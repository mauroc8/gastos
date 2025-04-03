import counter
import dashboard
import gleam/erlang/process
import gleam/http/request.{type Request, Request}
import gleam/http/response.{type Response}
import gleam/io
import gleam/result
import gleam/string
import glexec as exec
import helpers/server
import home
import migrations
import mist.{type Connection, type ResponseData}
import shork

pub fn main() {
  // Start database connection
  let connection =
    shork.default_config()
    |> shork.user("root")
    |> shork.password("root")
    |> shork.database("gastos")
    |> shork.connect

  let assert Ok(_) = migrations.run(connection)

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        // Set up the websocket connection to the client. This is how we send
        // DOM updates to the browser and receive events from the client.
        ["counter"] -> server.define_server_component(req, counter.app, 0)

        ["home"] -> server.define_server_component(req, home.app, connection)

        ["dashboard"] ->
          server.define_server_component(req, dashboard.app, connection)

        // We need to serve the server component runtime.
        ["lustre-server-component.mjs"] -> {
          // If lustre@v4 is installed as a gleam package the correct way to do this is:
          // let assert Ok(priv) = erlang.priv_directory("lustre")
          // let path = priv <> "src/lustre/lustre-server-component.mjs"

          let path = "../common/src/lustre/lustre-server-component.mjs"

          server.serve_static_file(path, "application/javascript")
        }

        ["reset.css"] ->
          server.serve_static_file("../common/src/reset.css", "text/css")

        ["ui-kit.css"] ->
          server.serve_static_file("../common/src/ui-kit.css", "text/css")

        // Serves the client/ build, which includes client components declarations
        ["script.mjs"] -> {
          let assert Ok(bash) = exec.find_executable("bash")

          case
            exec.new()
            |> exec.with_stdin(exec.StdinPipe)
            |> exec.with_stdout(exec.StdoutCapture)
            |> exec.with_stderr(exec.StderrStdout)
            |> exec.with_monitor(True)
            |> exec.with_pty(True)
            |> exec.run_sync(
              exec.Execve([
                bash,
                "-c",
                "cd ../client && gleam run -m lustre/dev build app",
              ]),
            )
          {
            Ok(exec.Output([exec.Stdout(stdout)])) -> {
              io.println("")
              io.println("🐥 cd ../client && gleam run -m lustre/dev build app")
              io.println(string.join(stdout, "\n"))
            }
            _ -> io.println_error("🐣 Couldn't build script.mjs")
          }

          server.serve_static_file(
            "../client/priv/static/app.mjs",
            "application/javascript",
          )
        }

        [] -> server.serve_html(home.page())

        [id] -> server.serve_html(dashboard.page(id))

        _ -> server.redirect("")
      }
    }
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}
