# ti2

## 1. Install Gleam

[Official instructions.](https://gleam.run/getting-started/installing)

## 2. Git clone wly library & ti2 project

In your github folder, or other favorite, git clone the `vistuleB/wly` and `vistuleB/ti2` repos.

*SSH:*

```
>>> git clone github.com/vistuleB/wly
>>> git clone github.com/vistuleB/ti2
```

*HTTPS:*

```
>>> git clone github.com/vistuleB/wly
>>> git clone github.com/vistuleB/ti2
```

## 3. Test the desugaring library

1. `cd wly/desugaring` (⚠️⚠️⚠️⚠️⚠️ it's `wly/desugaring` not `wly`)
3. `gleam run -m desugarers`

If everything is ok some messages with green squares "✅✅✅" will be output. (No need to read.)

## 4. Test ti2

1. `cd ../ti2` or `cd ti2`, depending on your location
2. `rm public/*.html` (⚠️⚠️⚠️⚠️⚠️ be careful to type `public/*.html` and not `public/*`, or else you will lose your javascript and CSS files!)
3. `gleam run`

Various messages from the desugaring engine (situated in `wly` repo) should print out, and the `public/` folder should have its .html repopulated.

Open the `index.html` inside the `public` folder directly inside your browser to check.

## 5. Download the Writerly (.wly) extension for VSCode & browse source

Search for ["Writerly"](https://marketplace.visualstudio.com/items?itemName=TabbyNotes.writerly-vscode-extension) in the VSCode extension marketplace. Install.

The book source is contained inside `ti2/wly/`. Browse that directory and those files to get an idea for the markup structure, and how the source is arranged into a tree.

The `.wly` files should syntax highlight after the extension is installed.

## 6. Running the formatter

Run `gleam run -- --fmt` for default 55 to reformat at char per line formatting.

Run e.g. `gleam run -- --fmt 65` to format line length to 65 chars per line, etc.

