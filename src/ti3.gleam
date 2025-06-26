import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/string.{inspect as ins}
import argv
import blamedlines.{type Blame, type BlamedLine, Blame, BlamedLine}
import vxml.{type VXML, V, T}
import vxml_renderer as vr
import prefabricated_pipelines as pp
import infrastructure.{type Pipe} as infra
import desugarer_names as dn
import writerly as wp

// Helper function to find descendants with a specific attribute value
fn descendants_with_attribute_value(vxml: VXML, attr_key: String, attr_value: String) -> List(VXML) {
  case vxml {
    T(_, _) -> []
    V(_, _, _, children) -> {
      let current_matches = case infra.v_has_key_value_attribute(vxml, attr_key, attr_value) {
        True -> [vxml]
        False -> []
      }
      
      let child_matches = 
        list.map(children, descendants_with_attribute_value(_, attr_key, attr_value))
        |> list.flatten
      
      list.flatten([current_matches, child_matches])
    }
  }
}

pub type FragmentType {
  Chapter(Int)
  Sub(Int, Int)  // Sub(chapter_number, sub_number)
  Index
}

pub type TI3SplitterError {
  NoChapters
  MoreThanOneBook
  NoBook
}

fn ti3_splitter(
  root: VXML,
) -> Result(List(#(String, VXML, FragmentType)), TI3SplitterError) {
  // Try to find Book - it might be the root itself or a child
  let book_vxml = case root {
    V(_, "Book", _, _) -> Ok(root)
    _ -> {
      case infra.unique_child_with_tag(root, "Book") {
        Ok(book) -> Ok(book)
        Error(infra.LessThanOne) -> Ok(root)  // Use root as Book if no Book found
        Error(infra.MoreThanOne) -> Error(MoreThanOneBook)
      }
    }
  }

  use book <- infra.on_error_on_ok(book_vxml, with_on_error: fn(error) { Error(error) })

  // Since chapters are transformed to div with class="chapter" by the pipeline
  let chapter_vxmls = descendants_with_attribute_value(book, "class", "chapter")
  
  // Ensure we have at least one chapter
  case chapter_vxmls {
    [] -> Error(NoChapters)
    _ -> {
      // Create fragments for each chapter
      let chapter_fragments = 
        list.index_map(chapter_vxmls, fn(chapter, chapter_index) {
          let chapter_number = chapter_index + 1
          // Since subs are also transformed to divs with class="subchapter"
          let sub_vxmls = descendants_with_attribute_value(chapter, "class", "subchapter")
          
          // Create chapter fragment
          let chapter_fragment = #(
            "chapter" <> string.inspect(chapter_number) <> ".html", 
            chapter, 
            Chapter(chapter_number)
          )
          
          // Create sub fragments if any exist
          let sub_fragments = 
            list.index_map(sub_vxmls, fn(sub, sub_index) {
              let sub_number = sub_index + 1
              #(
                "chapter" <> string.inspect(chapter_number) <> "-sub" <> string.inspect(sub_number) <> ".html",
                sub,
                Sub(chapter_number, sub_number)
              )
            })
          
          [chapter_fragment, ..sub_fragments]
        })
        |> list.flatten

      // Create index fragment (table of contents)
      let index_fragment = #("index.html", book, Index)
      
      Ok([index_fragment, ..chapter_fragments])
    }
  }
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
      dn.rename(#("Index", "section")),

      dn.rename_with_attributes([
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

pub fn our_emitter(
  tuple: #(String, VXML, FragmentType),
) -> Result(#(String, List(BlamedLine), FragmentType), String) {
  let #(path, fragment, fragment_type) = tuple
  let blame_us = fn(msg: String) -> Blame { Blame(msg, 0, 0, []) }
  let lines =
    list.flatten([
      [
        BlamedLine(blame_us("ti3_emitter"), 0, "<!DOCTYPE html>"),
        BlamedLine(blame_us("ti3_emitter"), 0, "<html>"),
        BlamedLine(blame_us("ti3_emitter"), 0, "<head>"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<meta charset=\"utf-8\">"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1\">"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"ti3.css\" />"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<script type=\"text/javascript\" id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>"),
        BlamedLine(blame_us("ti3_emitter"), 2, "<script type=\"text/javascript\" src=\"./app.js\"></script>"),
        BlamedLine(blame_us("ti3_emitter"), 2, get_navigation_html(fragment_type)),
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

fn get_navigation_html(fragment_type: FragmentType) -> String {
  case fragment_type {
    Index -> "<title>TI3 - Index</title>"
    Chapter(n) -> "<title>TI3 - Chapter " <> string.inspect(n) <> "</title>"
    Sub(chapter_n, sub_n) -> "<title>TI3 - Chapter " <> string.inspect(chapter_n) <> ", Section " <> string.inspect(sub_n) <> "</title>"
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
