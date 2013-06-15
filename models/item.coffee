
db = require('mongojs').connect('knapsackery', ['packages'])
ObjectId = db.ObjectId

require 'should'

class Item

  constructor: (attributes) ->
    @valid = @checkAttributes attributes
    if @valid
      @[key] = value for key, value of attributes
    @

  checkAttributes: (attributes) -> 
    for prop in ['id','weight','cube']
      if not attributes.hasOwnProperty prop
        return false
      if prop < 0 
        return false
    return true

  @all: (callback) ->
    all = []
    db.packages.find (err, items) ->
      if err
        callback new Error err
      else 
        all.push(new Item item) for item in items
        callback null, all

  @some: (n, callback) ->
    some = []
    db.packages.find {}, {}, {limit: n}, (err, items) ->
      if err
        callback new Error err
      else
        some.push(new Item item) for item in items
        callback null, some

module.exports = Item