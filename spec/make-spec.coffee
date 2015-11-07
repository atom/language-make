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

  it "selects the Makefile grammar for files that start with a hashbang make -f command", ->
    expect(atom.grammars.selectGrammar('', '#!/usr/bin/make -f')).toBe grammar

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

  it "parses nested interpolated strings and function calls correctly", ->
    waitsForPromise ->
      atom.packages.activatePackage("language-shellscript")

    runs ->
      lines = grammar.tokenizeLines 'default:\n\t$(eval MESSAGE=$(shell node -pe "decodeURIComponent(process.argv.pop())" "${MSG}"))'

      expect(lines[1][1]).toEqual value: '$(', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']
      expect(lines[1][2]).toEqual value: 'eval', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.eval.makefile']
      expect(lines[1][5]).toEqual value: '$(', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']
      expect(lines[1][6]).toEqual value: 'shell', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.shell.makefile']
      expect(lines[1][9]).toEqual value: '"', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.quoted.double.shell', 'punctuation.definition.string.begin.shell']
      expect(lines[1][10]).toEqual value: 'decodeURIComponent(process.argv.pop())', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.quoted.double.shell']
      expect(lines[1][11]).toEqual value: '"', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.quoted.double.shell', 'punctuation.definition.string.end.shell']
      expect(lines[1][14]).toEqual value: '${', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.quoted.double.shell', 'variable.other.bracket.shell', 'punctuation.definition.variable.shell']
      expect(lines[1][16]).toEqual value: '}', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.quoted.double.shell', 'variable.other.bracket.shell', 'punctuation.definition.variable.shell']
      expect(lines[1][18]).toEqual value: ')', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']
      expect(lines[1][19]).toEqual value: ')', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']

  it "parses `origin` and `flavor` correctly", ->
    waitsForPromise ->
      atom.packages.activatePackage("language-shellscript")

    runs ->
      lines = grammar.tokenizeLines 'default:\n\t$(origin 1)'

      expect(lines[1][1]).toEqual value: '$(', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']
      expect(lines[1][2]).toEqual value: 'origin', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'support.function.origin.makefile']
      expect(lines[1][4]).toEqual value: '1', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'meta.scope.function-call.makefile', 'variable.other.makefile']
      expect(lines[1][5]).toEqual value: ')', scopes: ['source.makefile', 'meta.scope.target.makefile', 'meta.scope.recipe.makefile', 'string.interpolated.makefile', 'punctuation.definition.variable.makefile']