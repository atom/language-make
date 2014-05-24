path = require 'path'

module.exports =
  activate: (state) ->
    forceHardTabsForMakefiles()

forceHardTabsForMakefiles = () ->
  atom.workspaceView.eachEditorView (editorView) ->
    editor = editorView.getEditor()
    grammarScope = editor.getGrammar()['scopeName']
    if grammarScope is 'text.plain.null-grammar'
      hardTabsBasedOnFileType(editor)
    if grammarScope is 'source.makefile'
      editor.setSoftTabs(false)

hardTabsBasedOnFileType = (editor) ->
  fileTypes = [
    'Makefile'
    'makefile'
    'GNUmakefile'
    'OCamlMakefile'
    'mk'
  ]
  if path.basename(editor.getPath()) in fileTypes
    editor.setSoftTabs(false)
