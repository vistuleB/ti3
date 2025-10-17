import argv
import formatter_renderer
import gleam/dict
import gleam/io
import gleam/string
import main_renderer
import on
import desugaring as ds

const ins = string.inspect

fn cli_usage_supplementary() {
  io.println("Format Writerly to Writerly")
  io.println("Make sure there exists wly-edit directory where formatted source will be saved")
  io.println("")
  io.println("gleam run -- --fmt <cols>")
}

pub fn main() {
  let args = argv.load().arguments

  case args {
    ["--help"] | ["-h"] -> {
      cli_usage_supplementary()
      ds.basic_cli_usage()
    }

    _ -> {
      use amendments <-  on.error_ok(
        ds.process_command_line_arguments(args, ["--fmt"]),
        fn(error) {
          io.println("")
          io.println("cli error: " <> ins(error))
          ds.basic_cli_usage()
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
          io.println("wly -> html renderer")
          main_renderer.main_renderer(amendments)
        }
      }
    }
  }
}
