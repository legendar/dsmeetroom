
@Events = new Mongo.Collection('events')

shouldBeTrue = Match.Where((value) -> value is true)
shouldBeFalse = Match.Where((value) -> value is false)

# TODO checks for date format, title, etc
# TODO checks for occupied datetime
# TODO throw errors, show them in tpl

@Events.allow(
  insert: (userId, doc)->
    check(userId, String)
    # ensure that ownerId is set
    check(doc.ownerId is userId, shouldBeTrue)
    # ensure that _id will auto-generated
    check(doc._id, undefined)
    return true
  update: (userId, doc, fields)->
    check(userId, String)
    check(doc.ownerId is userId, shouldBeTrue)
    # don't allow to update ownerId
    check(_.contains(fields, 'ownerId'), shouldBeFalse)
    return true
  remove: (userId, doc)->
    check(userId, String)
    check(doc.ownerId is userId, shouldBeTrue)
    return true
  # fetch fields that needs in check actions
  fetch: ['ownerId']
)
