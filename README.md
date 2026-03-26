# Aaqa's Resume

This repository contains Aaqa Ishtyaq's resume, built with a pinned Nix
toolchain for reproducible PDF and HTML outputs.

## Requirements

- [Nix](https://nixos.org/download/)
- Flakes enabled

## Build

Build the resume outputs with:

```sh
nix build '.#resume'
```

The generated files will be available at:

```sh
./result/resume.pdf
./result/resume.html
./result/resume.css
```

`result` is a symlink to the Nix store output.

## Local editing shell

Open a shell with the pinned LaTeX toolchain:

```sh
nix develop
```

Then build locally with `latexmk`:

```sh
latexmk -pdf -interaction=nonstopmode -halt-on-error -output-directory=build resume.tex
```

Generate HTML locally with:

```sh
make4ht -d build/html resume.tex
mkdir -p build/html/fonts
cp "$(nix develop --command sh -lc 'T=$(kpsewhich -var-value=TEXMFMAIN); printf %s \"$T/fonts/opentype/public/lm/lmroman10-regular.otf\"')" build/html/fonts/
cp "$(nix develop --command sh -lc 'T=$(kpsewhich -var-value=TEXMFMAIN); printf %s \"$T/fonts/opentype/public/lm/lmroman10-bold.otf\"')" build/html/fonts/
cp "$(nix develop --command sh -lc 'T=$(kpsewhich -var-value=TEXMFMAIN); printf %s \"$T/fonts/opentype/public/lm/lmroman10-italic.otf\"')" build/html/fonts/
cat resume-html-overrides.css >> build/html/resume.css
```

This writes intermediate files to `./build/`.

## GitHub Pages

The repository includes a GitHub Pages workflow at
[`/.github/workflows/pages.yml`](.github/workflows/pages.yml).

On pushes to `trunk`, the workflow:

- builds the PDF and HTML with `nix build '.#resume'`
- publishes the HTML as `index.html`
- includes `resume.pdf` as a downloadable asset

To enable publishing:

1. Push the workflow to GitHub.
2. In the repository settings, open `Pages`.
3. Set the source to `GitHub Actions`.

After that, each push to `trunk` will deploy the latest HTML resume to GitHub
Pages.
