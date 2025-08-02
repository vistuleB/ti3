import desugarer_library as dl
import infrastructure as infra
import gleam/list
import prefabricated_pipelines as pp
import group_replacement_splitting as grs

pub fn pipeline() -> List(infra.Desugarer) {
  let escape_dollar = grs.for_groups([#("\\\\", grs.Trash), #("\\$", grs.TagWithTextChild("span"))])
  [
    [
      dl.normalize_begin_end_align(#(infra.DoubleDollar, [infra.DoubleDollar]))
    ],
    pp.create_mathblock_elements([infra.DoubleDollar], infra.DoubleDollar),
    pp.splitting_empty_lines_cleanup(),
    pp.create_math_elements([infra.SingleDollar, infra.BackslashParenthesis], infra.SingleDollar),
    pp.splitting_empty_lines_cleanup(),
    [
      dl.regex_split_and_replace__outside(escape_dollar, ["Math", "MathBlock"]),
    ],
    pp.splitting_empty_lines_cleanup(),
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
      dl.associate_counter_by_prepending_incrementing_attribute(#("Chapter", "ChapterCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Exercise", "ExerciseCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Sub", "SubCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Statement", "StatementCounter")), 
      dl.prepend_text_node_if_has_ancestor_else__batch([
        #("Exercise",
          "Sub",
          "*Übungsaufgabe ::øøChapterCounter.::øøSubCounter.::øøExerciseCounter* ",
          "*Übungsaufgabe ::øøChapterCounter.::øøExerciseCounter* "),
        #("Statement",
          "Sub",
          "*::øøChapterCounter.::øøSubCounter.::øøStatementCounter*",
          "*::øøChapterCounter.::øøStatementCounter*"),
      ]),
      dl.prepend_text_node(#("ChapterTitle","::øøChapterCounter. ")), 
      dl.prepend_text_node(#("SubTitle", "::øøChapterCounter.::øøSubCounter ")),
      dl.prepend_attribute_as_text(#("Statement","title")),
      dl.prepend_attribute_as_text(#("Highlight","title")),
      dl.prepend_attribute_as_text(#("Remark","title")),
      dl.counters_substitute_and_assign_handles(),
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
            "Highlight", "Carousel", "CarouselItems", "CarouselItem",
            "h1", "h2", "h3", "pre", "div", "br", "hr",
            "figure", "img"
          ]
        ),
        ["MathBlock", "p", "Index", "Menu", "code", "pre", "h1", "h2", "h3", "span", "NoWrap", "Math", "QED", "Carousel"]
      ),
      dl.unwrap("WriterlyBlankLine"),
      dl.trim("p"),
      dl.delete_if_empty("p"),
    ],
    pp.symmetric_delim_splitting("_", "_", "i", ["MathBlock", "Math"]),
    pp.splitting_empty_lines_cleanup(),
    pp.symmetric_delim_splitting("\\*", "*", "b", ["MathBlock", "Math"]),
    pp.splitting_empty_lines_cleanup(),
    pp.symmetric_delim_splitting("`", "`", "code", ["MathBlock", "Math"]),
    pp.splitting_empty_lines_cleanup(),
    [
      dl.wrap_adjacent_non_whitespace_text_with(#("Math", "NoWrap")),
      dl.fold_contents_into_text("Math"),
      dl.wrap_children_in(#("Carousel","CarouselItems")),
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
            "h1", "h2", "h3", "p", "ol", "ul", "figure", "pre", "code", "MathBlock", "Carousel"
          ]), ""),
        #("Sub", "out", infra.has_class(_, "well"), ""),
        #("Sub", "main-column", infra.is_v_and_tag_is_one_of(_, [
            "h1", "h2", "h3", "p", "ol", "ul", "figure", "pre", "code", "MathBlock", "Carousel"
          ]), ""),
        #("Index", "main-column", fn(v) {!infra.tag_equals(v,"nav")}, ""),
      ]),
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
      dl.rename(#("Exercise", "div")),
      dl.rename(#("Statement", "div")),
      dl.rename(#("Highlight", "div")),
      dl.rename(#("Remark", "div")),
      dl.rename(#("Carousel", "div")),
      dl.rename(#("CarouselItems", "div")),
      dl.rename(#("CarouselItem", "div")),
      dl.rename(#("SubTheorem", "div")),
      dl.rename(#("NoWrap", "span")),
      dl.append_attribute__batch([
        #("img", "class", "constrained transition-all"),
        #("img", "onClick", "onImgClick(event)"),
      ]),
      dl.delete_attribute__batch([".", "counter", "title"]),
    ]
  ]
  |> list.flatten
}
