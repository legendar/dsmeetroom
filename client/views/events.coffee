
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

    defaultItems = ->
      # TODO review
      # count of days in month
      # expand to square (fill with prev/next months days)
      # add for week and day
      JSON.parse("{\"#{_.range(1,32).join('":[],"')}\":[]}")

    items = _(items)
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
      .defaults defaultItems()
      .map (items, day)=> {day, items: _(items).sortBy('datetime')}
      .value()
  currentFilter: -> Session.get('filter')
)

Template.eventsRow.helpers(
  formatDate: (d)-> moment(d).format('dddd, D MMMM, h:mm')
  formatTime: (d)-> moment(d).format('h:mm')
  formatDuration: (d)-> moment.duration(d).humanize()
  genClassName: -> 'v' + getRandomInt(1,3) + ' c' + getRandomInt(1,4)
)

Template.eventsList.events(
  'click .events-filter a': (e)->
    Session.set('filter', $(e.target).data('filter'))
    return false
)

Template.eventsForm.events(
  'submit .events-add-form': (e)->
    form = e.target
    # TODO validation, formatting, etc
    Events.insert(
      datetime: moment(form.datetime.value).valueOf()
      duration: moment.duration(form.duration.value).as('milliseconds')
      title: form.title.value
      ownerId: Meteor.userId()
      ownerName: Meteor.user().profile.name
    )
    # prevent default
    return false
  'change .datetime': (e)->
    setupDurationPicker(
      moment($(e.target).val())
    )
)

setupDurationPicker = (from)->
  dayStart = moment(from).hour(0).minute(0).second(0)
  #value = @$('.duration').val()
  @$('.duration-btn')
    #.val(
    #  moment(dayStart).add(moment.duration(value)).format('YYYY-MM-DD HH:MM')
    #)
    .datetimepicker('remove')
    .datetimepicker(
      #format: 'hh:ii'
      linkField: 'duration'
      linkFormat: 'hh:ii'
      startView: 1
      autoclose: true
      startDate: dayStart.format('YYYY-MM-DD') + ' 00:00'
      endDate: dayStart.add(
        moment.duration(24, 'hours').subtract(
          moment.duration(moment(from))
        )
      ).format('YYYY-MM-DD HH:MM')
    )
    #.val(value)

Template.eventsForm.rendered = ->
  @$('.datetime').datetimepicker(
    format: 'd M yyyy, hh:ii'
    autoclose: true
    startDate: moment().format('YYYY-MM-DD HH:MM')
  )
  setupDurationPicker(moment())


