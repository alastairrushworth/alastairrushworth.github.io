# alastairrushworth.github.io

My personal site — a tiny, static, terminal-style index of things I've made,
served at the root of `alastairrushworth.github.io`. No build step.

Because this is the user-site repo, my other project repos that don't set their
own custom domain are published alongside it at `alastairrushworth.github.io/<repo>`.

```
index.html        # the homepage (HTML + inline CSS, monospace dark theme)
recipes/index.html# a few recipes
favicon.svg       # site icon
.nojekyll         # serve files as-is (don't run Jekyll)
.github/workflows/deploy.yml  # deploy to Pages via GitHub Actions
```

## Editing

- **Projects:** copy a `<li><a class="row">…</a></li>` block in `index.html`.
- **Recipes:** edit `recipes/index.html` (or add a new `<section id="…">`).

## Deploy

Pushing to `main` triggers the GitHub Actions workflow, which publishes the
repo root to GitHub Pages.
