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
