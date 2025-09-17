import gleam/int
import simplifile
import gleam/io
import gleam/list
import gleam/dict
import gleam/string.{inspect as ins}
import desugaring as ds
import infrastructure as infra
import vxml.{type VXML, V}
import blame.{Src}
import formatter_pipeline.{formatter_pipeline}

const default_line_wrap_length = 70

type FragmentType {
  Root
  Chapter
  Sub
}

type FragmentOf(z) = 
  ds.OutputFragment(FragmentType, z)

fn fragment_bundler(
  vxml : VXML,
  classifier: FragmentType,
) -> FragmentOf(VXML) {
  let assert V(blame, _, _, _) = vxml
  let path = case blame {
    Src(_, path, _, _) -> path
    _ -> "unknown"
  }
  ds.OutputFragment(
    path: path,
    payload: vxml,
    classifier: classifier,
  )
}

fn splitter(
  root: VXML
) -> Result(List(FragmentOf(VXML)), String) {
  let #(root, chapters) = infra.v_extract_children(root, infra.is_v_and_tag_equals(_, "Chapter"))
  let root = fragment_bundler(root, Root)
  let #(chapters, subs) =
    chapters
    |> list.fold(
      #([], []),
      fn (acc, chapter) {
        let #(chapter, subs) = infra.v_extract_children(chapter, infra.is_v_and_tag_equals(_, "Sub"))
        let chapter = fragment_bundler(chapter, Chapter)
        let subs = list.map(
          subs,
          fragment_bundler(_, Sub)
        )
        #([chapter, ..acc.0], list.append(acc.1, subs))
      }
    )

  list.flatten([
    [root],
    chapters,
    subs,
  ])
  |> Ok
}

pub fn formatter_renderer(amendments: ds.CommandLineAmendments) -> Nil {
  let assert Ok(fmt_args) = dict.get(amendments.user_args, "--fmt")

  let cols = case fmt_args {
    [first, ..] -> case int.parse(first) {
      Ok(val) -> int.max(val, 40)
      Error(_) -> {
        io.println("\ncannot parse '" <> first <> "' as an integer value; reverting to default line length")
        default_line_wrap_length
      }
    }
    _ -> default_line_wrap_length
  }

  let pipeline = formatter_pipeline(cols)

  let renderer =
    ds.Renderer(
      assembler: ds.default_assembler(amendments.only_paths),
      parser: ds.default_writerly_parser(amendments.only_key_values),
      pipeline: pipeline,
      splitter: splitter,
      emitter: ds.default_writerly_emitter,
      writer: ds.default_writer,
      prettifier: ds.default_prettier_prettifier,
    )
    |> ds.amend_renderer_by_command_line_amendments(amendments)

  let parameters =
    ds.RendererParameters(
      input_dir: "./wly",
      output_dir: "./wly-edit",
      prettifier_behavior: ds.PrettifierOff,
      table: True,
    )
    |> ds.amend_renderer_paramaters_by_command_line_amendments(amendments)
  
  let debug_options =
    ds.default_renderer_debug_options()
    |> ds.amend_renderer_debug_options_by_command_line_amendments(amendments)

  let _ = simplifile.delete("./wly-edit/*")

  case ds.run_renderer(renderer, parameters, debug_options) {
    Error(error) -> io.println("\nrenderer error: " <> ins(error) <> "\n")
    _ -> Nil
  }
}
