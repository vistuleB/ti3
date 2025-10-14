# ti2

## Installing Gleam

[Official instructions.](https://gleam.run/getting-started/installing)

## Installing the VSCode Writerly extension

Search for ["Writerly"](https://marketplace.visualstudio.com/items?itemName=TabbyNotes.writerly-vscode-extension) in the extension marketplace.

## Running the project

1. Clone the markup parsing & desugaring library: `git clone github.com/vistuleB/wly`.
2. Check that works by running `gleam build` and `gleam run -m desugarers` from inside that repo's `desugaring/` folder.
3. Clone the `ti2` coursenotes repo: `git clone github.com/vistuleB/ti2`.
4. Try `gleam build` and `gleam run` from inside that repo's root folder. Also try `gleam run -- --help`.

## Running the formatter

Run `gleam run -- --fmt` for default 55 char per line formatting.

Run e.g. `gleam run -- --fmt 65` to format line length to 65 chars per line.

Run e.g. `gleam run -- --fmt 70 4` to subtract 4 chars from the line length at each level of indentation (and achieve uniform right-hand margin at 70 chars per "outermost" line).

## To view local output

Open `file:///PATH/TO/REPO/ti2/public/index.html` in a browser with `PATH/TO/REPO` suitably replaced.

## Serve on local server and mobile

1. Instal npm packages with `npm install`.
2. `npm run dev` to start the local server.

### To preview on mobile

Run `npm run dev` on local machine.

Visit the shown url on mobile to access the page. Requires the mobile
device and the local machine to share the same local network.

A sample output
```
Available on:
  http://127.0.0.1:8080
  http://192.168.0.105:8080
Hit CTRL-C to stop the server
Open: http://127.0.0.1:8080/index.html
```

## Web version

https://ti2.netlify.app/
