# TI2

## 1. Gleam Install

[here](https://gleam.run/getting-started/installing)

## 2. Clone repos

Git clone `github.com/vistuleB/wly` and `github.com/vistuleB/ti2` next to each other in the same folder.

*SSH*

```
git clone git@github.com:vistuleB/wly.git
```
```
git clone git@github.com:vistuleB/ti2.git
```

*HTTPS*

```
git clone https://github.com/vistuleB/wly.git
```
```
git clone https://github.com/vistuleB/ti2.git
```

## 3. 'wly' test

1. `cd wly/desugaring`
3. `gleam run -m desugarers`

Various output should come out like this:

![wly/desugaring gleam run -m desugarers terminal output](writerly-desugaring-m-terminal-output.png)

## 4. 'ti2' test

1. go to `ti2` repo
2. `rm public/*.html`
3. `gleam run`

Various messages from the desugaring engine (situated in `wly` repo) should print out and the `public/` folder should have its .html repopulated.

To check, open `public/index.html` inside a browser.

## 5. Source location

Author source is contained in `ti2/wly/` folder.

In VSCode, download ["Writerly"](https://marketplace.visualstudio.com/items?itemName=TabbyNotes.writerly-vscode-extension) for syntax highlighting.

## 6. Formatter

Run `gleam run -- --fmt` in `ti2` repo for default 55 to reformat at char per line formatting or `gleam run -- --fmt 65` to format line length to 65 chars per line.

