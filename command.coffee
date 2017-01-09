colors   = require 'colors'
dashdash = require 'dashdash'
_        = require 'lodash'

packageJSON = require './package.json'

COMMANDS = [{
  name: 'calendar-range'
  help: 'Retrieve all calendar events in a range'
}, {
  name: 'calendar-config-get'
  help: 'Retrieve the user calendar configuration'
}, {
  name: 'calendar-config-update'
  help: 'Update the user calendar configuration'
}, {
  name: 'item-get'
  help: 'Retrieve an Exchange Calendar Item'
}, {
  name: 'item-update'
  help: 'Update an Exchange Calendar Item'
}, {
  name: 'whoami'
  help: 'Who are you?'
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

    unless _.includes @_commandNames(), command
      console.error @usage parser.help({includeEnv: true})
      console.error colors.red 'Missing command or command not recognized.'
      process.exit 1

    return _.defaults {command, subArgs}, options

  run: =>
    Command = require "./command-#{@command}"
    command = new Command argv: @subArgs
    command.run()

  splitArgs: (args) =>
    command = _.first _.intersection(args, @_commandNames())
    i = _.indexOf args, command
    globalArgs = args[0..i]
    subArgs = ['node', args[i..-1]...]
    return [globalArgs, subArgs]

  _commandNames: => _.map COMMANDS, 'name'

  usage: (optionsStr) =>
    return """
      usage: bourse-cli [GLOBAL_OPTIONS] <COMMAND>

      commands:
          calendar-range          Retrieve all calendar events in a range
          config-calendar-get     Retrieve the user calendar configuration
          config-calendar-update  Update the user calendar configuration
          item-get                Retrieve an Exchange Calendar Item
          item-update             Update an Exchange Calendar Item
          whoami                  Who are you?

      global options:
      #{optionsStr}
    """

  die: (error) =>
    return process.exit(0) unless error?
    console.error 'ERROR'
    console.error error.stack
    process.exit 1

module.exports = Command
