import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/string.{inspect as ins}
import argv
import blamedlines.{type Blame, type BlamedLine, Blame, BlamedLine}
import vxml.{type VXML, V}
import vxml_renderer as vr
import prefabricated_pipelines as pp
import infrastructure.{type Pipe} as infra
import gleam/result
import desugarer_names as dn
import writerly as wp

pub type FragmentType {
  Chapter(Int)
  Sub(Int, Int)  // Sub(chapter_number, sub_number)
  Index
}

pub type TI3SplitterError {
  NoChapters
  MoreThanOneIndex
  NoIndex
}

fn blame_us(message: String) -> Blame {
  Blame(message, 0, 0, [])
}

fn index_error(e: infra.SingletonError) -> TI3SplitterError {
  case e {
    infra.MoreThanOne -> MoreThanOneIndex
    infra.LessThanOne -> NoIndex
  }
}

fn ensure_non_empty_chapters(chapters: List(VXML)) -> Result(List(VXML), TI3SplitterError) {
  case chapters {
    [] -> Error(NoChapters)
    _ -> Ok(chapters)
  }
}

// Index splitter - handles Index fragments
fn index_splitter(
  root: VXML,
) -> Result(List(#(String, VXML, FragmentType)), TI3SplitterError) {
  root
  |> infra.descendants_with_class("index")
  |> infra.read_singleton
  |> result.map_error(index_error)
  |> result.map(fn(index) { #("index.html", index, Index) })
  |> result.map(fn(fragment) { [fragment] })
}

// Chapter splitter - handles Chapter fragments without sub-chapters
fn chapter_splitter(
  root: VXML,
) -> Result(List(#(String, VXML, FragmentType)), TI3SplitterError) {
  root
  |> infra.descendants_with_class("chapter")
  |> ensure_non_empty_chapters
  |> result.map(list.index_map(_, fn(chapter, chapter_index) {
    let chapter_number = chapter_index + 1
    let #(chapter_without_subs, _) = infra.excise_children(chapter, infra.has_class(_, "subchapter"))
    #(
      "ch" <> string.inspect(chapter_number) <> ".html",
      chapter_without_subs,
      Chapter(chapter_number)
    )
  }))
}

// Sub-chapter splitter - handles Sub fragments
fn sub_chapter_splitter(
  root: VXML,
) -> Result(List(#(String, VXML, FragmentType)), TI3SplitterError) {
  root
  |> infra.descendants_with_class("chapter")
  |> ensure_non_empty_chapters
  |> result.map(list.index_map(_, fn(chapter, chapter_index) {
    let chapter_number = chapter_index + 1
    chapter
    |> infra.descendants_with_class("subchapter")
    |> list.index_map(fn(sub, sub_index) {
      let sub_number = sub_index + 1
      #(
        "ch" <> string.inspect(chapter_number) <> "-" <> string.inspect(sub_number) <> ".html",
        sub,
        Sub(chapter_number, sub_number)
      )
    })
  }))
  |> result.map(list.flatten)
}

// Main splitter that combines all sub-splitters
fn ti3_splitter(
  root: VXML,
) -> Result(List(#(String, VXML, FragmentType)), TI3SplitterError) {
  let assert V(_, "Document", _, _) = root

  // Get fragments from each splitter
  use index_fragments <- infra.on_error_on_ok(
    index_splitter(root),
    with_on_error: fn(error) { Error(error) }
  )

  use chapter_fragments <- infra.on_error_on_ok(
    chapter_splitter(root),
    with_on_error: fn(error) { Error(error) }
  )

  use sub_fragments <- infra.on_error_on_ok(
    sub_chapter_splitter(root),
    with_on_error: fn(error) { Error(error) }
  )

  // Combine all fragments
  Ok(list.flatten([
    index_fragments,
    chapter_fragments,
    sub_fragments
  ]))
}

fn our_pipeline() -> List(Pipe) {
  [
    [ dn.generate_ti3_index_element()
    ],
    pp.normalize_begin_end_align(infra.DoubleDollar),
    pp.create_mathblock_and_math_elements(
      #([infra.DoubleDollar], infra.DoubleDollar),
      #([infra.BackslashParenthesis], infra.SingleDollar),
    ),
    [
      dn.add_attributes([#("Document", "counter", "ChapterCounter")]),
      dn.add_attributes([#("Chapter", "counter", "ExerciseCounter")]),
      dn.add_attributes([#("Sub", "counter", "ExerciseCounter")]),
      dn.add_attributes([#("Chapter", "counter", "SubCounter")]),
      dn.associate_counter_by_prepending_incrementing_attribute([
        #("Chapter", "ChapterCounter")]),
      dn.associate_counter_by_prepending_incrementing_attribute([#("Exercise", "ExerciseCounter")]),
      dn.associate_counter_by_prepending_incrementing_attribute([#("Sub", "SubCounter")]),
      dn.prepend_text_if_has_ancestor_else([
        #("Exercise",
          "Sub",
          "*Übungsaufgabe ::øøChapterCounter.::øøSubCounter.::øøExerciseCounter* ",
          "*Übungsaufgabe ::øøChapterCounter.::øøExerciseCounter* ")]),
      dn.counters_substitute_and_assign_handles(),
    ],
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
            "Example", "Exercise", "OuterExercise", "Exercises", "Grid", "Image", "ImageLeft",
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
      dn.remove_text_nodes_with_singleton_empty_line(),
      dn.unwrap_when_child_of([#("VerticalChunk", ["ChapterTitle"])]),
      dn.rename(#("VerticalChunk", "p")),

      dn.rename_with_attributes([
        #("Index", "div", [#("class", "index")]),
        #("Chapter", "div", [#("class", "chapter")]),
        #("ChapterTitle", "div", [#("class", "main-column-width chapter-title")]),
        #("Sub", "div", [#("class", "subchapter")]),
        #("Definition", "div", [#("class", "definition")]),
        #("Exercise", "div", [#("class", "exercise")]),
        #("OuterExercise", "div", [#("class", "exercise")]),
      ]),

      dn.add_attributes([
        #("p", "class", "main-column-width"),
        #("figure", "class", "main-column-width"),
        #("img", "class", "constrained transition-all"),
        #("img", "onClick", "onImgClick(event)"),
      ]),
    ],
  ]
  |> list.flatten
}

// Index emitter - handles Index fragments
fn index_emitter(
  path: String,
  fragment: VXML,
  fragment_type: FragmentType,
) -> Result(#(String, List(BlamedLine), FragmentType), String) {
  let lines =
    list.flatten([
      [
        BlamedLine(blame_us("index_emitter"), 0, "<!DOCTYPE html>"),
        BlamedLine(blame_us("index_emitter"), 0, "<html>"),
        BlamedLine(blame_us("index_emitter"), 0, "<head>"),
        BlamedLine(blame_us("index_emitter"), 2, "<meta charset=\"utf-8\">"),
        BlamedLine(blame_us("index_emitter"), 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1\">"),
        BlamedLine(blame_us("index_emitter"), 2, "<meta name=\"description\" content=\"Table of contents for TI3 - Theoretische Informatik 2\">"),
        BlamedLine(blame_us("index_emitter"), 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"ti3.css\" />"),
        BlamedLine(blame_us("index_emitter"), 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        BlamedLine(blame_us("index_emitter"), 2, "<script type=\"text/javascript\" id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>"),
        BlamedLine(blame_us("index_emitter"), 2, "<script type=\"text/javascript\" src=\"./app.js\"></script>"),
        BlamedLine(blame_us("index_emitter"), 2, "<title>TI3 - Index</title>"),
        BlamedLine(blame_us("index_emitter"), 0, "</head>"),
        BlamedLine(blame_us("index_emitter"), 0, "<body class=\"page-index\">"),
      ],
      vxml.vxml_to_html_blamed_lines(fragment, 2, 2),
      [
        BlamedLine(blame_us("index_emitter"), 0, "</body>"),
        BlamedLine(blame_us("index_emitter"), 0, "</html>"),
        BlamedLine(blame_us("index_emitter"), 0, ""),
      ],
    ])
  Ok(#(path, lines, fragment_type))
}

// Chapter emitter - handles Chapter fragments
fn chapter_emitter(
  path: String,
  fragment: VXML,
  fragment_type: FragmentType,
) -> Result(#(String, List(BlamedLine), FragmentType), String) {
  let assert Chapter(n) = fragment_type
  let lines =
    list.flatten([
      [
        BlamedLine(blame_us("chapter_emitter"), 0, "<!DOCTYPE html>"),
        BlamedLine(blame_us("chapter_emitter"), 0, "<html>"),
        BlamedLine(blame_us("chapter_emitter"), 0, "<head>"),
        BlamedLine(blame_us("chapter_emitter"), 2, "<meta charset=\"utf-8\">"),
        BlamedLine(blame_us("chapter_emitter"), 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1\">"),
        BlamedLine(blame_us("chapter_emitter"), 2, "<meta name=\"description\" content=\"Chapter " <> string.inspect(n) <> " of TI3 - Theoretische Informatik 2\">"),
        BlamedLine(blame_us("chapter_emitter"), 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"ti3.css\" />"),
        BlamedLine(blame_us("chapter_emitter"), 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        BlamedLine(blame_us("chapter_emitter"), 2, "<script type=\"text/javascript\" id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>"),
        BlamedLine(blame_us("chapter_emitter"), 2, "<script type=\"text/javascript\" src=\"./app.js\"></script>"),
        BlamedLine(blame_us("chapter_emitter"), 2, "<title>TI3 - Chapter " <> string.inspect(n) <> "</title>"),
        BlamedLine(blame_us("chapter_emitter"), 0, "</head>"),
        BlamedLine(blame_us("chapter_emitter"), 0, "<body class=\"page-chapter chapter-" <> string.inspect(n) <> "\">"),
      ],
      vxml.vxml_to_html_blamed_lines(fragment, 2, 2),
      [
        BlamedLine(blame_us("chapter_emitter"), 0, "</body>"),
        BlamedLine(blame_us("chapter_emitter"), 0, "</html>"),
        BlamedLine(blame_us("chapter_emitter"), 0, ""),
      ],
    ])
  Ok(#(path, lines, fragment_type))
}

// Sub-chapter emitter - handles Sub fragments
fn sub_chapter_emitter(
  path: String,
  fragment: VXML,
  fragment_type: FragmentType,
) -> Result(#(String, List(BlamedLine), FragmentType), String) {
  let assert Sub(chapter_n, sub_n) = fragment_type
  let lines =
    list.flatten([
      [
        BlamedLine(blame_us("sub_chapter_emitter"), 0, "<!DOCTYPE html>"),
        BlamedLine(blame_us("sub_chapter_emitter"), 0, "<html>"),
        BlamedLine(blame_us("sub_chapter_emitter"), 0, "<head>"),
        BlamedLine(blame_us("sub_chapter_emitter"), 2, "<meta charset=\"utf-8\">"),
        BlamedLine(blame_us("sub_chapter_emitter"), 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1\">"),
        BlamedLine(blame_us("sub_chapter_emitter"), 2, "<meta name=\"description\" content=\"Section " <> string.inspect(chapter_n) <> "." <> string.inspect(sub_n) <> " of TI3 - Theoretische Informatik 2\">"),
        BlamedLine(blame_us("sub_chapter_emitter"), 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"ti3.css\" />"),
        BlamedLine(blame_us("sub_chapter_emitter"), 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        BlamedLine(blame_us("sub_chapter_emitter"), 2, "<script type=\"text/javascript\" id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>"),
        BlamedLine(blame_us("sub_chapter_emitter"), 2, "<script type=\"text/javascript\" src=\"./app.js\"></script>"),
        BlamedLine(blame_us("sub_chapter_emitter"), 2, "<title>TI3 - Chapter " <> string.inspect(chapter_n) <> ", Section " <> string.inspect(sub_n) <> "</title>"),
        BlamedLine(blame_us("sub_chapter_emitter"), 0, "</head>"),
        BlamedLine(blame_us("sub_chapter_emitter"), 0, "<body class=\"page-sub chapter-" <> string.inspect(chapter_n) <> " sub-" <> string.inspect(sub_n) <> "\">"),
      ],
      vxml.vxml_to_html_blamed_lines(fragment, 2, 2),
      [
        BlamedLine(blame_us("sub_chapter_emitter"), 0, "</body>"),
        BlamedLine(blame_us("sub_chapter_emitter"), 0, "</html>"),
        BlamedLine(blame_us("sub_chapter_emitter"), 0, ""),
      ],
    ])
  Ok(#(path, lines, fragment_type))
}

// Main emitter that dispatches to appropriate sub-emitters
pub fn our_emitter(
  tuple: #(String, VXML, FragmentType),
) -> Result(#(String, List(BlamedLine), FragmentType), String) {
  let #(path, fragment, fragment_type) = tuple
  case fragment_type {
    Index -> index_emitter(path, fragment, fragment_type)
    Chapter(_) -> chapter_emitter(path, fragment, fragment_type)
    Sub(_, _) -> sub_chapter_emitter(path, fragment, fragment_type)
  }
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
      splitter: ti3_splitter,
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
