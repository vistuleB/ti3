import desugarer_library as dl
import infrastructure.{type Pipe} as infra
import gleam/list
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
  "Index", "Menu", "WriterlyCodeBlock",
  "Highlight", "Carousel", "CarouselItems", "CarouselItem",
  "h1", "h2", "h3", "pre", "div", "br", "hr",
  "figure", "img", "Scope", "Topic", "SubTopic",
]

const p_cannot_be_contained_in = [
  "MathBlock", "p", "Index", "Menu", "code", "pre", "h1", "h2", "h3", "span", "NoWrap", "Math", "ChapterTitle", "SubTitle", "QED", "Carousel",
  "Topic", "SubTopic"
]

pub fn formatter_pipeline(cols: Int) -> List(Pipe) {
  [
    [
      dl.identity(),
      dl.trim_spaces_around_newlines__outside(["pre", "Math", "MathBlock", "WriterlyCodeBlock"]),
      dl.trim_ending_spaces_except_last_line(),
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
      dl.insert_text_start_end(#("tt", #("`", "`"))),
      dl.fold_contents_into_text("tt"),
      dl.insert_text_start_end(#("code", #("`", "`"))),
      dl.fold_contents_into_text("code"),
      dl.insert_text_start_end_if_unique_attr(#("span", "style", "font-variant:small-caps;", #("`", "`{sc}"))),
      dl.fold_children_into_text_if(#("span", infra.v_has_key_value(_, "style", "font-variant:small-caps;"))),
      dl.line_rewrap_no1__outside(#(cols, infra.is_v_and_tag_equals(_, "Math")), ["MathBlock", "pre", "WriterlyCodeBlock"]),
      dl.concatenate_text_nodes(),
      dl.fold_contents_into_text("Math"),
      dl.delete_empty_lines(),
      dl.split_first_line_after_prefix(#("MathBlock", "\\begin{align}")),
      dl.split_first_line_after_prefix(#("MathBlock", "\\begin{align*}")),
      dl.split_last_line_before_suffix(#("MathBlock", "\\end{align}")),
      dl.split_last_line_before_suffix(#("MathBlock", "\\end{align*}")),
      dl.unwrap("WriterlyBlankLine"),
      dl.trim_spaces_around_newlines__outside(["pre", "Math", "MathBlock", "WriterlyCodeBlock"]),
      dl.trim("p"),
      dl.delete_if_empty("p"),
      dl.unwrap_if_unique_child_is(#("Highlight", "pre")),
      dl.add_between(#("p", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("WriterlyCodeBlock", "p", "WriterlyBlankLine", [])),
      dl.add_before(#("WriterlyCodeBlock", "WriterlyBlankLine", [])),
      dl.add_between(#("MathBlock", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Topic", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("SubTopic", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Exercise", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Remark", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Statement", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("h3", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("h2", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("ol", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("ul", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("figure", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Carousel", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("pre", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("div", "p", "WriterlyBlankLine", [])),
      dl.add_between(#("Highlight", "p", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("MathBlock", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Topic", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("SubTopic", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Exercise", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Remark", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Statement", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("h3", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("h2", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("ol", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("ul", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("figure", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Carousel", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("pre", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("div", "WriterlyBlankLine", [])),
      dl.add_before_but_not_before_first_child(#("Highlight", "WriterlyBlankLine", [])),
      dl.unwrap("p"),
      dl.unwrap("MathBlock"),
      dl.delete_attribute__batch(["test", "t"]),
    ]
  ]
  |> list.flatten
  |> infra.desugarers_2_pipeline(
    sl.verbatim("<> marker")
    |> infra.extend_selector_up(4)
    |> infra.extend_selector_down(4),
    infra.TrackingOff,
  )
}
