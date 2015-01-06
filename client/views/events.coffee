
# TODO localStorage
Session.set('filter', 'week')

# NOTE can't use 'events' as template name
# seems issue in meteor
Template.eventsList.helpers(
  list: -> Events.find(
    # TODO filter
    #datetime: {$gt: new Date(), $lt: new Date() + period}
  )
)

Template.eventsList.events(
  'click .events-filter': (e)->
    Session.set('filter', $(e.target).data('filter'))
    return false
)

Template.eventsForm.events(
  'submit .events-add-form': (e)->
    debugger
    form = e.target
    # TODO validation, formatting, etc
    Events.insert(
      datetime: form.datetime.value
      title: form.title.value
    )
    # prevent default
    return false
)

