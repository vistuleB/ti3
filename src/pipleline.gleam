import desugarer_library as dl
import infrastructure as infra
import gleam/list
import prefabricated_pipelines as pp

pub fn pipeline() -> List(infra.Desugarer) {
  [
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
      dl.generate_ti3_menu(),
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
        // Beobachtung and (future) others that all has the same counter and will use `DefinitionCounter`
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
      dl.add_attributes([
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
        #("NoWrap", "class", "nowrap"),
      ]),
      dl.append_class_to_child_if([
        #("Chapter", "out", infra.has_class(_, "well")),
        #("Chapter", "main-column", infra.is_v_and_tag_is_one_of(_, [
          "h1", "h2", "h3", "p", "ol", "ul", "figure", "pre", "code"
        ])),
        #("Sub", "out", infra.has_class(_, "well")),
        #("Sub", "main-column", infra.is_v_and_tag_is_one_of(_, [
          "h1", "h2", "h3", "p", "ol", "ul", "figure", "pre", "code"
        ])),
        #("Index", "main-column", fn(v) {!infra.tag_equals(v,"nav")}),
      ]),
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
      dl.rename(#("NoWrap", "span")),
      dl.add_attributes([
        #("img", "class", "constrained transition-all"),
        #("img", "onClick", "onImgClick(event)"),
      ]),
      dl.remove_attributes([".", "counter", "title"]),
    ]
  ]
  |> list.flatten
}
