Bourse   = require 'bourse'
colors   = require 'colors'
dashdash = require 'dashdash'
_        = require 'lodash'

packageJSON = require './package.json'

OPTIONS = [{
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
  names: ['username', 'u']
  type: 'string'
  help: 'Exchange username'
  env:  'BOURSE_USERNAME'
}, {
  names: ['property-name', 'n']
  type: 'string'
  help: 'Property Name'
  env:  'BOURSE_PROPERTY_NAME'
}, {
  names: ['property-value', 'V']
  type: 'string'
  help: 'Property Value'
  env:  'BOURSE_PROPERTY_VALUE'
}, {
  names: ['version', 'v']
  type: 'bool'
  help: 'Print the version and exit.'
}]

class CommandItemGet
  constructor: ({@argv}) ->
    throw new Error 'Missing required parameter: argv' unless @argv?
    process.on 'uncaughtException', @die
    {@hostname, @username, @password, @property_name, @property_value} = @parseOptions()

  parseOptions: =>
    parser = dashdash.createParser({options: OPTIONS})
    options = parser.parse @argv

    if options.help
      console.log @usage parser.help({includeEnv: true})
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    {property_name, property_value, hostname, username, password} = options
    if _.some [property_name, property_value, hostname, username, password], _.isEmpty
      console.error @usage parser.help({includeEnv: true})
      console.error colors.red 'Missing one of: -H, --hostname, BOURSE_HOSTNAME' if _.isEmpty hostname
      console.error colors.red 'Missing one of: -p, --password, BOURSE_PASSWORD' if _.isEmpty password
      console.error colors.red 'Missing one of: -u, --username, BOURSE_USERNAME' if _.isEmpty username
      console.error colors.red 'Missing one of: -n, --property-name, BOURSE_PROPERTY_NAME'   if _.isEmpty property_name
      console.error colors.red 'Missing one of: -V, --property-value, BOURSE_PROPERTY_VALUE'   if _.isEmpty property_value
      process.exit 1

    return options

  run: =>
    bourse = new Bourse {@hostname, @username, @password}
    extendedProperties = {
      'genisysSearchableId': true
      'genisysMeetingId': true
    }
    bourse.findItemsByExtendedProperty {Id: 'calendar', key: @property_name, value: @property_value, extendedProperties}, (error, items) =>
      return @die error if error?
      console.log JSON.stringify(items, null, 2)
      process.exit 0

  usage: (optionsStr) =>
    return """
      usage: bourse-cli [GLOBAL_OPTIONS] item-get [OPTIONS]

      options:
      #{optionsStr}
    """

  die: (error) =>
    return process.exit(0) unless error?
    console.error error.stack
    process.exit 1



module.exports = CommandItemGet
