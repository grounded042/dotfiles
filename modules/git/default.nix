{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.git = {
    enable = true;

    userName = "Jon Carl";
    userEmail = "grounded042@joncarl.com";

    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKq+/aX9bH1PAyJXY9q1huLgPzQfkcokYryhiwMl6kw";
      signByDefault = true;
    };

    extraConfig = {
      user = {
        useConfigOnly = true;
      };

      github = {
        user = "grounded042";
        token = "MOVEALONG";
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
      };

      apply = {
        whitespace = "nowarn";
      };

      rerere = {
        enabled = 1;
      };

      difftool = {
        prompt = false;
      };

      diff = {
        tool = "diffmerge";
      };

      init = {
        templatedir = "~/.dotfiles/.git_template";
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
      };

      credential = {
        helper = "cache";
      };

      "filter \"tabspace\"" = {
        clean = "expand -t 4";
      };

      push = {
        default = "simple";
      };

      "filter \"media\"" = {
        required = true;
        clean = "git media clean %f";
        smudge = "git media smudge %f";
      };

      commit = {
        gpgsign = true;
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

      pull = {
        rebase = true;
      };

      gpg = {
        format = "ssh";
      };

      "gpg \"ssh\"" = {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };

    aliases = {
      # most commonly used
      co = "checkout";
      d = "diff --color-words";
      cam = "commit -a -m";
      upm = "!git fetch upstream && git merge upstream/master";

      # least used
      br = "branch -a";
      s = "status -s -u";
      cl = "log --stat -C -2";
      c = "commit";
      dh = "diff HEAD";
      dc = "diff --staged";
      dw = "diff --word-diff";
      dcw = "diff --color-words";
      dm = "!git diff | subl";
      dv = "!git diff | vim";
      who = "shortlog -s --";
      ph = "push";
      pl = "pull";
      lp = "log -p";
      lod = "log --oneline --decorate";
      lg = "log --graph";
      lpo = "log --pretty=oneline --abbrev-commit --graph --decorate --all";
      l1 = "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
      l2 = "log --graph --all --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      spull = "!git-svn fetch && git-svn rebase";
      spush = "!git-svn dcommit";
      sync = "!git pull && git push";
      es = "!git pull --rebase && git push";
      lf = "log --pretty=fuller";
      ignorechanges = "update-index --assume-unchanged";
      noticechanges = "update-index --no-assume-unchanged";
      gc-ap = "gc --aggressive --prune";
      listconf = "config --global --list";
      lsm = "log -M --stat";
      hse = "log --stat -5";
      diffall = "diff HEAD";
      logr = "log -M";
      logr2 = "log --stat -M -2";
      logit = "log --stat -M";
      scrub = "!git reset --hard && git clean -fd";
      pub = "!git pub checkout master && git pull && git checkout dev && git rebase master && git checkout master && git merge dev && git wtf";
      cs = "status";
      rv = "remote -v";
      lwr = "log --stat -C";
      pur = "pull --rebase";
      whatis = "show -s --pretty='tformat:%h (%s, %ad)' --date=short";
      orphank = "!gitk --all `git reflog | cut -c1-7`&";
      orphanl = "!git log --pretty=oneline --abbrev-commit --graph --decorate `git reflog | cut -c1-7`";
      k = "!exec gitk --all&";
      testecho1 = "!sh -c 'echo with slash: zero=$0 one=$1 two=$2' -";
      testecho2 = "!sh -c 'echo without slash: zero=$0 one=$1 two=$2'";
      st = "status";
      l = "log --stat -C";
      ll = "log --stat -C -3";
      servehere = "daemon --verbose --informative-errors --reuseaddr --export-all --base-path=. --enable=receive-pack";
      purgeme = "!git clean -fd && git reset --hard";
      prunenow = "gc --prune=now";
      ri = "rebase --interactive --autosquash";
      lol = "log --pretty=oneline --graph --abbrev-commit --all";
      blg = "log --graph --decorate --all --abbrev-commit --pretty=oneline";
      slog = "log --graph --simplify-by-decoration --all --abbrev-commit --pretty=oneline";
      lgso = "log --graph --date=short --pretty=format:'%C(yellow)%h%Creset %cn%x09%cd %s%C(green bold)%d'";
      ro = "!git fetch origin && git reset --hard origin/master";
      shorten = "!sh -c 'curl -i http://git.io -F url=$1' -";
      pushnotes = "!sh -c 'git push $1 refs/notes/*' -";
      fetchnotes = "!sh -c 'git fetch $1 refs/notes/*:refs/notes/*' -";
      showignored = "clean -ndX";
      showignored2 = "ls-files --others --ignored --exclude-standard";
      showuntracked = "ls-files --others --exclude-standard";
      rmmissing = "!git rm $(git ls-files --deleted)";
      mergekeepoursonly = "merge -s ours";
      redocommit = "reset --soft HEAD^";
      listunstaged = "diff --name-status";
      liststaged = "diff --name-status --staged";
      listhistory = "log --name-status";
      logn = "log --oneline --name-only";
      busypeople = "shortlog -6";
      busythisweek = "shortlog --since=one.week.ago";
      configpushtracking = "config push.default tracking";
      configpushnothing = "config push.default nothing";
      configpushmatching = "config push.default matching";
      configpushcurrent = "config push.default current";
      nr = "!sh -c 'git init $0'";
      echoparam1 = "!sh -c 'echo $0'";
      fixup = "!sh -c 'git commit -m \"fixup! $(git log -1 --format='\\''%s'\\'' $@)\"' -";
      squash = "!sh -c 'git commit -m \"squash! $(git log -1 --format='\\''%s'\\'' $@)\"' -";
      ccfq = "!sh -c 'git add $1 && git commit -m\"Placeholder\"' -";
      cob = "checkout -b";
      sno = "show --name-only";
      logsimple = "log --graph --abbrev-commit --pretty=oneline --all --decorate";
    };
  };
}
