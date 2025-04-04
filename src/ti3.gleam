import gleam/io
import gleam/list
import gleam/option.{Some}
import argv
import prefabricated_pipelines as pp
import infrastructure.{type Pipe}
import vxml_renderer as vr
import gleam/string.{inspect as ins}
import infrastructure as infra
import desugarer_names as dn
import writerly_parser as wp

fn our_pipeline() -> List(Pipe) {
  [
    pp.normalize_begin_end_align(pp.DoubleDollar),
    pp.create_mathblock_and_math_elements(
      [pp.DoubleDollar],
      [pp.BackslashParenthesis],
      pp.DoubleDollar,
      pp.SingleDollar,
    ),
    [
      dn.find_replace(#([#("\\$", "$")], ["Math", "MathBlock"])),
      dn.fold_tag_contents_into_text(["MathBlock", "Math"]),
      dn.group_consecutive_children_avoiding(
        #(
          "VerticalChunk",
          [
            "CentralDisplay", "CentralDisplayItalic", "Chapter", "ChapterTitle",
            "Example", "Exercise", "Exercises", "Grid", "Image", "ImageLeft",
            "ImageRight", "List", "MathBlock", "Note", "Pause", "Section",
            "Solution", "SolutionNote", "StarDivider", "Table", "TextParent",
            "WriterlyBlankLine", "center", "li", "ul", "ol", "table", "colgroup",
            "thead", "tbody", "tr", "td", "section",
          ],
          ["MathBlock", "VerticalChunk"],
        ),
      ),
      dn.unwrap_tags(["WriterlyBlankLine"]),
      dn.remove_empty_text_nodes(),
      dn.rename_when_child_of([#("VerticalChunk", "h1", "ChapterTitle")]),
      dn.rename_tag(#("VerticalChunk", "p")),
      dn.rename_with_attributes([
        #("ChapterTitle", "div", [#("class", "chapter-title")]),
        #("Chapter", "div", [#("class", "chapter")]),
        #("Sub", "div", [#("class", "subchapter")]),
      ]),
    ],
  ]
  |> list.flatten
}

fn cli_usage_supplementary() {
  io.println("      --prettier")
  io.println("         -> run npm prettier on emitted content")
}

pub fn main() {
  let args = argv.load().arguments

  use amendments <- infra.on_error_on_ok(
    vr.process_command_line_arguments(args, ["--prettier"]),
    fn(error) {
      io.println("")
      io.println("command line error: " <> ins(error))
      io.println("")
      vr.cli_usage()
      cli_usage_supplementary()
    },
  )

  let renderer =
    vr.Renderer(
      assembler: wp.assemble_blamed_lines_advanced_mode(_, amendments.spotlight_args_files),
      source_parser: vr.default_writerly_source_parser(_, amendments.spotlight_args),
      pipeline: our_pipeline(),
      splitter: vr.empty_splitter(_, ".html"),
      emitter: vr.stub_html_emitter,
      prettifier: vr.guarded_prettier_prettifier(amendments.user_args),
    )

  let parameters =
    vr.RendererParameters(
      input_dir: "./emu_content",
      output_dir: Some("./public"),
    )
    |> vr.amend_renderer_paramaters_by_command_line_amendment(amendments)

  let debug_options =
    vr.empty_renderer_debug_options("../renderer_artifacts")
    |> vr.amend_renderer_debug_options_by_command_line_amendment(amendments, our_pipeline())

  case vr.run_renderer(renderer, parameters, debug_options) {
    Error(error) -> io.println("\nrenderer error: " <> ins(error) <> "\n")
    _ -> Nil
  }
}
