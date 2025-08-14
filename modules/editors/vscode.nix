{ pkgs, pkgs-unstable, ... }:

{
  rso.home.programs.vscode = {
    enable = true;

    profiles.default = {
      extensions =
        with pkgs.vscode-extensions;
        [
          eamodio.gitlens
          streetsidesoftware.code-spell-checker
          tomoki1207.pdf # pdf preview
          mkhl.direnv

          jnoortheen.nix-ide
          rust-lang.rust-analyzer
          tamasfe.even-better-toml
          hashicorp.terraform
          hashicorp.hcl
          redhat.java
          golang.go
          vue.volar
          esbenp.prettier-vscode
          samuelcolvin.jinjahtml
          mkhl.direnv
        ]
        ++ (with pkgs-unstable.vscode-extensions; [
          myriad-dreamin.tinymist # typst
        ])
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "code-spell-checker-swedish";
            publisher = "streetsidesoftware";
            version = "1.3.1";
            hash = "sha256-o5N8BMYtjCm4EWOqjNmH9VaHrcHB6swFqPqiyumCJKU=";
          }
        ];

      userSettings = {
        "files.autoSave" = "onFocusChange";
        "files.insertFinalNewline" = true;
        "files.trimFinalNewlines" = true;
        "editor.formatOnSave" = true;
        "editor.rulers" = [ 80 ];
        "cSpell.language" = "en,sv";

        "nix.formatterPath" = [
          "nix"
          "fmt"
        ];
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "nix.serverSettings" = {
          nil = {
            formatting = {
              command = [
                "nix"
                "fmt"
              ];
            };
          };
        };

        "tinymist.exportPdf" = "onDocumentHasTitle";
        "tinymist.formatterMode" = "typstyle";
        "[typst]" = {
          "editor.wordSeparators" = "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/?";
        };
      }
      // (
        let
          prettierLangs = [
            "javascript"
            "typescript"
            "json"
            "jsonc"
            "html"
            "css"
            "scss"
            "markdown"
            "yaml"
            "vue"
            "graphql"
            "typescriptreact"
            "javascriptreact"
          ];
          withBrackets = map (lang: "[${lang}]") prettierLangs;
          scope = builtins.concatStringsSep "" withBrackets;
        in
        {
          ${scope}."editor.defaultFormatter" = "esbenp.prettier-vscode";
        }
      );

      keybindings = [
        {
          key = "alt+t";
          command = "editor.action.goToTypeDefinition";
        }
        {
          key = "shift+alt+up";
          command = "editor.action.copyLinesUpAction";
          when = "editorTextFocus && !editorReadonly";
        }
        {
          key = "shift+alt+down";
          command = "editor.action.copyLinesDownAction";
          when = "editorTextFocus && !editorReadonly";
        }
      ];
    };
  };
}
