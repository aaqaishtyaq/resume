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
          artifactBase = "aaqa-ishtyaq-resume";
          version = "1.0.0";
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
          sourceBase = builtins.replaceStrings [ ".tex" ] [ "" ] mainFile;
          sourcePdfName = "${sourceBase}.pdf";
          sourceHtmlName = "${sourceBase}.html";
          sourceCssName = "${sourceBase}.css";
          pdfName = "${artifactBase}.pdf";
          htmlName = "${artifactBase}.html";
          cssName = "${artifactBase}.css";
          buildInfoName = "${artifactBase}.build-info.json";
          buildInfo = pkgs.writeText buildInfoName (builtins.toJSON {
            artifact = artifactBase;
            inherit version system;
            source = mainFile;
            revision = self.rev or self.dirtyRev or self.dirtyRevision or null;
            shortRevision = self.shortRev or self.dirtyShortRev or null;
            lastModifiedDate = self.lastModifiedDate or null;
            outputs = {
              pdf = pdfName;
              html = htmlName;
              css = cssName;
              fonts = "fonts";
            };
          });
        in
        rec {
          resume = pkgs.stdenvNoCC.mkDerivation {
            pname = "resume";
            inherit version;
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

              cat resume-html-overrides.css >> "build/html/${sourceCssName}"
              sed -i "s|href='${sourceCssName}'|href='${cssName}'|" "build/html/${sourceHtmlName}"
              sed -i "s|<title></title>|<title>Aaqa Ishtyaq Resume</title>|" "build/html/${sourceHtmlName}"

              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall

              mkdir -p "$out"
              cp "build/pdf/${sourcePdfName}" "$out/${pdfName}"
              cp "build/html/${sourceHtmlName}" "$out/${htmlName}"
              cp "build/html/${sourceCssName}" "$out/${cssName}"
              cp -R build/html/fonts "$out/fonts"
              cp ${buildInfo} "$out/${buildInfoName}"

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
