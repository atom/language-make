# Make language support in Atom [![Build Status](https://travis-ci.org/atom/language-make.svg?branch=master)](https://travis-ci.org/atom/language-make)

Adds syntax highlighting to [Makefiles](http://www.gnu.org/software/make/manual/make.html)
in Atom.

Originally [converted](http://atom.io/docs/latest/converting-a-text-mate-bundle)
from the [Make TextMate bundle](https://github.com/textmate/make.tmbundle).

Contributions are greatly appreciated. Please fork this repository and open a
pull request to add snippets, make grammar tweaks, etc.

## Development

Grammar is generated from files in `src/`.  Lists of language variables and functions are
generated from parsing [GNU Make Manual](http://www.gnu.org/software/make/manual/make.html).
For re-generating `makefile.cson`, simply run package tests or run
```
    $ coffee src/makefile.coffee
```

If it happens while running package tests, that you get a timeout in the first
place, this is most likely, that fetching gnu make manual took a while.
