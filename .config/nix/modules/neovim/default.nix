{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins =
      let
        nvim-treesitter-with-plugins = pkgs.vimPlugins.nvim-treesitter.withPlugins (
          treesitter-plugins: with treesitter-plugins; [
            bash
            c
            css
            dockerfile
            go
            hcl
            html
            javascript
            jq
            json
            lua
            make
            markdown
            markdown_inline
            nginx
            nix
            rego
            sql
            tmux
            typescript
            vim
            yaml
          ]
        );

        vim-jsx-improve = pkgs.vimUtils.buildVimPlugin {
          name = "vim-jsx-improve";
          src = pkgs.fetchFromGitHub {
            owner = "neoclide";
            repo = "vim-jsx-improve";
            rev = "b179bf9a3901ccc6afcaa3abc9c93bae450f3339";
            sha256 = "sha256-/GygNrw+K4q3TBTz7hZxQwRbGCtwVXbZ4dbDlOGV8Bs=";
          };
        };
      in
      with pkgs.vimPlugins;
      [
        # LSP
        nvim-lspconfig

        # Completions
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        cmp-vsnip
        vim-vsnip

        # TreeSitter
        nvim-treesitter-with-plugins

        # Telescope
        plenary-nvim
        telescope-nvim

        # UI
        lightline-vim
        vim-gitgutter

        # Language specific
        vim-terraform
        vim-jsx-improve
        vim-prettier

        # Copilot
        copilot-lua
        CopilotChat-nvim
      ];

    extraConfig = lib.fileContents ./init.vim;
    extraLuaConfig = lib.fileContents ./init.lua;
  };

  # Create ftplugin files for language-specific configuration
  home.file.".config/nvim/ftplugin/go.vim".source = ./ftplugin/go.vim;
  home.file.".config/nvim/ftplugin/javascript.vim".source = ./ftplugin/javascript.vim;
  home.file.".config/nvim/ftplugin/json.vim".source = ./ftplugin/json.vim;
  home.file.".config/nvim/ftplugin/sh.vim".source = ./ftplugin/sh.vim;
  home.file.".config/nvim/ftplugin/typescript.vim".source = ./ftplugin/typescript.vim;
  home.file.".config/nvim/ftplugin/yaml.vim".source = ./ftplugin/yaml.vim;
}
