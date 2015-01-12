# Define SpeciesManager in the global window space as window.SpeciesManager
@SpeciesManager = ->
  # Private variables, functions and backbone objects
  _speciesOuterListView = null
  _seedData = null
  _map = null
  _families = {}
  # Store a reference to the currently open google maps pin window
  _openInfoWindow = null

  # Redefine the template interpolation character used by underscore (to @ from %) to prevent conflicts with rails ERB
  _.templateSettings =
    evaluate:    /\<\@(.+?)\@\>/g,
    interpolate: /\<\@=(.+?)\@\>/g,
    escape:      /\<\@-(.+?)\@\>/g


  # VIEWS -------------------------------------------------------------------------------
  # View for selected species shown in the center of the screen
  SpeciesPopoverView = Backbone.View.extend(
    # Id and class name for popover view
    className: '#popover-inner'
    id: '#popover-inner'
    # Select the underscore template to use, found in view/_map.html.erb
    template: _.template($('#popover-template').html())

    # Define javascript events for popover
    events:
      'click #overlay-close' : 'closeOverlay'
      'click #popover-inner' : 'cancelEvent'
      'click' : 'closeOverlay'

    # Fade out the overlay and set display to none to prevent event hogging
    closeOverlay: ->
      $('#overlay-dark, #popover-outer').removeClass('selected')
      setTimeout ->
        $('#overlay-dark,#popover-outer').css('display', 'none')
        # After we've faded out the popover, remove it from the DOM
        @.remove()
      , 300

    render: ->
      # Render the element from the template and model
      @$el.html @template(@model.toJSON())
      # Set display to block from none
      $('#overlay-dark,#popover-outer').css('display', 'block')
      # After a delay of 50 ms, add the class to allow the CSS transition to kick in at the next render loop
      setTimeout ->
        $('#overlay-dark,#popover-outer').addClass('selected')
      , 50
      this
  )

  SpeciesMapView = Backbone.View.extend(
    # Cache the parent model so we can access species data in each sub location
    parentModel: null
      
    # Initialize google maps objects and set the parent model
    initMapComponents: (parentModel) ->
      @parentModel = parentModel
      # Define google maps info window (little box that pops up when you click a marker)
      @infoWindow = new google.maps.InfoWindow(content: @parentModel.get('genusSpecies'))

      # Define google maps marker (red balloon over species on map)
      @marker = new google.maps.Marker(
        position: new google.maps.LatLng(@model.get('lat'), @model.get('lon'));
        map: _map
        title: @parentModel.get('genusSpecies')
      )

      # Add click event listener for the map pins
      google.maps.event.addListener @marker, "click", ->
        _openInfoWindow.close() if _openInfoWindow
        infoWindow.open _map, @marker
        _openInfoWindow = infoWindow
        return

    # Methods for hiding and showing google maps markers
    hideMarker: ->
      @infoWindow.close()
      @marker.setMap(null)

    showMarker: ->
      @marker.setMap(_map)
  )

  # View for species in menu list
  SpeciesListView = Backbone.View.extend(
    # Set class name for generated view
    className: 'list-row'
    # Select the underscore template to use, found in view/_species.html.erb
    template: _.template($('#list-row-template').html())
    # Store google maps data
    mapViews: []
    # Define javascript events
    events:
      'click': 'showPopover'

    initialize: ->
      # Set up a new family list view if one doesn't exist, otherwise add markers to the matching one
      familyListView = null 
      if _families[@model.get('family').name]
        familyListView = _families[@model.get('family').name]
      else
        familyListView = new FamilyListView(model: new FamilyModel(@model.get('family')))
      # Add this to the species managed by it's parent family
      familyListView.addSpecies(@)
      # If there are locations defined for these species, set up new species map views
      for location in @model.get('species_locations')
        # Create a new SpeciesMapView with location data
        mapView = new SpeciesMapView(model: new LocationModel(location))
        # Set up google maps components associated with the species map view
        mapView.initMapComponents @model
        # Save the mapview into the array in this model
        @mapViews.push(mapView)

    # When clicked, show the central popover with the corresponding data
    showPopover: ->
      popover = new SpeciesPopoverView({model: @model})
      $('#popover-outer').append(popover.render().el)

    render: ->
      # Add the species to the species list
      @$el.html @template(@model.toJSON())
      # Render the pin on the map
      this
  )

  # View for families in list
  FamilyListView = Backbone.View.extend(
    # Set class name for generated view
    className: 'family-row'
    # Set outer container for these rows to live in
    outerContainer: '#menu-content-families'
    # Select the underscore template to use, found in view/_species.html.erb
    template: _.template($('#family-row-template').html())
    # Define javascript events
    events:
      'click' : 'toggleFamily'

    # Whether or not this row is selected - (showing family species on the map)
    selected: true
    # Array of all the map markers that should be toggled by this family
    species: []

    initialize: ->
      @render()

    # Hides / displays the species managed by this family on the map
    toggleFamily: ->
      # Remove selected class from the checkbox inside this view
      if @selected then @$el.find('.checkbox').removeClass 'selected' else @$el.find('.checkbox').addClass 'selected'
        
      # Loop through and hide or show the species markers
      for s in @species
        for mapView in s.mapViews
          if @selected then mapView.hideMarker() else mapView.showMarker()

      # Flip the selected bool
      @selected = !@selected

    addSpecies: (species) ->
      @species.push(species)

    render: ->
      # Add the family to the families list
      @$el.html @template(@model.toJSON())
      $(@outerContainer).append @$el
      this
  )

  # The outer backbone view for the species list
  SpeciesOuterListView = Backbone.View.extend(
    el: '#menu-content-list'

    # Define methods to be run at initialization time
    initialize: ->
      # Create a new species collection to hold the data
      @collection = new speciesCollection(_seedData);
      # Whenever a new object is added to the collection, render it's corresponding view
      @collection.bind 'add', @appendItem
      # Call this view's render() function to render all the initial models that might have been added
      @render()

    render: ->
      # For each model in the collection, render and append them to the list view
      _(@collection.models).each (model) ->
        @appendItem model;
      , @

    appendItem: (model) ->
      # Create a new species view based on the model data
      view = new SpeciesListView({model: model})
      # Render the species view in the outer container
      @$el.append(view.render().el)
  )


  # MODELS ----------------------------------------------------------------------------------------
  # Model that holds each species
  SpeciesModel = Backbone.Model.extend({})

  # Model that holds a locations for species
  LocationModel = Backbone.Model.extend({})

  # Model that holds family data
  FamilyModel = Backbone.Model.extend({})


  # COLLECTIONS -----------------------------------------------------------------------------------
  # Collection that holds JSON returned from /species.json
  speciesCollection = Backbone.Collection.extend(
    # Provide a URL to pull JSON data from
    url: '/species.json'
    # Use the species model
    model: SpeciesModel
  )

  # SpeciesManager.initialize() is the only exported member variable, it will initialize the backbone objects, pull data
  # and set up the collection
  initialize: (seedData, map) ->
    # Cache local variables
    _seedData = seedData
    _map = map
    # Create a new list view to kick off backbone
    _speciesOuterListView = new SpeciesOuterListView()
