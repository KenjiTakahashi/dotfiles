```fish
alias .f='git --git-dir="$HOME/.files/" --work-tree=$HOME'
git clone -b <branch> --bare git@github.com:KenjiTakahashi/dotfiles.git '.files'
.f checkout --recurse-submodules
.f config --local status.showUntrackedFiles no
```

where `<branch>` is one of:
* `core` - common base for all machines, use for defining new configs
* `zion`
* `apfel1`

### Other Commands

```fish
go install golang.org/x/tools/gopls@latest
```
```fish
go install github.com/rinchsan/gosimports/cmd/gosimports@latest
```
```fish
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```
```fish
go install github.com/nametake/golangci-lint-langserver@latest
```

```fish
npm i -g typescript typescript-language-server vscode-langservers-extracted
```

### Why not `clone --separate-git-dir`?

Because most probably the `$HOME` directory is already not empty. So cloning into it will fail.
And cloning into temporary directory then `rsync`ing into `$HOME` will leave submodules with incorrect worktrees.

It can be made to work, but is actually more involved than the method above.

### Inspirations

* https://github.com/anandpiyer/.dotfiles
* https://codeberg.org/magie/dotfiles/src/branch/master
