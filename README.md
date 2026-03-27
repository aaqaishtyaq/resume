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
./result/aaqa-ishtyaq-resume.pdf
./result/aaqa-ishtyaq-resume.html
./result/aaqa-ishtyaq-resume.css
./result/aaqa-ishtyaq-resume.build-info.json
```

`result` is a symlink to the Nix store output.
The build info JSON includes deterministic metadata for the artifact bundle,
including the flake revision and `lastModifiedDate` when available.

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
- includes `aaqa-ishtyaq-resume.pdf` as a downloadable asset
- exposes `aaqa-ishtyaq-resume.build-info.json` with the published site files

To enable publishing:

1. Push the workflow to GitHub.
2. In the repository settings, open `Pages`.
3. Set the source to `GitHub Actions`.

After that, each push to `trunk` will deploy the latest HTML resume to GitHub
Pages.

## GitHub Release

The repository also includes
[`/.github/workflows/release-pdf.yml`](.github/workflows/release-pdf.yml).

On pushes to `trunk`, it builds the resume and updates a release tagged
`resume-pdf` with these assets:

```sh
aaqa-ishtyaq-resume.pdf
aaqa-ishtyaq-resume.build-info.json
```
