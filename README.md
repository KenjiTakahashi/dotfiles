```fish
$ alias .f='git --git-dir="$HOME/.files/" --work-tree=$HOME'
$ git clone -b <branch> --bare git@github.com:KenjiTakahashi/dotfiles.git '.files'
$ .f checkout --recurse-submodules
$ .f config --local status.showUntrackedFiles no
```

where `<branch>` is one of:
* `core` - common base for all machines, use for defining new configs
* `zion`
* `apfel1`

### Why not `clone --separate-git-dir`?

Because most probably the `$HOME` directory is already not empty. So cloning into it will fail.
And cloning into temporary directory then `rsync`ing into `$HOME` will leave submodules with incorrect worktrees.

It can be made to work, but is actually more involved than the method above.

### Inspirations

* https://github.com/anandpiyer/.dotfiles
* https://codeberg.org/magie/dotfiles/src/branch/master
