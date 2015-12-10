APP = do ->

  ###
  Generate all the options for the date entries
  ###

  daySelectors = getDomNodeArray('.day')

  ###*
  # Creates an Array of DOM nodes that match the selector
  # @param selector {string} CSS selector - selector to match against
  # @return {array} Array of DOM nodes
  ###

  getDomNodeArray = (selector) ->
    nodes = Array::slice.apply(document.querySelectorAll(selector))
    if !nodes
      nodes = []
    nodes

  ###
  class="model model-*" Refer to inputs by the name after class model-*
  ###

  Model = ->
    self = this
    # pulls values from elems of class="model model-*" to create Model's raw info and set up 1-way binding

    Binding = (elem, value) ->
      elem = elem or null
      value = value or null
      @elem = elem
      @value = value
      @hasChanged = false

      @oninput = ->

      return

    getDomNodeArray('.model').forEach (elem) ->
      elem.classList.forEach (className) ->
        possiblyMatch = className.match(/model\-/g)
        if possiblyMatch
          # create the Model value
          name = className.slice(6)
          value = elem.value
          # set default values
          if name.indexOf('Month') > -1
            value = value - 1
          else if name.indexOf('Time' > -1)
            value = value or '00:00'
          self[name] = self[name] or new Binding(elem, value)
          elem.binding = elem.binding or self[name]
          # bind data oninput

          elem.oninput = ->
            self[name].hasChanged = true
            self[name] = self[name] or new Binding(elem, value)
            self[name].value = elem.value
            self.updateCalculations()
            # for callbacks
            self[name].oninput()
            return

        return
      return

    self.updateCalculations = ->
      self.startMin = self.startMin or new Binding(null, self.startTime.value.split(':')[1])
      self.startHour = self.startHour or new Binding(null, self.startTime.value.split(':')[0])
      self.endMin = self.endMin or new Binding(null, self.endTime.value.split(':')[1])
      self.endHour = self.endHour or new Binding(null, self.endTime.value.split(':')[0])
      self.date = self.date or new Binding
      self.date.value = new Date(self.startYear.value, self.startMonth.value, self.startDay.value)
      return

    self.updateCalculations()
    return

  ###
  To create a placeholder effect. Assumes that display element starts with 'placeholder' class
  ###

  displayWithPlaceholder = (inputBinding, displayElem, placeholder) ->
    if displayElem.classList.contains('placeholder')
      displayElem.classList.remove 'placeholder'
    if inputBinding.value == ''
      inputBinding.value = placeholder
      # let the model know that input has gone back to default
      inputBinding.hasChanged = false
      displayElem.classList.add 'placeholder'
    displayElem.innerHTML = inputBinding.value
    return

  validate = ->
    self = this
    allGood = false
    errorMessage = 'Please correct the following errors: <br>'
    people = getDomNodeArray('.people>div')
    validations = [
      {
        errorMessage: 'Please include a title.'
        validationMethod: ->
          model.title.hasChanged

      }
      {
        errorMessage: 'Please include a description.'
        validationMethod: ->
          model.description.hasChanged

      }
      {
        errorMessage: 'Please include guests.'
        validationMethod: ->
          if people.length > 0
            true
          else
            false

      }
      {
        errorMessage: 'Please include valid email addresses.'
        validationMethod: ->
          areReal = false
          emailRegex = new RegExp('^[-a-z0-9~!$%^&*_=+}{\'?]+(.[-a-z0-9~!$%^&*_=+}{\'?]+)*@([a-z0-9_][-a-z0-9_]*(.[-a-z0-9_]+)*.(aero|arpa|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org|pro|travel|mobi|[a-z][a-z])|([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}))(:[0-9]{1,5})?$')
          people.forEach (guest, index) ->
            result = emailRegex.exec(guest.value)
            if result and result['index'] == 0
              if index == 0
                areReal = true
              else
                areReal = areReal and true
            else
              areReal = areReal and false
            return
          areReal

      }
    ]
    validations.forEach (val, index) ->
      if val.validationMethod(self)
        if index == 0
          allGood = true
        else
          allGood = allGood and true
      else
        allGood = allGood and false
        errorMessage = errorMessage + val.errorMessage + '<br>'
      return
    errorMessage = errorMessage.trim()
    {
      isValid: allGood
      errorMessage: errorMessage
    }

  daySelectors.forEach (selectElement) ->
    day = 1
    while day < 32
      newOption = document.createElement('option')
      if day < 10
        day = '0' + day
      else
        day = day + ''
      newOption.innerHTML = day
      selectElement.appendChild newOption
      day++
    return
  monthSelectors = getDomNodeArray('.month')
  monthSelectors.forEach (selectElement) ->
    month = 1
    while month < 13
      newOption = document.createElement('option')
      if month < 10
        month = '0' + month
      else
        month = month + ''
      newOption.innerHTML = month
      selectElement.appendChild newOption
      month++
    return
  yearSelectors = getDomNodeArray('.year')
  yearSelectors.forEach (selectElement) ->
    year = 2015
    while year < 2021
      newOption = document.createElement('option')
      newOption.innerHTML = year + ''
      selectElement.appendChild newOption
      year++
    return

  ###
  Adding guests
  ###

  newGuest = document.querySelector('input.new-guest')
  people = document.querySelector('.attendees')

  newGuest.onkeydown = (evt) ->
    if evt.keyIdentifier == 'Enter'
      enteredPerson = document.createElement('div')
      deletePerson = document.createElement('button')
      deletePerson.innerHTML = '-'
      deletePerson.parent = enteredPerson

      deletePerson.onclick = ->
        people.removeChild @parent
        return

      enteredPerson.innerHTML = newGuest.value
      enteredPerson.value = newGuest.value
      # for easy access later
      enteredPerson.appendChild deletePerson
      people.appendChild enteredPerson
      newGuest.value = ''
    return

  model = new Model
  # Update the view oninput

  model.title.oninput = ->
    titleDisplay = document.querySelector('.title-display')
    displayWithPlaceholder model.title, titleDisplay, 'Untitled Event'
    return

  model.description.oninput = ->
    descriptionDisplay = document.querySelector('.card-detail-actual.what')
    displayWithPlaceholder model.description, descriptionDisplay, 'Description'
    return

  model.location.oninput = ->
    locationDisplay = document.querySelector('.card-detail-actual.where')
    displayWithPlaceholder model.location, locationDisplay, 'Place'
    return

  whenDisplay = document.querySelector('.card-detail-actual.when')
  getDomNodeArray('.input-datetime').forEach (elem) ->

    elem.binding.oninput = ->
      # TODO: a bit hacky
      timeToDisplay = model.date.value.toDateString() + ' from ' + model.startTime.value + ' to ' + model.endTime.value
      displayWithPlaceholder { value: timeToDisplay }, whenDisplay, 'Time'
      return

    return
  createButton = document.querySelector('button#create')

  createButton.onclick = ->
    validState = validate()
    if !validState.isValid
      errorMessage = document.querySelector('.error-message')
      errorMessage.innerHTML = validState.errorMessage
    else
      alert 'Valid form. Thanks for submitting!'
    return

  return