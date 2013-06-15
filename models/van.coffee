
_ = require 'underscore'

db = require('mongojs').connect('knapsackery', ['vans'])
ObjectId = db.ObjectId

Item = require './item'

# This is basically a Knapsack
class Van

  constructor: (attributes) ->
    @valid = @checkAttributes attributes
    if @valid
      @[key] = value for key,value of attributes
      @items = []
      @remainingWeight = @maximum_weight
      @remainingCube   = @maximum_cube
    @
  
  checkAttributes: (attributes) -> 
    for prop in ['id','description','maximum_weight','maximum_cube','cost']
      if not attributes.hasOwnProperty prop
        return false
    return true

  packItem: (item) -> 
    if not @fitsItem item
      return false
    else 
      @items.push item
      @remainingWeight -= item.weight
      @remainingCube   -= item.cube
      @

  unpackItem: (someItem) ->
    found = _.find @items, (item) -> item.id is someItem.id
    if not found?
      return false
    else
      @items = _.reject @items, (item) -> item.id is someItem.id
      @remainingWeight += parseFloat someItem.weight
      @remainingCube   += parseFloat someItem.cube
      return true

  # the main Knapsack packing method
  pack: (some_items) ->
    self = @
    valid_items = []
    invalid_items = []

  fitsItem: (item) ->
    parseFloat(item.weight) <= @remainingWeight and parseFloat(item.cube) <= @remainingCube


  # TODO
  # this might need a callback and some async eventually, if lots of vans instantiated
  containsItemById: (id) ->
    if @items.length < 1
      return false

    found = _.find @items, (item) -> item.id is id
    return (if found? then true else false)

  @bestVanForItem: (item, callback) ->
    # We want to find the van that would fit an item with as little wasted weight/volume as possible.
    # Find an item with measurements $gte the item's measurements, and sort by cost
    db.vans.find({ $and: [ { maximum_weight: { $gte: parseInt(item.weight) }}, { maximum_cube: { $gte: parseInt(item.cube) }} ] }).sort { cost: 1 }, (err, vans) ->
      return callback new Error err if err
      if vans.length > 0
        return callback null, new Van vans[0]
      else
        return callback null, null

  @largest: (callback) ->
    db.vans.find().sort { maximum_weight: -1 }, (err, vans) ->
      return callback new Error err if err
      callback null, new Van vans[0]

  @smallest: (callback) ->
    db.vans.find().sort { maximum_weight: 1 }, (err, vans) ->
      return callback new Error err if err
      callback null, new Van vans[0]

  @medium: (callback) ->
    db.vans.find().sort { maximum_weight: -1 }, (err, vans) ->
      return callback new Error err if err
      callback null, new Van vans[1]
  
  @all: (callback) ->
    all = []
    db.vans.find (err, vans) ->
      if err
        console.log err
        callback new Error err
      else
        all.push(new Van van) for van in vans
        callback null, all

  @some: (n, callback) ->
    some = []
    db.vans.find {}, {}, {limit: n}, (err, vans) ->
      if err
        console.log err
        callback new Error err
      else
        some.push(new Van van) for van in vans
        callback null, some


module.exports = Van