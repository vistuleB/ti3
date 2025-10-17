import blame.{Ext}
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string.{inspect as ins}
import infrastructure as infra
import io_lines.{type OutputLine, OutputLine}
import main_pipeline.{main_pipeline}
import simplifile
import vxml.{type VXML}
import desugaring as ds
import gleam/regexp.{type Regexp}

const title_banner = "TI2—"
const favicon_loc = "./img/favicon.svg"
const mathjax_loc = "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js"

pub type FragmentType {
  Chapter(Int)
  Sub(Int, Int)
  Index
}

type Fragment(z) = ds.OutputFragment(FragmentType, z)
type OL = List(OutputLine)

pub type TI2SplitterError {
  NoChapters
  MoreThanOneIndex
  NoIndex
}

fn index_error(e: infra.SingletonError) -> TI2SplitterError {
  case e {
    infra.MoreThanOne -> MoreThanOneIndex
    infra.LessThanOne -> NoIndex
  }
}

fn our_splitter(
  root: VXML
) -> Result(List(Fragment(VXML)), TI2SplitterError) {
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
    |> list.map(infra.v_extract_children(_, fn(child) {infra.is_v_and_has_class(child, "subchapter")}))
    |> list.unzip

  let chapter_fragments =
    chapters
    |> list.index_map(
      fn(chapter, chapter_index) {
        let chapter_number = chapter_index + 1
        ds.OutputFragment(
          Chapter(chapter_number),
          string.inspect(chapter_number) <> "-0" <> ".html",
          chapter
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
            ds.OutputFragment(
              Sub(chapter_number, sub_number),
              string.inspect(chapter_number) <> "-" <> string.inspect(sub_number) <> ".html",
              sub
            )
          }
        )
      }
    )
    |> list.flatten

  list.flatten([
    [ds.OutputFragment(Index, "index.html", index)],
    chapter_fragments,
    sub_fragments,
  ])

  |> Ok
}

// index emitter - handles index fragments
fn index_emitter(
  fragment: Fragment(VXML),
) -> Result(Fragment(OL), String) {
  let blame = Ext([], "index_emitter")
  let lines =
    list.flatten([
      [
        OutputLine(blame, 0, "<!DOCTYPE html>"),
        OutputLine(blame, 0, "<html>"),
        OutputLine(blame, 0, "<head>"),
        OutputLine(blame, 2, "<meta charset=\"utf-8\">"),
        OutputLine(blame, 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1\">"),
        OutputLine(blame, 2, "<meta name=\"description\" content=\"Table of contents for TI-2 - Theoretische Informatik 2\">"),
        OutputLine(blame, 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"app.css\" />"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" id=\"MathJax-script\" src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" src=\"./app.js\"></script>"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" src=\"./group.js\"></script>"),
        OutputLine(blame, 2, "<title>" <> title_banner <> "Inhaltsverzeichnis</title>"),
        OutputLine(blame, 0, "</head>"),
        OutputLine(blame, 0, "<body>"),
      ],
      vxml.vxmls_to_html_output_lines(fragment.payload |> infra.v_get_children, 2, 2),
      [
        OutputLine(blame, 0, "</body>"),
        OutputLine(blame, 0, "</html>"),
        OutputLine(blame, 0, ""),
      ],
    ])
  Ok(ds.OutputFragment(..fragment, payload: lines))
}

// chapter emitter - handles chapter fragments
fn chapter_emitter(
  fragment: Fragment(VXML),
) -> Result(Fragment(OL), String) {
  let assert Chapter(n) = fragment.classifier
  let blame = Ext([], "chapter_emitter")
  let lines =
    list.flatten([
      [
        OutputLine(blame, 0, "<!DOCTYPE html>"),
        OutputLine(blame, 0, "<html>"),
        OutputLine(blame, 0, "<head>"),
        OutputLine(blame, 2, "<meta charset=\"utf-8\">"),
        OutputLine(blame, 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1\">"),
        OutputLine(blame, 2, "<meta name=\"description\" content=\"Chapter " <> string.inspect(n) <> " of TI-2 - Theoretische Informatik 2\">"),
        OutputLine(blame, 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"app.css\" />"),
        OutputLine(blame, 2, "<link rel=\"icon\" type=\"image/x-icon\" href=\"" <> favicon_loc <> "\">"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" id=\"MathJax-script\" src=\"" <> mathjax_loc <> "\"></script>"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" src=\"./app.js\"></script>"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" src=\"./group.js\"></script>"),
        OutputLine(blame, 2, "<title>" <> title_banner <> "Kapitel " <> string.inspect(n) <> "</title>"),
        OutputLine(blame, 0, "</head>"),
        OutputLine(blame, 0, "<body>"),
      ],
      vxml.vxmls_to_html_output_lines(fragment.payload |> infra.v_get_children, 2, 2),
      [
        OutputLine(blame, 0, "</body>"),
        OutputLine(blame, 0, "</html>"),
        OutputLine(blame, 0, ""),
      ],
    ])
  Ok(ds.OutputFragment(..fragment, payload: lines))
}

// subchapter emitter - handles sub fragments
fn subchapter_emitter(
  fragment: Fragment(VXML),
) -> Result(Fragment(OL), String) {
  let assert Sub(chapter_n, sub_n) = fragment.classifier
  let blame = Ext([], "subchapter_emitter")
  let lines =
    list.flatten([
      [
        OutputLine(blame, 0, "<!DOCTYPE html>"),
        OutputLine(blame, 0, "<html>"),
        OutputLine(blame, 0, "<head>"),
        OutputLine(blame, 2, "<meta charset=\"utf-8\">"),
        OutputLine(blame, 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1\">"),
        OutputLine(blame, 2, "<meta name=\"description\" content=\"Section " <> string.inspect(chapter_n) <> "." <> string.inspect(sub_n) <> " of TI-2 - Theoretische Informatik 2\">"),
        OutputLine(blame, 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"app.css\" />"),
        OutputLine(blame, 2, "<link rel=\"icon\" type=\"image/x-icon\" href=\"" <> favicon_loc <> "\">"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" id=\"MathJax-script\" src=\"" <> mathjax_loc <> "\"></script>"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" src=\"./app.js\"></script>"),
        OutputLine(blame, 2, "<script type=\"text/javascript\" src=\"./group.js\"></script>"),
        OutputLine(blame, 2, "<title>" <> title_banner <> "Kapitel " <> string.inspect(chapter_n) <> "." <> string.inspect(sub_n) <> "</title>"),
        OutputLine(blame, 0, "</head>"),
        OutputLine(blame, 0, "<body>"),
      ],
      vxml.vxmls_to_html_output_lines(fragment.payload |> infra.v_get_children, 2, 2),
      [
        OutputLine(blame, 0, "</body>"),
        OutputLine(blame, 0, "</html>"),
        OutputLine(blame, 0, ""),
      ],
    ])
  Ok(ds.OutputFragment(..fragment, payload: lines))
}

// main emitter that dispatches to appropriate sub-emitters
fn our_emitter(
  fragment: Fragment(VXML),
) -> Result(Fragment(OL), String) {
  case fragment.classifier {
    Index -> index_emitter(fragment)
    Chapter(_) -> chapter_emitter(fragment)
    Sub(_, _) -> subchapter_emitter(fragment)
  }
}

fn cleanup_html_files(output_dir: String) -> Result(Nil, String) {
  io.println("• rm " <> output_dir <> "/**.html")
  case simplifile.read_directory(output_dir) {
    Ok(files) -> {
      files
      |> list.filter(fn(file) { string.ends_with(file, ".html") })
      |> list.map(fn(file) { 
        let file_path = output_dir <> "/" <> file
        case simplifile.delete(file_path) {
          Ok(_) -> Ok(Nil)
          Error(error) -> {
            io.println("Warning: Could not delete " <> file_path <> ": " <> string.inspect(error))
            Ok(Nil)  // continue even if some files can't be deleted
          }
        }
      })
      |> result.all
      |> result.map(fn(_) { Nil })
    }
    Error(error) -> {
      io.println("Warning: Could not read output directory " <> output_dir <> ": " <> string.inspect(error))
      Ok(Nil)  // continue even if directory can't be read
    }
  }
}

fn filename_shorthand_to_path_fragment(
  shorthand: String,
  filename_shorthand_regexp: Regexp,
) -> String {
  let zero_pad = fn(s) -> String {
    case string.length(s) < 2 {
      True -> "0" <> s
      False -> s
    }
  }
  case regexp.scan(filename_shorthand_regexp, shorthand) {
    [one] -> {
      let assert [Some(ch_no), Some(sub_no)] = one.submatches
      zero_pad(ch_no) <> "/" <> case zero_pad(sub_no) {
        "00" -> "__parent.wly"
        x -> x
      }
    }
    _ -> shorthand
  }
}

fn expand_filename_shorthands_to_path_fragments(
  amendments: ds.CommandLineAmendments,
) -> ds.CommandLineAmendments {
  let assert Ok(filename_shorthand_regexp) = regexp.from_string("^([\\d]{1,2})[\\.\\-]([\\d]{1,2})$")

  let only_paths = list.map(
    amendments.only_paths,
    filename_shorthand_to_path_fragment(_, filename_shorthand_regexp),
  )

  let only_key_values = list.map(
    amendments.only_key_values,
    fn(x) {
      let #(path, k, v) = x
      #(filename_shorthand_to_path_fragment(path, filename_shorthand_regexp), k, v)
    }
  )

  ds.CommandLineAmendments(
    ..amendments,
    only_paths: only_paths,
    only_key_values: only_key_values,
  )
}

pub fn main_renderer(amendments: ds.CommandLineAmendments) -> Nil {
  let amendments = expand_filename_shorthands_to_path_fragments(amendments)

  let renderer =
    ds.Renderer(
      assembler: ds.default_assembler(amendments.only_paths),
      parser: ds.default_writerly_parser(amendments.only_key_values),
      pipeline: main_pipeline(),
      splitter: our_splitter,
      emitter: our_emitter,
      writer: ds.default_writer,
      prettifier: ds.default_prettier_prettifier,
    )
    |> ds.amend_renderer_by_command_line_amendments(amendments)

  let parameters =
    ds.RendererParameters(
      input_dir: "./wly",
      output_dir: "./public",
      prettifier_behavior: ds.PrettifierOff,
      table: False,
      verbose: True,
    )
    |> ds.amend_renderer_paramaters_by_command_line_amendments(amendments)

  let debug_options =
    ds.default_renderer_debug_options()
    |> ds.amend_renderer_debug_options_by_command_line_amendments(amendments)

  // clean up HTML files before rendering
  case cleanup_html_files(parameters.output_dir) {
    Ok(_) -> Nil
    Error(error) -> io.println("HTML cleanup failed: " <> error)
  }
  
  case ds.run_renderer(renderer, parameters, debug_options) {
    Error(error) -> io.println("\nrenderer error: " <> ins(error) <> "\n")
    _ -> Nil
  }
}
