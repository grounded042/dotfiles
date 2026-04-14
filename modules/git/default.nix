{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.git = {
    enable = true;

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKq+/aX9bH1PAyJXY9q1huLgPzQfkcokYryhiwMl6kw";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Jon Carl";
        email = "grounded042@joncarl.com";
        useConfigOnly = true;
      };

      github = {
        user = "grounded042";
      };

      color = {
        ui = "auto";
        branch = {
          current = "yellow reverse";
          local = "yellow";
          remote = "green";
        };
        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red bold";
          new = "green bold";
        };
        status = {
          added = "yellow";
          changed = "green";
          untracked = "cyan";
        };
      };

      advice = {
        statusHints = false;
      };

      gui = {
        fontdiff = "-family Monaco -size 10 -weight normal -slant roman -underline 0 -overstrike 0";
      };

      core = {
        excludesfile = "~/.gitignore";
        quotepath = false;
        autocrlf = "input";
        safecrlf = "warn";
        editor = "vim";
        # faster git status via filesystem monitoring
        fsmonitor = true;
        # cache untracked file info for performance
        untrackedCache = true;
      };

      apply = {
        whitespace = "nowarn";
      };

      # format list output (branches, tags) in columns
      column.ui = "auto";

      # sort branches by most recent commit
      branch.sort = "-committerdate";

      # sort tags by semantic version
      tag.sort = "version:refname";

      rerere = {
        enabled = 1;
        # automatically stage rerere-resolved conflicts
        autoupdate = true;
      };

      difftool = {
        prompt = false;
      };

      diff = {
        tool = "diffmerge";
        # better diff output than default myers
        algorithm = "histogram";
        # highlight moved code blocks in diffs
        colorMoved = "plain";
        # use i/ (index) and w/ (worktree) instead of a/ and b/
        mnemonicPrefix = true;
        # detect file renames in diffs
        renames = true;
      };

      init = {
        # default branch name for new repos
        defaultBranch = "main";
      };

      mergetool = {
        prompt = false;
        keepBackup = false;
      };

      "difftool \"diffmerge\"" = {
        cmd = "diffmerge \"$LOCAL\" \"$REMOTE\"";
      };

      "mergetool \"diffmerge\"" = {
        cmd = "diffmerge --merge --result=\"$MERGED\" \"$LOCAL\" \"$(if test -f \"$BASE\"; then echo \"$BASE\"; else echo \"$LOCAL\"; fi)\" \"$REMOTE\"";
        trustExitCode = true;
      };

      merge = {
        tool = "diffmerge";
        stat = true;
        # show original base in conflict markers
        conflictstyle = "zdiff3";
      };

      credential = {
        helper = "cache";
      };

      "filter \"tabspace\"" = {
        clean = "expand -t 4";
      };

      push = {
        default = "simple";
        # auto-create upstream tracking on first push
        autoSetupRemote = true;
      };

      fetch = {
        # remove stale remote-tracking refs
        prune = true;
        # remove stale remote tags
        pruneTags = true;
        # fetch from all remotes
        all = true;
      };

      "filter \"media\"" = {
        required = true;
        clean = "git media clean %f";
        smudge = "git media smudge %f";
      };

      "url \"ssh://git@github.com/\"" = {
        insteadOf = "https://github.com/";
      };

      "filter \"lfs\"" = {
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
      };

      # suggest corrections for mistyped commands
      help.autocorrect = "prompt";

      rebase = {
        # auto-squash fixup! commits during rebase
        autoSquash = true;
        # auto-stash before rebase
        autoStash = true;
        # move stacked branch pointers on rebase
        updateRefs = true;
      };

      pull = {
        rebase = true;
      };

      gpg = {
        format = "ssh";
      };

      "gpg \"ssh\"" = lib.mkMerge [
        (lib.mkIf pkgs.stdenv.isDarwin {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        })
        (lib.mkIf pkgs.stdenv.isLinux {
          program = lib.getExe' pkgs._1password-gui "op-ssh-sign";
        })
      ];

      alias = {};
    };
  };
}
