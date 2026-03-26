{
  description = "Build the resume PDF with a pinned Nix toolchain";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive)
              latexmk
              lm
              luaxml
              scheme-small
              geometry
              hyperref
              parskip;
          };
          mainFile = "resume.tex";
          pdfName = builtins.replaceStrings [ ".tex" ] [ ".pdf" ] mainFile;
        in
        rec {
          resume = pkgs.stdenvNoCC.mkDerivation {
            pname = "resume";
            version = "1.0.0";
            src = ./.;

            nativeBuildInputs = [
              tex
            ];

            buildPhase = ''
              runHook preBuild

              export HOME="$TMPDIR"
              export TEXMFVAR="$TMPDIR/texmf-var"

              mkdir -p build/pdf build/html

              latexmk \
                -pdf \
                -interaction=nonstopmode \
                -halt-on-error \
                -output-directory=build/pdf \
                ${mainFile}

              make4ht \
                -d build/html \
                ${mainFile}

              lm_dir="$(kpsewhich -var-value=TEXMFMAIN)/fonts/opentype/public/lm"
              mkdir -p build/html/fonts
              cp "$lm_dir/lmroman10-regular.otf" build/html/fonts/
              cp "$lm_dir/lmroman10-bold.otf" build/html/fonts/
              cp "$lm_dir/lmroman10-italic.otf" build/html/fonts/

              cat resume-html-overrides.css >> "build/html/${builtins.replaceStrings [ ".tex" ] [ ".css" ] mainFile}"

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p "$out"
              cp "build/pdf/${pdfName}" "$out/${pdfName}"
              cp -R build/html/. "$out/"

              runHook postInstall
            '';
          };

          default = resume;
        });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive)
              latexmk
              lm
              luaxml
              scheme-small
              geometry
              hyperref
              parskip;
          };
        in
        {
          default = pkgs.mkShell {
            packages = [
              tex
            ];
          };
        });
    };
}
