import gleam/bytes_tree
import gleam/erlang/process.{type Selector, type Subject}
import gleam/http/request.{type Request, Request}
import gleam/http/response
import gleam/io
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/otp/actor
import gleam/result
import lustre
import lustre/element
import lustre/server_component
import mist.{type Connection, type WebsocketConnection, type WebsocketMessage}

pub fn redirect(path) {
  response.new(302)
  |> response.prepend_header("Location", path)
  |> response.set_body(mist.Bytes(bytes_tree.new()))
}

pub fn serve_static_file(path, mime_type) {
  mist.send_file(path, offset: 0, limit: None)
  |> result.map(fn(contents) {
    response.new(200)
    |> response.prepend_header("content-type", mime_type)
    |> response.set_body(contents)
  })
  |> result.lazy_unwrap(fn() {
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_tree.new()))
  })
}

pub fn serve_html(document) {
  response.new(200)
  |> response.prepend_header("content-type", "text/html")
  |> response.set_body(
    document
    |> element.to_document_string_builder
    |> bytes_tree.from_string_tree
    |> mist.Bytes,
  )
}

// ---

pub fn define_server_component(
  req: Request(Connection),
  app: fn() -> lustre.App(flags, model, msg),
  flags: flags,
) {
  mist.websocket(
    request: req,
    on_init: fn(_) { socket_init(app, flags) },
    on_close: socket_close,
    handler: socket_update,
  )
}

type Component(msg) =
  Subject(lustre.Action(msg, lustre.ServerComponent))

fn socket_init(
  app,
  flags,
) -> #(Component(msg), Option(Selector(lustre.Patch(msg)))) {
  let self = process.new_subject()
  let app_instance = app()
  let assert Ok(component) = lustre.start_actor(app_instance, flags)

  process.send(
    component,
    server_component.subscribe(
      // server components can have many connected clients, so we need a way to
      // identify this client.
      "ws",
      // this callback is called whenever the server component has a new patch
      // to send to the client. here we json encode that patch and send it to
      // via the websocket connection.
      //
      // a more involved version would have us sending the patch to this socket's
      // subject, and then it could be handled (perhaps with some other work) in
      // the `mist.Custom` branch of `socket_update` below.
      process.send(self, _),
    ),
  )

  #(
    // we store the server component's `Subject` as this socket's state so we
    // can shut it down when the socket is closed.
    component,
    Some(process.selecting(process.new_selector(), self, fn(a) { a })),
  )
}

fn socket_update(
  component: Component(msg),
  conn: WebsocketConnection,
  msg: WebsocketMessage(lustre.Patch(msg)),
) {
  case msg {
    mist.Text(json) -> {
      // we attempt to decode the incoming text as an action to send to our
      // server component runtime.
      let action = json.decode(json, server_component.decode_action)

      case action {
        Ok(action) -> process.send(component, action)
        Error(_) -> Nil
      }

      actor.continue(component)
    }

    mist.Binary(_) -> actor.continue(component)
    mist.Custom(patch) -> {
      case
        patch
        |> server_component.encode_patch
        |> json.to_string
        |> mist.send_text_frame(conn, _)
      {
        Ok(_) -> Nil
        Error(err) -> {
          io.print("Error en socket_update: ")
          io.debug(err)
          Nil
        }
      }

      actor.continue(component)
    }
    mist.Closed | mist.Shutdown -> actor.Stop(process.Normal)
  }
}

fn socket_close(component: Component(msg)) {
  process.send(component, lustre.shutdown())
}
