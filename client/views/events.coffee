
# can be one of 'day', 'week', 'month'
# TODO localStorage
Session.set('filter', 'month')

# NOTE can't use 'events' as template name
# seems issue in meteor
Template.eventsList.helpers(
  list: ->
    filter = Session.get('filter')

    calcPeriodQuery = ->
      # start of current day
      now = moment().hour(0).minute(0).second(0)
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

    items = Events.find(
      datetime: calcPeriodQuery()
    ).fetch()

    _(items)
      .chain()
      .map((item)=>
        day = moment(item.datetime)
        switch filter
          when 'day'
            day = 'today'
          when 'week'
            day = day.day()
          when 'month'
            day = day.date()
        item.day = day
        return item
      )
      .groupBy('day')
      .map (items, day)=> {day, items}
      .value()
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

