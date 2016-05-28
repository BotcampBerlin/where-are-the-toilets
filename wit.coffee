debug = (require 'debug') 'wit'
Wit = require('node-wit').Wit
Smooch = require './smooch'

token = process.env.WIT_APP_TOKEN

firstEntityValue = (entities, entity) ->
  val = entities && entities[entity] &&
    Array.isArray(entities[entity]) &&
    entities[entity].length > 0 &&
    entities[entity][0].value
  if not val then return null
  if typeof val == 'object' then return val.value
  return val

module.exports =
  parseMessage: (user_id, msg) ->
    actions =
      say: (sessionId, context, message, cb) ->
        debug "say: #{message}"
        debug context
        cb()
      merge: (sessionId, context, entities, message, cb) ->
        debug entities
        stage = firstEntityValue entities, 'stage_now_playing'
        if stage?
          context.stageLocation = stage
        cb context
      error: (sessionId, context, error) ->
        debug "Error #{error.message}"
        Smooch.sendMessage user_id, error.message
      getDirections: (sessionId, context, cb) ->
        debug context
        context.response = 'The toilets are near the east entrance'
        cb context
      getNowOnStage: (sessionId, context, cb) ->
        debug context
        context.response = 'The White Stripes are playing.'
        cb context
    client = new Wit token, actions
    session = user_id
    client.runActions session, 'Where are the toilets?', {}, (error, context) ->
      if error
        debug "Oops! Got an error: #{error}"
      else
        debug "The session state is now: #{JSON.stringify(context)}"
        Smooch.sendMessage user_id, context.response

