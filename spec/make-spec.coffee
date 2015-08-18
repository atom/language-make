describe "Makefile grammar", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-make")

    runs ->
      grammar = atom.grammars.grammarForScopeName("source.makefile")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "source.makefile"

  it "parses recipes", ->
    lines = grammar.tokenizeLines 'all: foo.bar\n\ttest\n\nclean: foo\n\trm -fr foo.bar'

    expect(lines[0][0]).toEqual value: 'all', scopes: ['source.makefile', 'meta.scope.target.makefile', 'entity.name.function.target.makefile']
    expect(lines[3][0]).toEqual value: 'clean', scopes: ['source.makefile', 'meta.scope.target.makefile', 'entity.name.function.target.makefile']

  it "parses function calls", ->
    {tokens} = grammar.tokenizeLine 'foo: echo $(basename /foo/bar.txt)'
    expect(tokens[4]).toEqual value: 'basename', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.prerequisites.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.basename.makefile']

  it "parses targets with line breaks in body", ->
    lines = grammar.tokenizeLines 'foo:\n\techo $(basename /foo/bar.txt)'

    expect(lines[1][3]).toEqual value: 'basename', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.basename.makefile']

  it "selects the Makefile grammar for files that start with a hashbang make -f command", ->
    expect(atom.grammars.selectGrammar('', '#!/usr/bin/make -f')).toBe grammar
