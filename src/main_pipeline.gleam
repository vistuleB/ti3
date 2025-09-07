import desugarer_library as dl
import infrastructure.{type Pipe} as infra
import gleam/list
import prefabricated_pipelines as pp
import group_replacement_splitting as grs
import selector_library as sl
import blame as bl
import vxml

const our_blame = bl.Des([], "main_pipeline", 9)

pub fn main_pipeline()  -> List(Pipe) {
  let escape_dollar = grs.for_groups([#("\\\\", grs.Trash), #("\\$", grs.TagWithTextChild("span"))])

  let pre_transformation_document_tags = ["Document", "Chapter", "ChapterTitle", "Sub", "SubTitle", "WriterlyBlankLine", "Topic", "SubTopic", "Statement", "Exercise", "Highlight", "Remark", "QED", "CircleX", "Carousel", "CarouselItem", "WriterlyCodeBlock", "marker"]
  let pre_transformation_html_tags = ["div", "a", "pre", "span", "br", "hr", "img", "figure", "figcaption", "ol", "ul", "li"]
  let pre_transformation_approved_tags = [pre_transformation_document_tags, pre_transformation_html_tags] |> list.flatten
  
  let post_transformation_document_tags = ["Document", "marker", "WriterlyCodeBlock"]
  let post_transformation_html_tags = pre_transformation_html_tags |> list.append(["header", "nav", "section", "h1", "h2", "p", "b", "i", "code"])
  let post_transformation_approved_tags = [post_transformation_document_tags, post_transformation_html_tags] |> list.flatten

  let possible_outer_elements = [
    "p",
    "ul",
    "ol",
    "div",
    "pre",
    "code",
    "figure",
    "Topic",
    "SubTopic",
    "MathBlock",
    "CarouselContainer",
  ]

  let qed = [
    vxml.V(
      our_blame,
      "span",
      [vxml.Attribute(our_blame, "style", "color:#0000;visibility:none;")],
      [vxml.T(our_blame, [vxml.TextLine(our_blame, "A")])],
    ),
    vxml.V(
      our_blame,
      "span",
      [vxml.Attribute(our_blame, "class", "qed")],
      [vxml.T(our_blame, [vxml.TextLine(our_blame, "\\(\\square\\)")])],
    ),
  ]

  [
    [
      dl.check_tags(#(pre_transformation_approved_tags, "pre-transformation")),
      dl.rename(#("WriterlyCodeBlock","CodeBlock")),
      dl.append_attribute__batch([
        #("Document", "counter", "ChapterCounter"),
        #("Chapter", "counter", "SubCounter"),
        #("Chapter", "counter", "ExerciseCounter"),
        #("Chapter", "counter", "StatementCounter"),
        #("Sub", "counter", "ExerciseCounter"),
        #("Sub", "counter", "StatementCounter")
      ]),
      dl.prepend_attribute(#("Chapter", "path", "./::øøChapterCounter-0.html", infra.GoBack)),
      dl.prepend_attribute(#("Sub", "path", "./::øøChapterCounter-::øøSubCounter.html", infra.GoBack)),
      dl.prepend_counter_incrementing_attribute(#("Chapter", "ChapterCounter", infra.GoBack)),
      dl.prepend_counter_incrementing_attribute(#("Sub", "SubCounter", infra.GoBack)),
      dl.prepend_counter_incrementing_attribute(#("Exercise", "ExerciseCounter", infra.Continue)),
      dl.prepend_counter_incrementing_attribute(#("Statement", "StatementCounter", infra.Continue)),
      dl.set_handle_value_if_has_ancestor_else(#("Statement", "Sub", "::øøChapterCounter.::øøSubCounter.::øøStatementCounter", "::øøChapterCounter.::øøStatementCounter")),
      dl.set_handle_value_if_has_ancestor_else(#("Exercise", "Sub", "::øøChapterCounter.::øøSubCounter.::øøExerciseCounter", "::øøChapterCounter.::øøExerciseCounter")),
      dl.set_handle_value_if_has_ancestor_else(#("Topic", "Sub", "::øøChapterCounter.::øøSubCounter", "::øøChapterCounter")),
      dl.auto_generate_child_if_missing_from_attribute(#("Chapter", "ChapterTitle", "title")),
      dl.auto_generate_child_if_missing_from_attribute(#("Sub", "SubTitle", "title")),
      dl.prepend_text_node(#("ChapterTitle","::øøChapterCounter. ")), 
      dl.prepend_text_node(#("SubTitle", "::øøChapterCounter.::øøSubCounter ")),
      dl.prepend_text_node_if_has_ancestor_else__batch([
        #(
          "Exercise",
          "Sub",
          " *Übungsaufgabe ::øøChapterCounter.::øøSubCounter.::øøExerciseCounter* ",
          " *Übungsaufgabe ::øøChapterCounter.::øøExerciseCounter* "
        ),
        #(
          "Statement",
          "Sub",
          " *::øøChapterCounter.::øøSubCounter.::øøStatementCounter* ",
          " *::øøChapterCounter.::øøStatementCounter* "
        ),
      ]),
      dl.counters_substitute_and_assign_handles(),
      dl.handles_generate_ids(),
      dl.handles_generate_dictionary("path"),
      dl.handles_substitute(#("path", "a", "a", [], [])),
      dl.prepend_attribute_as_text(#("Statement", "title")),
      dl.prepend_attribute_as_text(#("Highlight", "title")),
      dl.prepend_attribute_as_text(#("Remark", "title")),
    ],
    pp.create_mathblock_elements([infra.DoubleDollar, infra.BeginEndAlign, infra.BeginEndAlignStar], infra.DoubleDollar),
    pp.splitting_empty_lines_cleanup(),
    pp.create_math_elements([infra.BackslashParenthesis, infra.SingleDollar], infra.SingleDollar, infra.BackslashParenthesis),
    pp.splitting_empty_lines_cleanup(),
    [
      dl.regex_split_and_replace__outside(escape_dollar, ["Math", "MathBlock"]),
    ],
    pp.splitting_empty_lines_cleanup(),
    [
      dl.ti3_code_block_to_pre(),
      dl.ti3_parse_python_prompt_pre(),
      dl.ti3_parse_orange_comments_pre(),
      dl.ti3_parse_arbitrary_prompt_response_pre(),
      dl.ti3_parse_redyellow_pre(),
      dl.normalize_br_in_pre(),
      dl.ti3_add_listing_bol_spans(),
      dl.generate_ti3_index(),
      dl.generate_ti3_menu(),
      dl.expand_ti3_carousel(),
      dl.group_consecutive_children__outside(
        #(
          "p",
          [
            "CentralDisplay", "CentralDisplayItalic", "Chapter", "ChapterTitle",
            "Example", "Exercise", "Grid", "Image", "ImageLeft",
            "ImageRight", "List", "MathBlock", "Note", "Pause", "Section",
            "Solution", "SolutionNote", "StarDivider", "Table", "TextParent",
            "WriterlyBlankLine", "center", "li", "ul", "ol", "table", "colgroup",
            "Sub", "SubTitle", "Statement", "Remark",
            "thead", "tbody", "tr", "td", "section",
            "Index", "Menu",
            "Topic", "SubTopic",
            "Highlight", "CarouselContainer", "Carousel", "CarouselItems", "CarouselItem",
            "pre", "div", "br", "hr",
            "figure"
          ]
        ),
        ["MathBlock", "p", "Index", "Menu", "Topic", "SubTopic", "code", "pre", "span", "NoWrap", "Math", "QED", "CarouselContainer", "figure"]
      ),
      dl.unwrap("WriterlyBlankLine"),      
      dl.trim("p"),
      dl.delete_if_empty("p"),
      dl.rearrange_links(#("Theorem <a href=1>_1_</a>", "<a href=1>Theorem _1_</a>")),
      dl.rearrange_links(#("Übungsaufgabe <a href=1>_1_</a>", "<a href=1>Übungsaufgabe _1_</a>")),
      dl.rearrange_links(#("Aufgabe <a href=1>_1_</a>", "<a href=1>Aufgabe _1_</a>")),
      dl.rearrange_links(#("Kapitel <a href=1>_1_</a>", "<a href=1>Kapitel _1_</a>")),
      dl.rearrange_links(#("Lemma <a href=1>_1_</a>", "<a href=1>Lemma _1_</a>")),    
      dl.rearrange_links(#("Algorithmus <a href=1>_1_</a>", "<a href=1>Algorithmus _1_</a>")),
    ],
    pp.symmetric_delim_splitting("`", "`", "code", ["MathBlock", "Math"]),
    pp.splitting_empty_lines_cleanup(),
    pp.symmetric_delim_splitting("_", "_", "i", ["MathBlock", "Math", "pre", "code"]),
    pp.splitting_empty_lines_cleanup(),
    pp.symmetric_delim_splitting("\\*", "*", "b", ["MathBlock", "Math", "pre", "code"]),
    pp.splitting_empty_lines_cleanup(),
    [
      dl.wrap_adjacent_non_whitespace_text_with(#("Math", "NoWrap")),
    ],
    pp.splitting_empty_lines_cleanup(),
    [
      dl.fold_contents_into_text("Math"),
      dl.wrap_children_in(#("Carousel","CarouselItems")),
      dl.wrap(#("Carousel", "CarouselContainer")),
      dl.append_attribute__batch([
        #("Index", "class", "index"),
        #("Menu", "class", "menu"),
        #("Chapter", "class", "chapter"),
        #("ChapterTitle","class", "main-column page-title"),
        #("Sub", "class", "subchapter"),
        #("SubTitle", "class", "main-column page-title"),
        #("MathBlock", "class", "math-block"),
        #("Highlight", "class", "well highlight"),
        #("Statement", "class", "well statement"), 
        #("Remark", "class", "well remark"),
        #("Exercise", "class", "well exercise"),
        #("CarouselContainer", "class", "carousel__container"),
        #("Carousel", "class", "carousel"),
        // `CarouselItems` represents middle column
        // (< prevBtn) --- CarouselItems --- (nextBtn >)
        #("CarouselItems", "class", "carousel__items"),
        #("CarouselItem", "class", "carousel__item"),
        #("NoWrap", "class", "nowrap"),
      ]),
      dl.wrap_with_if_child_of(#("pre", "div", ["Sub", "Chapter"])),
      dl.wrap_with_if_child_of(#("ol", "div", ["Sub", "Chapter"])),
      dl.wrap_with_if_child_of(#("ul", "div", ["Sub", "Chapter"])),
      dl.append_class_to_child_if_has_class(#("Chapter", "out", "well")),
      dl.append_class_to_child_if_has_class(#("Sub", "out", "well")),
      dl.append_class_to_child_if_is_one_of(#("Chapter", "main-column", possible_outer_elements)),
      dl.append_class_to_child_if_is_one_of(#("Sub", "main-column", possible_outer_elements)),
      dl.append_class_to_child_if_is_not_one_of(#("Index", "main-column", ["nav"])),
      dl.append_attribute__outside(#("img", "class", "constrained transition-all"), ["CarouselContainer"]),
      dl.append_attribute__outside(#("img", "onClick", "onImgClick(event)"), ["CarouselContainer"]),
      dl.replace_with_arbitrary(#("QED", qed)),
      dl.rename_with_attributes(#("CircleX", "img", [#("class", "circle-X-img"), #("src", "img/context-free/LR/circle-X.svg")])),
      dl.rename(#("MathBlock", "div")),
      dl.rename(#("Index", "div")),
      dl.rename(#("Menu", "div")),
      dl.rename(#("LeftMenu", "div")),
      dl.rename(#("RightMenu", "div")),
      dl.rename(#("Chapter", "div")),
      dl.rename(#("ChapterTitle", "div")),
      dl.rename(#("Sub", "div")),
      dl.rename(#("SubTitle", "div")),
      dl.rename(#("Topic", "h1")),
      dl.rename(#("SubTopic", "h2")),
      dl.rename(#("Exercise", "div")),
      dl.rename(#("Statement", "div")),
      dl.rename(#("Highlight", "div")),
      dl.rename(#("Remark", "div")),
      dl.rename(#("CarouselContainer", "div")),
      dl.rename(#("Carousel", "div")),
      dl.rename(#("CarouselItems", "div")),
      dl.rename(#("CarouselItem", "div")),
      dl.rename(#("SubTheorem", "div")),
      dl.rename(#("NoWrap", "span")),
      dl.delete_attribute__batch([".", "counter", "title"]),
      dl.check_tags(#(post_transformation_approved_tags,"post-transformation")),
    ]
  ]
  |> list.flatten
  |> infra.desugarers_2_pipeline(
    sl.verbatim("ächstes wollen wir zeig")
    |> infra.extend_selector_up(4)
    |> infra.extend_selector_down(16)
    |> infra.extend_selector_to_ancestors(
      with_elder_siblings: True,
      with_attributes: False,
    ),
    infra.TrackingOff,
  )
}
