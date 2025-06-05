import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/string.{inspect as ins}
import argv
import blamedlines.{type Blame, type BlamedLine, Blame, BlamedLine}
import vxml.{type VXML}
import vxml_renderer as vr
import prefabricated_pipelines as pp
import infrastructure.{type Pipe} as infra
import desugarer_names as dn
import writerly as wp

fn our_pipeline() -> List(Pipe) {
  [
    pp.normalize_begin_end_align(infra.DoubleDollar),
    pp.create_mathblock_and_math_elements(
      #([infra.DoubleDollar], infra.DoubleDollar),
      #([infra.BackslashParenthesis], infra.SingleDollar),
    ),
    pp.symmetric_delim_splitting("_", "_", "i", ["MathBlock", "Math"]),
    pp.symmetric_delim_splitting("\\*", "*", "b", ["MathBlock", "Math"]),
    pp.symmetric_delim_splitting("`", "`", "code", ["MathBlock", "Math"]),
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
            "Sub", "Definition",
            "thead", "tbody", "tr", "td", "section",
          ],
          ["MathBlock", "VerticalChunk"],
        ),
      ),
      dn.unwrap(["WriterlyBlankLine"]),
      dn.remove_empty_text_nodes(),
      dn.unwrap_when_child_of([#("VerticalChunk", ["ChapterTitle"])]),
      dn.rename(#("VerticalChunk", "p")),
      dn.rename_with_attributes([
        #("ChapterTitle", "div", [#("class", "chapter-title")]),
        #("Chapter", "div", [#("class", "chapter")]),
        #("Sub", "div", [#("class", "subchapter")]),
        #("Definition", "div", [#("class", "definition")]),
      ]),
    ],
  ]
  |> list.flatten
}

pub fn our_emitter(
  tuple: #(String, VXML, a),
) -> Result(#(String, List(BlamedLine), a), b) {
  let #(path, fragment, fragment_type) = tuple
  let blame_us = fn(msg: String) -> Blame { Blame(msg, 0, 0, []) }
  let lines =
    list.flatten([
      [
        BlamedLine(blame_us("ti3_emitter"), 0, "<!DOCTYPE html>"),
        BlamedLine(blame_us("ti3_emitter"), 0, "<html>"),
        BlamedLine(blame_us("ti3_emitter"), 0, "<head>"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<meta charset=\"utf-8\">"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"ti3.css\" />"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<script type=\"text/javascript\" id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>"),
        BlamedLine(blame_us("ti3_emitter"), 0, "</head>"),
        BlamedLine(blame_us("ti3_emitter"), 0, "<body>"),
      ],
      fragment
        |> infra.get_children
        |> list.map(fn(vxml) { vxml.vxml_to_html_blamed_lines(vxml, 2, 2) })
        |> list.flatten,
      [
        BlamedLine(blame_us("ti3_emitter"), 0, "</body>"),
        BlamedLine(blame_us("ti3_emitter"), 0, ""),
      ],
    ])
  Ok(#(path, lines, fragment_type))
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
      emitter: our_emitter,
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
