import argv
import blamedlines.{type Blame, type BlamedLine, Blame, BlamedLine}
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string.{inspect as ins}
import infrastructure as infra
import pipleline.{pipeline}
import simplifile
import vxml.{type VXML}
import vxml_renderer as vr
import writerly as wp

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

fn cleanup_html_files(output_dir: String) -> Result(Nil, String) {
  case simplifile.read_directory(output_dir) {
    Ok(files) -> {
      files
      |> list.filter(fn(file) { string.ends_with(file, ".html") })
      |> list.map(fn(file) { 
        let file_path = output_dir <> "/" <> file
        case simplifile.delete(file_path) {
          Ok(_) -> {
            io.println("Deleted: " <> file_path)
            Ok(Nil)
          }
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

pub fn main() {
  let args = argv.load().arguments
  // automatically add --prettier flag if not already present
  let args_with_prettier = case list.contains(args, "--prettier") {
    True -> args
    False -> list.append(args, ["--prettier"])
  }

  use amendments <- infra.on_error_on_ok(
    vr.process_command_line_arguments(args_with_prettier, ["--prettier"]),
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
      pipeline: pipeline(),
      splitter: ti3_splitter,
      emitter: our_emitter,
      prettifier: vr.guarded_prettier_prettifier(amendments.user_args),
    )

  let parameters =
    vr.RendererParameters(
      input_dir: "./wly",
      output_dir: Some("./public"),
    )
    |> vr.amend_renderer_paramaters_by_command_line_amendment(amendments)

  let debug_options =
    vr.empty_renderer_debug_options("../renderer_artifacts")
    |> vr.amend_renderer_debug_options_by_command_line_amendment(amendments, pipeline())

  // clean up HTML files before rendering
  case parameters.output_dir {
    Some(output_dir) -> {
      case cleanup_html_files(output_dir) {
        Ok(_) -> io.println("HTML cleanup completed")
        Error(error) -> io.println("HTML cleanup failed: " <> error)
      }
    }
    _ -> Nil
  }

  case vr.run_renderer(renderer, parameters, debug_options) {
    Error(error) -> io.println("\nrenderer error: " <> ins(error) <> "\n")
    _ -> Nil
  }
}
