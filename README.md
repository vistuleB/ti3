# ti2

## 1. Install Gleam

[Official instructions.](https://gleam.run/getting-started/installing)

## 2. Git clone wly library & ti2 project

In your github folder, or other favorite, git clone the `vistuleB/wly` and `vistuleB/ti2` repos.

ssh:

```
git clone git@github.com:vistuleB/wly.git
```
```
git clone git@github.com:vistuleB/ti2.git
```

https:

```
git clone https://github.com/vistuleB/wly.git
```
```
git clone https://github.com/vistuleB/ti2.git
```

## 3. Test the library

1. `cd wly/desugaring`
3. `gleam run -m desugarers`

If everything is ok some messages with green squares "✅✅✅" will be output. (No need to read.)

## 4. Test ti2

1. `cd ../ti2` or `cd ti2`, depending on your location
2. `rm public/*.html` (⚠️ careful to type `public/*.html` and not `public/*`, or else you will lose your javascript and CSS files ⚠️)
3. `gleam run`

Various messages from the desugaring engine (situated in `wly` repo) should print out and the `public/` folder should have its .html repopulated.

You can open the `index.html` inside the `public` folder directly inside a browser to check.

## 5. Download the Writerly (.wly) extension for VSCode & browse source

Search for ["Writerly"](https://marketplace.visualstudio.com/items?itemName=TabbyNotes.writerly-vscode-extension) in the VSCode extension marketplace. Install.

Author source is contained inside `ti2/wly/`. Browse that directory to get an idea for the markup structure.

The `.wly` source files should be syntax highlighted.

## Bonus: Running the formatter

Run `gleam run -- --fmt` for default 55 to reformat at char per line formatting.

Run e.g. `gleam run -- --fmt 65` to format line length to 65 chars per line, etc.

