debug = (require 'debug') 'wit'
Wit = require('node-wit').Wit

token = process.env.WIT_APP_TOKEN

firstEntityValue = (entities, entity) ->
  val = entities && entities[entity] &&
    Array.isArray(entities[entity]) &&
    entities[entity].length > 0 &&
    entities[entity][0].value
  if not val then return null
  if typeof val == 'object' then return val.value
  return val

actions =
  say: (sessionId, context, message, cb) ->
    debug "say: #{message}"
    debug context
    cb()
  merge: (sessionId, context, entities, message, cb) ->
    debug entities
    location = firstEntityValue entities, 'local_search_query'
    context.location = location
    cb context
  error: (sessionId, context, error) ->
    debug context
    debug "error: #{error.message}"
  getDirections: (sessionId, context, cb) ->
    debug context
    context.response = 'The toilets are near the east entrance'
    cb context

client = new Wit token, actions

module.exports = Wit =
  parseMessage: (user_id, msg) ->
    session = user_id
    client.runActions session, 'Where are the toilets?', {}, (error, context) ->
      if error
        debug "Oops! Got an error: #{error}"
      else
        Smooch.sendMessage user_id, context.response
        debug "The session state is now: #{JSON.stringify(context)}"

