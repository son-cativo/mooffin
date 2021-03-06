'use strict'

#Filters

angular.module('mooffin.filters', [])
.filter "searchFor", ->
  
  # All filters must return a function. The first parameter
  # is the data that is to be filtered, and the second is an
  # argument that may be passed with a colon (searchFor:searchString)
  (arr, searchString) ->
    return arr unless searchString
    
    result = []
    searchString = searchString.toLowerCase()
    
    # Using the forEach helper method to loop through the array
    angular.forEach arr, (ingredient) ->
      result.push ingredient  if ingredient.name.toLowerCase().indexOf(searchString) isnt -1

    result