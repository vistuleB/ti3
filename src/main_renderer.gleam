import blame.{type Blame, Src}
import gleam/io
import gleam/list
import gleam/result
import gleam/string.{inspect as ins}
import infrastructure as infra
import io_lines.{type OutputLine, OutputLine}
import main_pipeline.{main_pipeline}
import simplifile
import vxml.{type VXML}
import desugaring as ds

pub type FragmentType {
  Chapter(Int)
  Sub(Int, Int)  // Sub(chapter_number, sub_number)
  Index
}

type TI3Fragment(z) = ds.OutputFragment(FragmentType, z)
type BL = List(OutputLine)

pub type TI3SplitterError {
  NoChapters
  MoreThanOneIndex
  NoIndex
}

fn blame_us(message: String) -> Blame {
  Src([], message, 0, 0)
}

fn index_error(e: infra.SingletonError) -> TI3SplitterError {
  case e {
    infra.MoreThanOne -> MoreThanOneIndex
    infra.LessThanOne -> NoIndex
  }
}

fn ti3_splitter(
  root: VXML
) -> Result(List(TI3Fragment(VXML)), TI3SplitterError) {
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
  fragment: TI3Fragment(VXML),
) -> Result(TI3Fragment(BL), String) {
  let lines =
    list.flatten([
      [
        OutputLine(blame_us("index_emitter"), 0, "<!DOCTYPE html>"),
        OutputLine(blame_us("index_emitter"), 0, "<html>"),
        OutputLine(blame_us("index_emitter"), 0, "<head>"),
        OutputLine(blame_us("index_emitter"), 2, "<meta charset=\"utf-8\">"),
        OutputLine(blame_us("index_emitter"), 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1\">"),
        OutputLine(blame_us("index_emitter"), 2, "<meta name=\"description\" content=\"Table of contents for TI3 - Theoretische Informatik 2\">"),
        OutputLine(blame_us("index_emitter"), 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"ti3.css\" />"),
        OutputLine(blame_us("index_emitter"), 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        OutputLine(blame_us("index_emitter"), 2, "<script type=\"text/javascript\" id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>"),
        OutputLine(blame_us("index_emitter"), 2, "<script type=\"text/javascript\" src=\"./ti3.js\"></script>"),
        OutputLine(blame_us("index_emitter"), 2, "<title>TI3 - Index</title>"),
        OutputLine(blame_us("index_emitter"), 0, "</head>"),
        OutputLine(blame_us("index_emitter"), 0, "<body class=\"page-index\">"),
      ],
      vxml.vxml_to_html_output_lines(fragment.payload, 2, 2),
      [
        OutputLine(blame_us("index_emitter"), 0, "</body>"),
        OutputLine(blame_us("index_emitter"), 0, "</html>"),
        OutputLine(blame_us("index_emitter"), 0, ""),
      ],
    ])
  Ok(ds.OutputFragment(..fragment, payload: lines))
}

// chapter emitter - handles chapter fragments
fn chapter_emitter(
  fragment: TI3Fragment(VXML),
) -> Result(TI3Fragment(BL), String) {
  let assert Chapter(n) = fragment.classifier
  let lines =
    list.flatten([
      [
        OutputLine(blame_us("chapter_emitter"), 0, "<!DOCTYPE html>"),
        OutputLine(blame_us("chapter_emitter"), 0, "<html>"),
        OutputLine(blame_us("chapter_emitter"), 0, "<head>"),
        OutputLine(blame_us("chapter_emitter"), 2, "<meta charset=\"utf-8\">"),
        OutputLine(blame_us("chapter_emitter"), 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1\">"),
        OutputLine(blame_us("chapter_emitter"), 2, "<meta name=\"description\" content=\"Chapter " <> string.inspect(n) <> " of TI3 - Theoretische Informatik 2\">"),
        OutputLine(blame_us("chapter_emitter"), 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"ti3.css\" />"),
        OutputLine(blame_us("chapter_emitter"), 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        OutputLine(blame_us("chapter_emitter"), 2, "<script type=\"text/javascript\" id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>"),
        OutputLine(blame_us("chapter_emitter"), 2, "<script type=\"text/javascript\" src=\"./ti3.js\"></script>"),
        OutputLine(blame_us("chapter_emitter"), 2, "<title>TI3 - Chapter " <> string.inspect(n) <> "</title>"),
        OutputLine(blame_us("chapter_emitter"), 0, "</head>"),
        OutputLine(blame_us("chapter_emitter"), 0, "<body class=\"page-chapter chapter-" <> string.inspect(n) <> "\">"),
      ],
      vxml.vxml_to_html_output_lines(fragment.payload, 2, 2),
      [
        OutputLine(blame_us("chapter_emitter"), 0, "</body>"),
        OutputLine(blame_us("chapter_emitter"), 0, "</html>"),
        OutputLine(blame_us("chapter_emitter"), 0, ""),
      ],
    ])
  Ok(ds.OutputFragment(..fragment, payload: lines))
}

// sub-chapter emitter - handles sub fragments
fn sub_chapter_emitter(
  fragment: TI3Fragment(VXML),
) -> Result(TI3Fragment(BL), String) {
  let assert Sub(chapter_n, sub_n) = fragment.classifier
  let lines =
    list.flatten([
      [
        OutputLine(blame_us("sub_chapter_emitter"), 0, "<!DOCTYPE html>"),
        OutputLine(blame_us("sub_chapter_emitter"), 0, "<html>"),
        OutputLine(blame_us("sub_chapter_emitter"), 0, "<head>"),
        OutputLine(blame_us("sub_chapter_emitter"), 2, "<meta charset=\"utf-8\">"),
        OutputLine(blame_us("sub_chapter_emitter"), 2, "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1, minimum-scale=1\">"),
        OutputLine(blame_us("sub_chapter_emitter"), 2, "<meta name=\"description\" content=\"Section " <> string.inspect(chapter_n) <> "." <> string.inspect(sub_n) <> " of TI3 - Theoretische Informatik 2\">"),
        OutputLine(blame_us("sub_chapter_emitter"), 2, "<link rel=\"stylesheet\" type=\"text/css\" href=\"ti3.css\" />"),
        OutputLine(blame_us("sub_chapter_emitter"), 2, "<script type=\"text/javascript\" src=\"./mathjax_setup.js\"></script>"),
        OutputLine(blame_us("sub_chapter_emitter"), 2, "<script type=\"text/javascript\" id=\"MathJax-script\" async src=\"https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js\"></script>"),
        OutputLine(blame_us("sub_chapter_emitter"), 2, "<script type=\"text/javascript\" src=\"./ti3.js\"></script>"),
        OutputLine(blame_us("sub_chapter_emitter"), 2, "<title>TI3 - Chapter " <> string.inspect(chapter_n) <> ", Section " <> string.inspect(sub_n) <> "</title>"),
        OutputLine(blame_us("sub_chapter_emitter"), 0, "</head>"),
        OutputLine(blame_us("sub_chapter_emitter"), 0, "<body class=\"page-sub chapter-" <> string.inspect(chapter_n) <> " sub-" <> string.inspect(sub_n) <> "\">"),
      ],
      vxml.vxml_to_html_output_lines(fragment.payload, 2, 2),
      [
        OutputLine(blame_us("sub_chapter_emitter"), 0, "</body>"),
        OutputLine(blame_us("sub_chapter_emitter"), 0, "</html>"),
        OutputLine(blame_us("sub_chapter_emitter"), 0, ""),
      ],
    ])
  Ok(ds.OutputFragment(..fragment, payload: lines))
}

// main emitter that dispatches to appropriate sub-emitters
fn our_emitter(
  fragment: TI3Fragment(VXML),
) -> Result(TI3Fragment(BL), String) {
  case fragment.classifier {
    Index -> index_emitter(fragment)
    Chapter(_) -> chapter_emitter(fragment)
    Sub(_, _) -> sub_chapter_emitter(fragment)
  }
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
            // io.println("Deleted: " <> file_path)
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

pub fn main_renderer(amendments: ds.CommandLineAmendments) -> Nil {
  let renderer =
    ds.Renderer(
      assembler: ds.default_assembler(amendments.only_paths),
      parser: ds.default_writerly_parser(echo amendments.only_key_values),
      pipeline: main_pipeline(),
      splitter: ti3_splitter,
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
    )
    |> ds.amend_renderer_paramaters_by_command_line_amendments(amendments)

  let debug_options =
    ds.default_renderer_debug_options()
    |> ds.amend_renderer_debug_options_by_command_line_amendments(amendments)

  // clean up HTML files before rendering
  case cleanup_html_files(parameters.output_dir) {
    Ok(_) -> io.println("HTML cleanup completed")
    Error(error) -> io.println("HTML cleanup failed: " <> error)
  }
  
  case ds.run_renderer(renderer, parameters, debug_options) {
    Error(error) -> io.println("\nrenderer error: " <> ins(error) <> "\n")
    _ -> Nil
  }
}
