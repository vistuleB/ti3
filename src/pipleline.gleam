import desugarer_library as dl
import infrastructure.{type Pipe} as infra
import gleam/list
import prefabricated_pipelines as pp
import group_replacement_splitting as grs
import selector_library as sl

pub fn pipeline()  -> List(Pipe) {
  let escape_dollar = grs.for_groups([#("\\\\", grs.Trash), #("\\$", grs.TagWithTextChild("span"))])

  let pre_transformation_document_tags = ["Document", "Chapter", "ChapterTitle", "Sub", "SubTitle", "WriterlyBlankLine", "Topic", "SubTopic", "Statement", "Exercise", "Highlight", "Remark", "QED", "Carousel", "CarouselItem", "WriterlyCodeBlock", "marker"]
  let pre_transformation_html_tags = ["div", "a", "pre", "span", "br", "hr", "img", "figure", "figcaption", "ol", "ul", "li"]
  let pre_transformation_approved_tags = [pre_transformation_document_tags, pre_transformation_html_tags] |> list.flatten
  
  let post_transformation_document_tags = ["Document", "marker", "WriterlyCodeBlock"]
  let post_transformation_html_tags = pre_transformation_html_tags |> list.append(["header", "nav", "section", "h1", "h2", "p", "b", "i", "code"])
  let post_transformation_approved_tags = [post_transformation_document_tags, post_transformation_html_tags] |> list.flatten

  [
    [
      dl.check_tags(#(pre_transformation_approved_tags, "pre-transformation")),
      dl.rename(#("WriterlyCodeBlock","CodeBlock")),
    ],
    pp.create_mathblock_elements([infra.DoubleDollar, infra.BeginEndAlign, infra.BeginEndAlignStar], infra.DoubleDollar),
    pp.splitting_empty_lines_cleanup(),
    pp.create_math_elements([infra.SingleDollar, infra.BackslashParenthesis], infra.SingleDollar, infra.BackslashParenthesis),
    pp.splitting_empty_lines_cleanup(),
    [
      dl.regex_split_and_replace__outside(escape_dollar, ["Math", "MathBlock"]),
    ],
    pp.splitting_empty_lines_cleanup(),
    [
      dl.python_prompt_code_block(),
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
      dl.generate_ti3_index(),
      dl.generate_ti3_menu(),
      dl.append_attribute__batch([
        #("Document", "counter", "ChapterCounter"),
        #("Chapter", "counter", "SubCounter"),
        #("Chapter", "counter", "ExerciseCounter"),
        #("Chapter", "counter", "StatementCounter"),
        #("Sub", "counter", "ExerciseCounter"),
        #("Sub", "counter", "StatementCounter")
      ]),
      dl.append_value_to_handle_attribute_if_has_ancestor_else(#("Statement", "Sub", "::øøChapterCounter.::øøSubCounter.::øøStatementCounter", "::øøChapterCounter.::øøStatementCounter")),
      dl.append_value_to_handle_attribute_if_has_ancestor_else(#("Exercise", "Sub", "::øøChapterCounter.::øøSubCounter.::øøExerciseCounter", "::øøChapterCounter.::øøExerciseCounter")),
      dl.append_value_to_handle_attribute_if_has_ancestor_else(#("Topic", "Sub", "::øøChapterCounter.::øøSubCounter", "::øøChapterCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Chapter", "ChapterCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Exercise", "ExerciseCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Sub", "SubCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Statement", "StatementCounter")), 
      dl.prepend_text_node_if_has_ancestor_else__batch([
        #("Exercise",
          "Sub",
          " *Übungsaufgabe ::øøChapterCounter.::øøSubCounter.::øøExerciseCounter* ",
          " *Übungsaufgabe ::øøChapterCounter.::øøExerciseCounter* "),
        #("Statement",
          "Sub",
          " *::øøChapterCounter.::øøSubCounter.::øøStatementCounter* ",
          " *::øøChapterCounter.::øøStatementCounter* "),
      ]),
      dl.prepend_text_node(#("ChapterTitle","::øøChapterCounter. ")), 
      dl.prepend_text_node(#("SubTitle", "::øøChapterCounter.::øøSubCounter ")),
      dl.prepend_attribute_as_text(#("Statement","title")),
      dl.prepend_attribute_as_text(#("Highlight","title")),
      dl.prepend_attribute_as_text(#("Remark","title")),
      dl.append_attribute__outside(#("Chapter", "path", "./::øøChapterCounter-0.html"), []),
      dl.append_attribute__outside(#("Sub", "path", "./::øøChapterCounter-::øøSubCounter.html"), []),
      dl.counters_substitute_and_assign_handles(),
      dl.handles_generate_ids(),
      dl.handles_generate_dictionary("path"),
      dl.handles_substitute(#("path", "a", "a", [], [])),
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
            "figure", "img"
          ]
        ),
        ["MathBlock", "p", "Index", "Menu", "Topic", "SubTopic", "code", "pre", "span", "NoWrap", "Math", "QED", "CarouselContainer"]
      ),
      dl.unwrap("WriterlyBlankLine"),      
      dl.trim("p"),
      dl.delete_if_empty("p"),
      dl.rearrange_links(#("Theorem <a href='1'>_1_</a>", "<a href='1'>Theorem _1_</a>")),
      dl.rearrange_links(#("Übungsaufgabe <a href='1'>_1_</a>", "<a href='1'>Übungsaufgabe _1_</a>")),
      dl.rearrange_links(#("Aufgabe <a href='1'>_1_</a>", "<a href='1'>Aufgabe _1_</a>")),
      dl.rearrange_links(#("Kapitel <a href='1'>_1_</a>", "<a href='1'>Kapitel _1_</a>")),
      dl.rearrange_links(#("Lemma <a href='1'>_1_</a>", "<a href='1'>Lemma _1_</a>")),
    ],
    pp.symmetric_delim_splitting("`", "`", "code", ["MathBlock", "Math"]),
    pp.splitting_empty_lines_cleanup(),
    pp.symmetric_delim_splitting("_", "_", "i", ["MathBlock", "Math", "pre", "code"]),
    pp.splitting_empty_lines_cleanup(),
    pp.symmetric_delim_splitting("\\*", "*", "b", ["MathBlock", "Math", "pre", "code"]),
    pp.splitting_empty_lines_cleanup(),
    [
      dl.wrap_adjacent_non_whitespace_text_with(#("Math", "NoWrap")),
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
      dl.append_class_to_child_if__batch([
        #("Chapter", "out", infra.has_class(_, "well"), ""),
        #("Chapter", "main-column", infra.is_v_and_tag_is_one_of(_, [
          "Topic", "SubTopic", "div", "p", "ol", "ul", "figure", "pre", "code", "MathBlock", "CarouselContainer"
          ]), ""),
        #("Sub", "out", infra.has_class(_, "well"), ""),
        #("Sub", "main-column", infra.is_v_and_tag_is_one_of(_, [
            "Topic", "SubTopic", "div", "p", "ol", "ul", "figure", "pre", "code", "MathBlock", "CarouselContainer"
          ]), ""),
        #("Index", "main-column", fn(v) {!infra.tag_equals(v,"nav")}, ""),
      ]),
      dl.append_attribute__outside(#("img", "class", "constrained transition-all"), ["CarouselContainer"]),
      dl.append_attribute__outside(#("img", "onClick", "onImgClick(event)"), ["CarouselContainer"]),
      dl.rename_with_appended_attributes_and_prepended_text([#("QED", "span", "\\(\\square\\)", [#("class", "qed")])]),
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
      dl.check_tags(#(post_transformation_approved_tags,"post-transformation"))
    ]
  ]
  |> list.flatten
  |> infra.wrap_desugarers(
    infra.Off,
    // sl.tag("marker")
    // sl.key_val("test", "test")
    sl.text("ächstes wollen wir zeig")
    |> infra.extend_selector_up(4)
    |> infra.extend_selector_down(16)
    |> infra.extend_selector_to_ancestors(
      with_elder_siblings: True,
      with_attributes: False,
    )
  )
}
