import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/string.{inspect as ins}
import argv
import blamedlines.{type Blame, type BlamedLine, Blame, BlamedLine}
import vxml.{type VXML}
import vxml_renderer as vr
import prefabricated_pipelines as pp
import infrastructure as infra
import gleam/result
import desugarer_library as dl
import writerly as wp
import group_replacement_splitting as grs
import gleam/regexp

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

fn ti3_splitter(
  root: VXML
) -> Result(List(#(String, VXML, FragmentType)), TI3SplitterError) {
  use index <- result.try(
    infra.descendants_with_class(root, "index")
    |> infra.read_singleton
    |> result.map_error(index_error)
  )

  use chapters <- result.try(
    case infra.descendants_with_class(root, "chapter") {
      [] -> Error(NoChapters)
      [..chapters] -> Ok(chapters)
    }
  )

  let #(chapters, list_list_subs) =
    chapters
    |> list.map(infra.excise_children(_, fn(child) {infra.has_class(child, "subchapter")}))
    |> list.unzip

  let chapter_fragments =
    chapters
    |> list.index_map(
      fn(chapter, chapter_index) {
        let chapter_number = chapter_index + 1
        #(
          string.inspect(chapter_number) <> "-0" <> ".html",
          chapter,
          Chapter(chapter_number)
        )
      }
    )

  let sub_fragments =
    list_list_subs
    |> list.index_map(
      fn(chapter_subs, chapter_index) {
        let chapter_number = chapter_index + 1
        list.index_map(
          chapter_subs,
          fn(sub, sub_index) {
            let sub_number = sub_index + 1
            #(
              string.inspect(chapter_number) <> "-" <> string.inspect(sub_number) <> ".html",
              sub,
              Sub(chapter_number, sub_number)
            )
          }
        )
      }
    )
    |> list.flatten

  list.flatten([
    [#("index.html", index, Index)],
    chapter_fragments,
    sub_fragments,
  ])
  |> Ok
}

fn our_pipeline() -> List(infra.Desugarer) {
  let assert Ok(code_regex) = regexp.from_string("`([^`]+)`")
  let code_highlighter = grs.RegexpWithGroupReplacementInstructions(
    re: code_regex,
    instructions: [
      grs.TagReplaceKeepPayloadAsTextChild("code") 
    ]
  )
  
  [
    // pp.normalize_begin_end_align(infra.DoubleDollar),
    pp.create_mathblock_and_math_elements(
      #([infra.DoubleDollar], infra.DoubleDollar),
      #([infra.BackslashParenthesis, infra.SingleDollar], infra.SingleDollar),
    ),
    [
      dl.auto_generate_child_if_missing_from_attribute(#(
        "Chapter",        // parent tag
        "ChapterTitle",   // new child tag
        "title"           // attribute to extract from
      )),
      dl.auto_generate_child_if_missing_from_attribute(#(
        "Sub",
        "SubTitle",
        "title"
      )),
      dl.generate_ti3_index_element(),
      
      dl.add_attributes([
        #("Document", "counter", "ChapterCounter"),
        #("Chapter", "counter", "SubCounter"),
        #("Chapter", "counter", "ExerciseCounter"),
        #("Chapter", "counter", "DefinitionCounter"),
        #("Sub", "counter", "ExerciseCounter"),
        #("Sub", "counter", "DefinitionCounter")
      ]),
      dl.associate_counter_by_prepending_incrementing_attribute([
        #("Chapter", "ChapterCounter"),
        #("Exercise", "ExerciseCounter"),
        #("Sub", "SubCounter"),
        // Beobachtung and (future) others that all has the same counter and will use `DefinitionCounter` as well `definition` class
        #("Definition", "DefinitionCounter"), 
        #("Beobachtung", "DefinitionCounter"),
        #("Behauptung", "DefinitionCounter"),
        #("Theorem", "DefinitionCounter"),
        #("Lemma", "DefinitionCounter"),
      ]),
      dl.prepend_text_if_has_ancestor_else([
        #("Exercise",
          "Sub",
          "*Übungsaufgabe ::øøChapterCounter.::øøSubCounter.::øøExerciseCounter* ",
          "*Übungsaufgabe ::øøChapterCounter.::øøExerciseCounter* "),
        #("Definition",
          "Sub",
          "*Definition ::øøChapterCounter.::øøSubCounter.::øøDefinitionCounter* ",
          "*Definition ::øøChapterCounter.::øøDefinitionCounter* "),
        #("Beobachtung",
          "Sub",
          "*Beobachtung ::øøChapterCounter.::øøSubCounter.::øøDefinitionCounter* ",
          "*Beobachtung ::øøChapterCounter.::øøDefinitionCounter* "),
        #("Behauptung",
          "Sub",
          "*Behauptung ::øøChapterCounter.::øøSubCounter.::øøDefinitionCounter* ",
          "*Behauptung ::øøChapterCounter.::øøDefinitionCounter* "),
        #("Theorem",
          "Sub",
          "*Theorem ::øøChapterCounter.::øøSubCounter.::øøDefinitionCounter* ",
          "*Theorem ::øøChapterCounter.::øøDefinitionCounter* "),
        #("Lemma",
          "Sub",
          "*Lemma ::øøChapterCounter.::øøSubCounter.::øøDefinitionCounter* ",
          "*Lemma ::øøChapterCounter.::øøDefinitionCounter* "),
      ]),
      dl.prepend_text([#("ChapterTitle","::øøChapterCounter. "), #("SubTitle", "::øøChapterCounter.::øøSubCounter ")]),
      dl.counters_substitute_and_assign_handles(),
    ],
    pp.symmetric_delim_splitting("_", "_", "i", ["MathBlock", "Math"]),
    pp.symmetric_delim_splitting("\\*", "*", "b", ["MathBlock", "Math"]),
    pp.symmetric_delim_splitting("`", "`", "code", ["MathBlock", "Math"]),
    [
      dl.find_replace(#([#("\\$", "$")], ["Math", "MathBlock"])),
      dl.wrap_adjacent_non_whitespace_text_with(#("Math", "NoWrap")),
      dl.fold_tag_contents_into_text(["MathBlock", "Math"]),
      dl.group_consecutive_children_avoiding(
        #(
          "p",
          [
            "CentralDisplay", "CentralDisplayItalic", "Chapter", "ChapterTitle",
            "Example", "Exercise", "Exercises", "Grid", "Image", "ImageLeft",
            "ImageRight", "List", "MathBlock", "Note", "Pause", "Section",
            "Solution", "SolutionNote", "StarDivider", "Table", "TextParent",
            "WriterlyBlankLine", "center", "li", "ul", "ol", "table", "colgroup",
            "Sub", "SubTitle", "Definition", "Beobachtung", "Behauptung", "Theorem", "Lemma",
            "thead", "tbody", "tr", "td", "section",
            "Index",
            "Highlight",
            "h1", "h2", "h3", "pre", "div", "br",
          ],
          ["MathBlock", "p", "Index", "code", "pre", "h1", "h2", "h3", "span", "NoWrap", "Math", "ChapterTitle", "SubTitle"]
        ),
      ),
      dl.unwrap(["WriterlyBlankLine"]),
      dl.remove_text_nodes_with_singleton_empty_line(),
      dl.rename_with_attributes([
        #("Index", "div", [#("class", "index")]),
        #("Chapter", "div", [#("class", "chapter")]),
        #("ChapterTitle", "div", [#("class", "main-column-width page-title")]),
        #("SubTitle", "div", [#("class", "main-column-width page-title")]),
        #("Sub", "div", [#("class", "subchapter")]),
        #("Definition", "div", [#("class", "definition")]),
        #("Beobachtung", "div", [#("class", "definition")]),
        #("Behauptung", "div", [#("class", "definition")]),
        #("Theorem", "div", [#("class", "definition")]),
        #("Lemma", "div", [#("class", "definition")]),
        #("Exercise", "div", [#("class", "exercise")]),
        #("Highlight", "div", [#("class", "highlight")]),
        #("NoWrap", "span", [#("class", "nowrap")]),
      ]),
      dl.add_attributes([
        #("p", "class", "main-column-width"),
        #("h1", "class", "main-column-width"),
        #("h2", "class", "main-column-width"),
        #("h3", "class", "main-column-width"),
        #("figure", "class", "main-column-width"),
        #("img", "class", "constrained transition-all"),
        #("img", "onClick", "onImgClick(event)"),
      ]),
    dl.remove_attributes([".", "counter", "title"]),
    dl.split_with_replacement_instructions(code_highlighter),
    ],
  ]
  |> list.flatten
}

// index emitter - handles index fragments
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

// chapter emitter - handles chapter fragments
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

// sub-chapter emitter - handles sub fragments
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

// main emitter that dispatches to appropriate sub-emitters
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
