# Landing page

Source for <https://rakkunn.github.io/DualClip/>, served by GitHub Pages from this folder.

## The page is prerendered

`index.html` is **generated — do not edit it**. It is committed because GitHub
Pages serves this folder as-is, with no build step of its own.

```
index.template.html   page shell: <head>, meta tags, script tags
components/*.jsx      markup, rendered by React at build time only
app.jsx               composes the sections
build.mjs             renders <App/> to static HTML → index.html
site.js               the only JavaScript the browser receives
styles.css            base tokens, primitives
sections.css          per-section layout
```

## Editing

```bash
cd docs
npm install       # once
npm run build     # regenerates index.html
```

Then open `index.html` directly, or `python3 -m http.server` from this folder.
Commit the regenerated `index.html` along with your source changes.

## Why it works this way

The page used to ship React, ReactDOM (development builds) and
`@babel/standalone` to every visitor and compile JSX in the browser — roughly
2.5 MB of JavaScript before anything appeared, and an empty `<body>` for any
crawler or preview bot that doesn't execute scripts. React now runs only here,
at build time.

That means **markup must be renderable without a browser**. Components take no
`useState` and touch no DOM APIs; they render the page's first frame, and
`site.js` takes over from there:

- rotating the highlighted slot in the hero popover
- advancing the three-step storyboard (and pausing it when you click a step)
- switching demo tabs
- the copy-to-clipboard buttons
- the theme toggle, which now also follows `prefers-color-scheme` and
  remembers your choice

Anything with two visual states — the copy button, the theme icons, the demo
panels — ships both states in the HTML and toggles a class, rather than being
constructed in JS.

`build.mjs` evaluates the components in a bare sandbox with only `React` and
`window` available, so a component that reaches for the DOM at module scope
fails the build instead of silently shipping a page that renders empty.
