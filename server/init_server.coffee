
console?.log "Server only code..."

Meteor.startup = ->
  console?.log "Starting again..."
    
        
Meteor.methods
  dummy: ->
    resp = "Dummy thing!"
    console.log resp
    resp

  suma: () ->
    total = 0
    total += x for x in arguments
    console?.log "Suma: ", total
    total

Accounts.loginServiceConfiguration.allow
  insert: (userid, service) ->
    if not userid then false else true
  
  update: (userid, service) ->
    if not userid then false else true
  
  remove: (userid, service) ->
    if not userid then false else true
  
teamsOps = (what, userid, team) ->
  if not userid
    return false
  try
    user = Meteor.users.findOne _id: userid
    name = user.profile.name
  catch e
    console?.log "ERROR: ", e.message
    name = "unknown user"
  
  strteam = JSON.stringify team
  msg = "(#{name}/#{userid}) is #{what} team #{strteam}"
  console?.log msg    
  Modifs.insert who: name, message: msg
  true
  
Teams.allow
  insert: (userid, team) ->
    teamsOps "inserting", userid, team
  update: (userid, teamid) ->
    teamsOps "updating", userid, teamid
  remove: (userid, teamid) ->
    teamsOps "removing", userid, teamid
       
    

