import simplifile
import gleam/io
import gleam/list
import gleam/string.{inspect as ins}
import vxml_renderer as vr
import infrastructure.{type Pipe} as infra
import vxml.{type VXML, V}
import desugarer_library as dl
import prefabricated_pipelines as pp
import selector_library as sl

const p_cannot_contain = [
  "CentralDisplay", "CentralDisplayItalic", "Chapter", 
  "ChapterTitle", "Example", "Exercise", "Grid", "Image", 
  "List", "MathBlock", "Note", "Pause", "Section",
  "Solution", "SolutionNote", "StarDivider", "Table", "TextParent",
  "WriterlyBlankLine", "center", "li", "ul", "ol", "table", "colgroup",
  "Sub", "SubTitle", "Statement", "Remark",
  "thead", "tbody", "tr", "td", "section",
  "Index", "Menu",
  "Highlight", "Carousel", "CarouselItems", "CarouselItem",
  "h1", "h2", "h3", "pre", "div", "br", "hr",
  "figure", "img", "Scope", "Topic", "SubTopic"
]

const p_cannot_be_contained_in = [
  "MathBlock", "p", "Index", "Menu", "code", "pre", "h1", "h2", "h3", "span", "NoWrap", "Math", "ChapterTitle", "SubTitle", "QED", "Carousel",
  "Topic", "SubTopic"
]

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

fn our_pipeline() -> List(Pipe) {
  [
    [
      dl.find_replace__outside(#("&amp;", "&"), []),
    ],
    pp.create_mathblock_elements([infra.DoubleDollar, infra.BackslashSquareBracket, infra.BeginEndAlign, infra.BeginEndAlignStar], infra.DoubleDollar),
    pp.create_math_elements([infra.BackslashParenthesis, infra.SingleDollar], infra.SingleDollar, infra.BackslashParenthesis),
    [
      dl.strip_delimiters_inside_if(#(
        "MathBlock",
        infra.latex_strippable_display_delimiters(),
        infra.descendant_text_contains(_, "\\begin{align")
      )),
      dl.group_consecutive_children__outside(#("p", p_cannot_contain), p_cannot_be_contained_in),
      dl.concatenate_text_nodes(),
      dl.line_rewrap_no1__outside(#(50, infra.is_v_and_tag_equals(_, "Math")), ["MathBlock", "pre", "WriterlyCodeBlock"]),
      dl.concatenate_text_nodes(),
      dl.fold_contents_into_text("Math"),
      dl.delete_empty_lines(),
      dl.split_first_line_after_prefix(#("MathBlock", "\\begin{align}")),
      dl.split_first_line_after_prefix(#("MathBlock", "\\begin{align*}")),
      dl.split_last_line_before_suffix(#("MathBlock", "\\end{align}")),
      dl.split_last_line_before_suffix(#("MathBlock", "\\end{align*}")),
      dl.unwrap("WriterlyBlankLine"),
      dl.trim("p"),
      dl.delete_if_empty("p"),
      dl.add_between(#("MathBlock", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("WriterlyCodeBlock", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Topic", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("SubTopic", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Exercise", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Remark", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Statement", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Highlight", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("h3", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("h2", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("ol", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("ul", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("figure", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Carousel", "p", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("MathBlock", "WriterlyBlankLine", [])),
      dl.add_before(#("WriterlyCodeBlock", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Topic", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("SubTopic", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Exercise", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Remark", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Statement", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Highlight", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("h3", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("h2", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("ol", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("ul", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("figure", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Carousel", "WriterlyBlankLine", [])),
      dl.unwrap("p"),
      dl.unwrap("MathBlock"),
      dl.delete_attribute__batch(["test"]),
    ]
  ]
  |> list.flatten
  |> infra.wrap_desugarers(
    infra.Off,
    sl.tag("marker")
    |> infra.extend_selector_up(4)
    |> infra.extend_selector_down(4)
  )
}

pub fn entrypoint(amendments: vr.CommandLineAmendments) {
  let pipeline = our_pipeline()

  let renderer =
    vr.Renderer(
      assembler: vr.default_blamed_lines_assembler(amendments.spotlight_paths),
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
      prettifier_on_by_default: False,
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
