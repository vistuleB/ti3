import desugarer_library as dl
import infrastructure as infra
import gleam/list
import prefabricated_pipelines as pp

pub fn pipeline() -> List(infra.Desugarer) {
  [
    [ dl.normalize_begin_end_align(#(infra.DoubleDollar, [infra.DoubleDollar])) ],
    pp.create_mathblock_elements([infra.DoubleDollar], infra.DoubleDollar),
    pp.create_math_elements([infra.SingleDollar], infra.SingleDollar),
    pp.create_math_elements([infra.BackslashParenthesis], infra.SingleDollar),
    pp.create_math_elements([infra.BackslashSquareBracket], infra.SingleDollar),
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
      dl.generate_ti3_menu(),
      dl.append_attribute__batch([
        #("Document", "counter", "ChapterCounter"),
        #("Chapter", "counter", "SubCounter"),
        #("Chapter", "counter", "ExerciseCounter"),
        #("Chapter", "counter", "DefinitionCounter"),
        #("Sub", "counter", "ExerciseCounter"),
        #("Sub", "counter", "DefinitionCounter")
      ]),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Chapter", "ChapterCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Exercise", "ExerciseCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Sub", "SubCounter")),
        // Beobachtung and (future) others that all has the same counter and will use `DefinitionCounter`
      dl.associate_counter_by_prepending_incrementing_attribute(#("Definition", "DefinitionCounter")), 
      dl.associate_counter_by_prepending_incrementing_attribute(#("Beobachtung", "DefinitionCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Behauptung", "DefinitionCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Theorem", "DefinitionCounter")),
      dl.associate_counter_by_prepending_incrementing_attribute(#("Lemma", "DefinitionCounter")),
      dl.prepend_text_node_if_has_ancestor_else__batch([
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
      dl.prepend_text_node(#("ChapterTitle","::øøChapterCounter. ")), 
      dl.prepend_text_node(#("SubTitle", "::øøChapterCounter.::øøSubCounter ")),
      dl.counters_substitute_and_assign_handles(),
    ],
    pp.symmetric_delim_splitting("_", "_", "i", ["MathBlock", "Math"]),
    pp.symmetric_delim_splitting("\\*", "*", "b", ["MathBlock", "Math"]),
    pp.symmetric_delim_splitting("`", "`", "code", ["MathBlock", "Math"]),
    [
      dl.find_replace__outside(#("\\$", "$"), ["Math", "MathBlock"]),
      dl.wrap_adjacent_non_whitespace_text_with(#("Math", "NoWrap")),
      dl.fold_tag_contents_into_text(["MathBlock", "Math"]),
      dl.group_consecutive_children__outside(
        #(
          "p",
          [
            "CentralDisplay", "CentralDisplayItalic", "Chapter", "ChapterTitle",
            "Example", "Exercise", "Exercises", "Grid", "Image", "ImageLeft",
            "ImageRight", "List", "MathBlock", "Note", "Pause", "Section",
            "Solution", "SolutionNote", "StarDivider", "Table", "TextParent",
            "WriterlyBlankLine", "center", "li", "ul", "ol", "table", "colgroup",
            "Sub", "SubTitle", "Definition", "Beobachtung", "Behauptung", "Theorem", "Lemma", "SubTheorem",
            "thead", "tbody", "tr", "td", "section",
            "Index", "Menu", "QED",
            "Highlight",
            "h1", "h2", "h3", "pre", "div", "br", "hr",
            "figure", "img"
          ]
        ),
        ["MathBlock", "p", "Index", "Menu", "code", "pre", "h1", "h2", "h3", "span", "NoWrap", "Math", "ChapterTitle", "SubTitle", "QED"]
      ),
      dl.unwrap("WriterlyBlankLine"),
      dl.delete_text_nodes_with_singleton_empty_line(),
      dl.append_attribute__batch([
        #("Index", "class", "index"),
        #("Menu", "class", "menu"),
        #("Chapter", "class", "chapter"),
        #("ChapterTitle","class", "main-column page-title"),
        #("Sub", "class", "subchapter"),
        #("SubTitle", "class", "main-column page-title"),
        #("Definition", "class", "well definition"),
        #("Beobachtung", "class", "well beobachtung"),
        #("Behauptung", "class", "well behauptung "),
        #("Theorem", "class", "well theorem"),
        #("Lemma", "class", "well lemma"), 
        #("Exercise", "class", "well exercise"),
        #("Highlight", "class", "well highlight"),
        #("SubTheorem", "class", "well subtheorem"),
        #("NoWrap", "class", "nowrap"),
      ]),
      dl.append_class_to_child_if(#("Chapter", "out", infra.has_class(_, "well"), "has_class 'well'")),
      dl.append_class_to_child_if(#("Chapter", "main-column", infra.is_v_and_tag_is_one_of(_, [
          "h1", "h2", "h3", "p", "ol", "ul", "figure", "pre", "code"
        ]), "is_one_of[h1,h2,h3,p,ol,ul,figure,pre,code]")),
      dl.append_class_to_child_if(#("Sub", "out", infra.has_class(_, "well"), "has_class'well'")),
      dl.append_class_to_child_if(#("Sub", "main-column", infra.is_v_and_tag_is_one_of(_, [
          "h1", "h2", "h3", "p", "ol", "ul", "figure", "pre", "code"
        ]), "is_one_of(h1,h2,h3,p,ol,ul,figure,pre,code)")),
      dl.append_class_to_child_if(#("Index", "main-column", fn(v) {!infra.tag_equals(v,"nav")}, "!tag_equals nav")),
      dl.rename_with_appended_attributes_and_prepended_text([#("QED", "span", "\\(\\square\\)", [#("class", "qed")])]),
      dl.rename(#("Index", "div")),
      dl.rename(#("Menu", "div")),
      dl.rename(#("LeftMenu", "div")),
      dl.rename(#("RightMenu", "div")),
      dl.rename(#("Chapter", "div")),
      dl.rename(#("ChapterTitle", "div")),
      dl.rename(#("Sub", "div")),
      dl.rename(#("SubTitle", "div")),
      dl.rename(#("Definition", "div")),
      dl.rename(#("Beobachtung", "div")),
      dl.rename(#("Behauptung", "div")),
      dl.rename(#("Theorem", "div")),
      dl.rename(#("Lemma", "div")),
      dl.rename(#("Exercise", "div")),
      dl.rename(#("Highlight", "div")),
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
