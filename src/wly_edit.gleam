import simplifile
import gleam/io
import gleam/list
import gleam/string.{inspect as ins}
import vxml_renderer as vr
import infrastructure.{type Desugarer} as infra
import vxml.{type VXML, V}
import desugarer_library as dl
import prefabricated_pipelines as pp

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
  vr.OutputFragment(
    blame.filename,
    vxml,
    classifier,
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

fn our_pipeline() -> List(Desugarer) {
  let #(opening, closing) = 
    infra.latex_display_delimiter_pairs_list()
    |> list.map(infra.opening_and_closing_string_for_pair)
    |> list.unzip

  [
    [
      dl.normalize_begin_end_align(#(infra.DoubleDollar, [infra.DoubleDollar])),
    ],
    pp.create_mathblock_elements([infra.DoubleDollar], infra.DoubleDollar),
    [
      dl.strip_delimiters_inside(#("MathBlock", opening, closing)),
      dl.unwrap("MathBlock"),
    ]
  ]
  |> list.flatten
}

pub fn entrypoint(amendments: vr.CommandLineAmendments) {
  let pipeline = our_pipeline()

  let renderer =
    vr.Renderer(
      assembler: vr.default_blamed_lines_assembler([]),
      source_parser: vr.default_writerly_source_parser([]),
      pipeline: pipeline,
      splitter: splitter,
      emitter: vr.stub_writerly_emitter,
      prettifier: vr.default_prettier_prettifier,
    )

  let parameters =
    vr.RendererParameters(
      input_dir: "./wly",
      output_dir: "./wly-edit",
      prettifier_on_by_default: False,
    )
    |> vr.amend_renderer_paramaters_by_command_line_amendment(amendments)

  let debug_options =
    vr.default_renderer_debug_options()
    |> vr.amend_renderer_debug_options_by_command_line_amendment(amendments, pipeline)

  let _ = simplifile.delete("./wly-edit/*")

  case vr.run_renderer(renderer, parameters, debug_options) {
    Error(error) -> io.println("\nrenderer error: " <> ins(error) <> "\n")
    _ -> Nil
  }
}