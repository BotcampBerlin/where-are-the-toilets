debug = (require 'debug') 'wit'
Wit = require('node-wit').Wit

token = process.env.WIT_APP_TOKEN

actions =
  say: (sessionId, context, message, cb) ->
    debug "say: #{message}"
    cb()
  merge: (sessionId, context, entities, message, cb) ->
    debug entities
    context.location = entities.local_search_query[0].value
    cb context
  error: (sessionId, context, error) ->
    debug context
    debug "error: #{error.message}"
  getDirections: (sessionId, context, cb) ->
    debug 'getDirections'
#debug context
# context.directions = 'The toilets are near the east entrance'
# cb context

client = new Wit token, actions

###
context = {}
client.message 'Where are the toilets?', context, (error, data) ->
  if error
    debug "Oops! Got an error: #{error}"
  else
    debug "Yay, got Wit.ai response: #{JSON.stringify(data)}"
    debug context

session = 'my-user-session-42';
context0 = {}

client.runActions session, 'Where are the toilets?', context0, (e, context1) ->
  if e
    debug "Oops! Got an error: #{e}"
    return
  debug "The session state is now: #{JSON.stringify(context1)}"
###