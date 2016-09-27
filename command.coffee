colors   = require 'colors'
dashdash = require 'dashdash'
_        = require 'lodash'

packageJSON = require './package.json'

COMMANDS = [{
  name: 'item-get'
  help: 'Retrieve an Exchange Calendar Item'
}]

OPTIONS = [{
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help and exit.'
}, {
  names: ['version', 'v']
  type: 'bool'
  help: 'Print the version and exit.'
}]

class Command
  constructor: ({@argv}) ->
    process.on 'uncaughtException', @die
    {@command, @subArgs} = @parseOptions()

  parseOptions: =>
    parser = dashdash.createParser({options: OPTIONS})
    [globalArgs, subArgs] = @splitArgs @argv
    options = parser.parse(globalArgs)
    command = _.first options._args

    if options.help
      console.log @usage parser.help({includeEnv: true})
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    unless _.includes ['item-get'], command
      console.error @usage parser.help({includeEnv: true})
      console.error colors.red 'Missing command or command not recognized.'
      process.exit 1

    return _.defaults {command, subArgs}, options

  run: =>
    Command = require "./command-#{@command}"
    command = new Command argv: @subArgs
    command.run()

    console.log "Hi Example! #{@example}"

  splitArgs: (args) =>
    command = _.first _.intersection(args, _.map(COMMANDS, 'name'))
    i = _.indexOf args, command
    globalArgs = args[0..i]
    subArgs = [(i+1)..-1]
    return [globalArgs, subArgs]

  usage: (optionsStr) =>
    return """
      usage: bourse-cli [GLOBAL_OPTIONS] <COMMAND>

      commands:
          item-get     Retrieve an Exchange Calendar Item

      options:
      #{optionsStr}
    """

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

module.exports = Command
