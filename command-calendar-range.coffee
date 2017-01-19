Bourse   = require 'bourse'
colors   = require 'colors'
dashdash = require 'dashdash'
_        = require 'lodash'
moment   = require 'moment'

packageJSON = require './package.json'

OPTIONS = [{
  names: ['end', 'e']
  type: 'string'
  help: 'End of range'
  env:  'BOURSE_END'
}, {
  names: ['help', 'h']
  type: 'bool'
  help: 'Print this help and exit.'
}, {
  names: ['hostname', 'H']
  type: 'string'
  help: 'Exchange hostname'
  env:  'BOURSE_HOSTNAME'
}, {
  names: ['password', 'p']
  type: 'string'
  help: 'Exchange password'
  env:  'BOURSE_PASSWORD'
}, {
  names: ['start', 's']
  type: 'string'
  help: 'Start of range'
  env:  'BOURSE_START'
}, {
  names: ['username', 'u']
  type: 'string'
  help: 'Exchange username'
  env:  'BOURSE_USERNAME'
}, {
  names: ['version', 'v']
  type: 'bool'
  help: 'Print the version and exit.'
}]

class CommandCalendarRange
  constructor: ({@argv}) ->
    throw new Error 'Missing required parameter: argv' unless @argv?
    process.on 'uncaughtException', @die
    {@start, @end, @hostname, @username, @password} = @parseOptions()

  parseOptions: =>
    parser = dashdash.createParser({options: OPTIONS})
    options = parser.parse @argv

    if options.help
      console.log @usage parser.help({includeEnv: true})
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    {end, start, hostname, username, password} = options
    if _.some [end, start, hostname, username, password], _.isEmpty
      console.error @usage parser.help({includeEnv: true})
      console.error colors.red 'Missing one of: -e, --end, BOURSE_END' if _.isEmpty end
      console.error colors.red 'Missing one of: -H, --hostname, BOURSE_HOSTNAME' if _.isEmpty hostname
      console.error colors.red 'Missing one of: -p, --password, BOURSE_PASSWORD' if _.isEmpty password
      console.error colors.red 'Missing one of: -s, --start, BOURSE_START' if _.isEmpty start
      console.error colors.red 'Missing one of: -u, --username, BOURSE_USERNAME' if _.isEmpty username
      process.exit 1

    options.end   = moment.utc end
    options.start = moment.utc start
    return options

  run: =>
    bourse = new Bourse {@hostname, @username, @password}
    bourse.getCalendarItemsInRange {@start, @end, extendedProperties: {'genisysMeetingId': true, 'genisysSearchableId': true}}, (error, items) =>
      return @die error if error?
      console.log JSON.stringify(items, null, 2)
      process.exit 0

  usage: (optionsStr) =>
    return """
      usage: bourse-cli [GLOBAL_OPTIONS] calendar-range [OPTIONS]

      options:
      #{optionsStr}
    """

  die: (error) =>
    return process.exit(0) unless error?
    console.error error.stack
    process.exit 1



module.exports = CommandCalendarRange
