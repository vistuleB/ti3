import simplifile
import gleam/io
import gleam/list
import gleam/string.{inspect as ins}
import vxml_renderer as vr
import infrastructure as infra
import vxml.{type VXML, V}
import blamedlines.{Src}
import formatter_pipeline.{formatter_pipeline}

type FragmentType {
  Root
  Chapter
  Sub
}

type FragmentOf(z) = 
  vr.OutputFragment(FragmentType, z)

fn fragment_bundler(
  vxml : VXML,
  classifier: FragmentType,
) -> FragmentOf(VXML) {
  let assert V(blame, _, _, _) = vxml
  let path = case blame {
    Src(_, path, _, _) -> path
    _ -> "unknown"
  }
  vr.OutputFragment(
    path: path,
    payload: vxml,
    classifier: classifier,
  )
}

fn splitter(
  root: VXML
) -> Result(List(FragmentOf(VXML)), String) {
  let #(root, chapters) = infra.extract_children(root, infra.is_v_and_tag_equals(_, "Chapter"))
  let root = fragment_bundler(root, Root)
  let #(chapters, subs) =
    chapters
    |> list.fold(
      #([], []),
      fn (acc, chapter) {
        let #(chapter, subs) = infra.extract_children(chapter, infra.is_v_and_tag_equals(_, "Sub"))
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

pub fn formatter_renderer(amendments: vr.CommandLineAmendments) -> Nil {
  let pipeline = formatter_pipeline()

  let renderer =
    vr.Renderer(
      assembler: vr.default_input_lines_assembler(amendments.spotlight_paths),
      source_parser: vr.default_writerly_source_parser(amendments.spotlight_key_values),
      pipeline: pipeline,
      splitter: splitter,
      emitter: vr.stub_writerly_emitter,
      prettifier: vr.default_prettier_prettifier,
    )
    |> vr.amend_renderer_by_command_line_amendments(amendments)

  let parameters =
    vr.RendererParameters(
      input_dir: "./wly",
      output_dir: "./wly-edit",
      prettifier_behavior: vr.PrettifierOff
      
    )
    |> vr.amend_renderer_paramaters_by_command_line_amendments(amendments)
  
  let debug_options =
    vr.default_renderer_debug_options()
    |> vr.amend_renderer_debug_options_by_command_line_amendments(amendments)

  let _ = simplifile.delete("./wly-edit/*")

  case vr.run_renderer(renderer, parameters, debug_options) {
    Error(error) -> io.println("\nrenderer error: " <> ins(error) <> "\n")
    _ -> Nil
  }
}
