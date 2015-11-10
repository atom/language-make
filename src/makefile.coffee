###
$ coffee makefile.coffee
###

Q    = require 'q'
path = require 'path'
fs   = require 'fs'
{makeGrammar} = require 'atom-syntax-tools'

grammarFactory = require './makefile-grammar.coffee'

gnuMakeManual = path.resolve __dirname, '..', 'make.html'

processMakeManual = (content) ->
  lines = content.split /\r?\n/
  entries = targets: [], variables: [], functions: [], other_targets: []
  isSkipped = true

  for line in lines
    isSkipped = false if line.match /^<a\s+name="Name-Index"><\/a>/
    continue if isSkipped
    if m = line.match ///
      ^<tr><td></td><td\s+valign="top"><a\s+href="[^"]*"><code>([^<]*)
      </code></a>:</td><td>&nbsp;</td><td\s+valign="top"><a[^>]*>([^<]*)</a></td></tr>
    ///

      [ match, name, type ] = m
      name = name.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/, '&')
      if type.match /function/i or name == 'subst'
        entries.functions.push name
      else if type.match /target/i and name.match /^\./
        entries.targets.push name[1...]
      else if type.match /target/i
        entries.other_targets.push name
      else if (type.match /variable/i)
        if (m = name.match /^\$\((.*)\)$/)
          entries.variables.push m[1]
        else if name.match /^[^$]/
          entries.variables.push name

  entries

createMakeGrammar = ->
  process.stderr.write "started\n"
  getMakeInfo().then (makeInfo) ->
    grammarFile = path.resolve __dirname, "..", "grammars", "makefile.cson"
    makeGrammar grammarFactory(makeInfo), grammarFile

getMakeInfo = ->
  deferred = Q.defer()

  if not fs.existsSync gnuMakeManual
    http = require 'http'
    request = http.request 'http://www.gnu.org/software/make/manual/make.html', (res) ->

      res.pipe(fs.createWriteStream gnuMakeManual).on 'end', ->
        content = fs.readFileSync(gnuMakeManual).toString()
        deferred.resolve processMakeManual content

    request.on "error", (error) ->
      deferred.reject(error)

    request.end()
  else
    deferred.resolve processMakeManual fs.readFileSync(gnuMakeManual).toString()

  deferred.promise

module.exports = {createMakeGrammar}

if require.main is module
  createMakeGrammar().then ->
    console.log "Grammar Created.\n"
  .catch (error) ->
    console.log "Error: #{error}\n#{error.stack}\n"
