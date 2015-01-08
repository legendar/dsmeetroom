
# can be one of 'day', 'week', 'month'
# TODO localStorage
Session.set('filter', 'week')

# NOTE can't use 'events' as template name
# seems issue in meteor
Template.eventsList.helpers(
  list: ->
    calcPeriodQuery = ->
      # start of current day
      now = moment().hour(0).minute(0).second(0)
      filter = Session.get('filter')
      switch filter
        when 'week'
          # start of week
          now.day(0)
        when 'month'
          # start of month
          now.date(1)
      {
        $gte: now.valueOf()
        $lt: now.add(1, filter + 's').valueOf()
      }

    Events.find(
      datetime: calcPeriodQuery()
    )
)

Template.eventsRow.helpers(
  date: (d)-> moment(d).format('dddd, D MMMM, h:mm')
)

Template.eventsList.events(
  'click .events-filter': (e)->
    Session.set('filter', $(e.target).data('filter'))
    return false
)

Template.eventsForm.events(
  'submit .events-add-form': (e)->
    form = e.target
    # TODO validation, formatting, etc
    Events.insert(
      datetime: moment(form.datetime.value).valueOf()
      title: form.title.value
      ownerId: Meteor.userId()
      ownerName: Meteor.user().profile.name
    )
    # prevent default
    return false
)

