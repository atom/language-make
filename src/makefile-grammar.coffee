###
Generator for makefile.cson
###

{makeWords, makeRegexFromWords, rule} = require 'atom-syntax-tools'

module.exports = (makeInfo) ->

  console.log makeInfo

  makeFuncs = makeRegexFromWords makeInfo.functions
  makeVars  = makeRegexFromWords makeInfo.variables

  console.log makeVars

  makeTargets = makeRegexFromWords makeInfo.targets

  placeholder =
    m: /%/
    n: 'constant.other.placeholder.makefile'

  otherVariable =
    m: /[^\s]+/
    n: 'variable.other.makefile'

  continuation =
    m: /\\\n/
    n: 'constant.character.escape.continuation.makefile'

  grammar =
    macros: {makeFuncs, makeTargets, makeVars}
    scopeName: 'source.makefile'
    name: 'Makefile'
    fileTypes: [
      'Makefile'
      'makefile'
      'GNUmakefile'
      'OCamlMakefile'
      'mf'
      'mk'
      'Makefile.in'
    ]
    firstLineMatch: /^#!\s*\/.*\bmake\s+-f/
    patterns: [
      '#comment'
      '#variableAssignment'
      '#recipe'
      '#directives'
    ]
    repository:
      comment:
        b: /(^[ \t]+)?(?=#)/
        c:
          1: 'punctuation.whitespace.comment.leading.makefile'
        e: /(?!\G)/
        p: [
          rule
            b: /#/
            c:
              0: 'punctuation.definition.comment.makefile'
            e: /\n/
            n: 'comment.line.number-sign.makefile'
            p: [
              continuation
            ]
        ]
      directives: [
        rule
          b: /^[ ]*([s\-]?include)\b/
          c:
            1: 'keyword.control.include.makefile'
          e: /^/
          p: [
            '#comment'
            '#variables'
            placeholder
          ]
        rule
          b: /^[ ]*(vpath)\b/
          c:
            1: 'keyword.control.vpath.makefile'
          e: /^/
          p: [
            '#comment'
            '#variables'
            placeholder
          ]
        rule
          b: /^(?:(override)\s*)?(define)\s*([^\s]+)\s*(=|\?=|:=|\+=)?(?=\s)/
          c:
            1: 'keyword.control.override.makefile'
            2: 'keyword.control.define.makefile'
            3: 'variable.other.makefile'
            4: 'punctuation.separator.key-value.makefile'
          e: /^(endef)\b/
          n: 'meta.scope.conditional.makefile'
          p: [
            {
              b: /\G(?!\n)/
              e: /^/
              p: [ '#comment' ]
            }
            '#variables'
            '#comment'
          ]
        rule
          b: /^[ ]*(export)\b/
          c:
            1: 'keyword.control.$1.makefile'
          e: /^/
          p: [
            '#comment'
            '#variableAssignment'
            otherVariable
          ]
        rule
          b: /^[ ]*(override|private)\b/
          c:
            1: 'keyword.control.$1.makefile'
          e: /^/
          p: [
            'include': '#comment'
            'include': '#variableAssignment'
          ]
        rule
          b: /^[ ]*(unexport|undefine)\b/
          c:
            1: 'keyword.control.$1.makefile'
          e: /^/
          'patterns': [
            '#comment'
            otherVariable
          ]
        rule
          b: /^(ifdef|ifndef)\s*([^\s]+)(?=\s)/
          c:
            1: 'keyword.control.$1.makefile'
            2: 'variable.other.makefile'
            3: 'punctuation.separator.key-value.makefile'
          e: /^(endif)\b/
          n: 'meta.scope.conditional.makefile'
          p: [
            rule
              b: /\G(?!\n)/
              e: /^/
              p: [ '#comment' ]
            '$self'
          ]
        rule
            b: /^(ifeq|ifneq)(?=\s)/
            c:
              1: 'keyword.control.$1.makefile'
            e: /^(endif)\b/
            n: 'meta.scope.conditional.makefile'
            p: [
              rule
                b: /\G/
                e: /^/
                n: 'meta.scope.condition.makefile'
                p: [
                  '#variables'
                  '#comment'
                ]

              rule
                b: /^else(?=\s)/
                c:
                  0: 'keyword.control.else.makefile'
                e: /^/

              '$self'
            ]
        ]

      interpolation:
        b: /(?=`)/
        e: /(?!\G)/
        n: 'meta.embedded.line.shell'
        p: [
          rule
            begin: /`/
            beginCaptures:
              0: 'punctuation.definition.string.makefile'
            contentName: 'source.shell'
            end: /(`)/
            endCaptures:
              0: 'punctuation.definition.string.makefile'
              1: 'source.shell'
            name: 'string.interpolated.backtick.makefile'
            patterns: [
                'source.shell'
            ]
        ]
      recipe:
        b: /^(?!\t)([^:]*)(:)(?!\=)/
        c:
          1: [
              rule
                m: /^\s*(\\.)({makeTargets})\s*$/
                c:
                  1: 'punctuation.definition.target.special.makefile'
                  2: 'support.function.target.$1.makefile'

              rule
                b: /(?=\S)/
                e: /(?=\s|$)/
                n: 'entity.name.function.target.makefile'
                p: [
                    '#variables'
                    placeholder
                ]
            ]
          2: 'punctuation.separator.key-value.makefile'
        e: /^(?!\t)/
        n: 'meta.scope.target.makefile'
        p: [
          rule
            b: /\G/
        #    e: /(?!\\\n)$/
            e: /^/
            n: 'meta.scope.prerequisites.makefile'
            p: [
              continuation

              rule
                m: /%|\*/
                n: 'constant.other.placeholder.makefile'

              '#comment'
              '#variables'
            ]
          rule
            begin: /^\t/
            end: /$/
            name: 'meta.scope.recipe.makefile'
            patterns: [
              continuation
              '#variables'
              'source.shell'
            ]

        ]
      variableAssignment:
        begin: /(^[ ]*|\G\s*)([^\s]+)\s*(=|\?=|:=|\+=)/
        beginCaptures:
          2: 'variable.other.makefile'
          3: 'punctuation.separator.key-value.makefile'
        end: /\n/
        patterns: [
          continuation
          '#comment'
          '#variables'
          '#interpolation'
        ]
      variables:
        patterns: [
          rule
            captures:
              1: 'punctuation.definition.variable.makefile'
            match: /(\$?\$)[@%<?^+*]/
            name: 'variable.language.makefile'
          rule
            match: /\b@\w+@\b/
            name: 'string.interpolated.makefile'
          rule
            b: /\$?\$\(/
            c:
              0: 'punctuation.definition.variable.makefile'
            e: /\)/
            C:
              0: 'punctuation.definition.variable.makefile'
            n: 'string.interpolated.makefile'
            p: [
              'source.shell#string'
              '#variables'
              rule
                m: /\G({makeVars})(?=\s*\))/
                n: 'variable.language.makefile'

              rule
                b: /\G({makeFuncs})\s/
                c:
                  1: 'support.function.$1.makefile'
                e: /(?=\))/
                n: 'meta.scope.function-call.makefile'
                p: [
                  '#variables'
                  'source.shell#string'
                  {
                    m: /%|\*/
                    n: 'constant.other.placeholder.makefile'
                  }
                ]
              rule
                begin: /\G(origin|flavor)\s(?=[^\s)]+\s*\))/
                contentName: 'variable.other.makefile'
                end: /(?=\))/
                name: 'meta.scope.function-call.makefile'
                patterns: [
                  '#variables'
                  'source.shell#string'
                ]
              rule
                b: /\G(?!\))/
                e: /(?=\))/
                n: 'variable.other.makefile'
                p: [
                  '#variables'
                  'source.shell#string'
                ]
            ]
        ]

  grammar
