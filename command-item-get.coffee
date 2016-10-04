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
  names: ['item-id', 'i']
  type: 'string'
  help: 'Item Id'
  env:  'BOURSE_ITEM_ID'
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
  names: ['version', 'v']
  type: 'bool'
  help: 'Print the version and exit.'
}]

class CommandItemGet
  constructor: ({@argv}) ->
    throw new Error 'Missing required parameter: argv' unless @argv?
    process.on 'uncaughtException', @die
    {@hostname, @username, @password, @item_id} = @parseOptions()

  parseOptions: =>
    parser = dashdash.createParser({options: OPTIONS})
    options = parser.parse @argv

    if options.help
      console.log @usage parser.help({includeEnv: true})
      process.exit 0

    if options.version
      console.log packageJSON.version
      process.exit 0

    {item_id, hostname, username, password} = options
    if _.some [item_id, hostname, username, password], _.isEmpty
      console.error @usage parser.help({includeEnv: true})
      console.error colors.red 'Missing one of: -H, --hostname, BOURSE_HOSTNAME' if _.isEmpty hostname
      console.error colors.red 'Missing one of: -i, --item-id, BOURSE_ITEM_ID'   if _.isEmpty item_id
      console.error colors.red 'Missing one of: -p, --password, BOURSE_PASSWORD' if _.isEmpty password
      console.error colors.red 'Missing one of: -u, --username, BOURSE_USERNAME' if _.isEmpty username
      process.exit 1

    return options

  run: =>
    bourse = new Bourse {@hostname, @username, @password}
    bourse.getItem {itemId: @item_id}, (error, item) =>
      return @die error if error?
      console.log JSON.stringify(item, null, 2)
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
