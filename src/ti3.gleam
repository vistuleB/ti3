import argv
import gleam/io
import gleam/string
import gleam/dict
import infrastructure as infra
import formatter_renderer
import main_renderer
import vxml_renderer as vr

const ins = string.inspect

fn cli_usage_supplementary() {
  io.println("Format Writerly to Writerly")
  io.println("Make sure there exists wly-edit directory where formatted source will be saved")
  io.println("")
  io.println("gleam run -- --fmt")
}

pub fn main() {
  let args = argv.load().arguments

  case args {
    ["--help"] | ["-h"] -> {
      cli_usage_supplementary()
      vr.cli_usage()
    }

    _ -> {
      use amendments <- infra.on_error_on_ok(
        vr.process_command_line_arguments(args, ["--fmt"]),
        fn(error) {
          io.println("")
          io.println("command line error: " <> ins(error))
          io.println("")
          vr.cli_usage()
          cli_usage_supplementary()
        }
      )

      case dict.get(amendments.user_args, "--fmt") {
        Ok(_) -> {
          io.println("")
          io.println("wly -> wly formatter")
          formatter_renderer.formatter_renderer(amendments)
        }
        Error(_) -> {
          io.println("")
          io.println("wly -> html")
          main_renderer.main_renderer(amendments)
        }
      }
    }
  }
}
