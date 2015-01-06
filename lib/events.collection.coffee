
@Events = new Mongo.Collection('events')

@Events.allow({
  insert: (userId, doc)->
    check(userId, String)
    return true
  update: (userId, doc)->
    # TODO allow edit only own docs
    check(userId, String)
    return true
  remove: (userId, doc)->
    # TODO allow edit only own docs
    check(userId, String)
    return true
})
