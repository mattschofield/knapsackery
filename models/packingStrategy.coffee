_ = require 'underscore'
async = require 'async'

Van = require './van'
Item = require './item'
###

A class to provide a generic interface with methods for packing items into vans
This is an abstraction according to the Strategy software design pattern. 
Concrete implementations of this class will exist for specific algorithms

###
class PackingStrategy

  constructor: (attributes) ->
    @[k]=v for k,v of attributes
    @ 

  packEachItem: (items, callback) ->
    packedVans = []
    unpackableItems = []

    q = async.queue((task, cb) ->
      Van.bestVanForItem task.item, (err, van) ->
        cb new Error err if err
        van?.packItem task.item
        packedVans.push van if van?
        unpackableItems.push task.item if not van?
        cb()
    , 6)

    # assign a callback
    q.drain = -> 
      callback null, unpackableItems, packedVans

    for item in items
      q.push { item: item }, (err) ->
        console.log err if err

  removeSortedItem: (items, index) ->
    for i in [index...items.length]
      items[i] = items[i+1]
    items.pop() # remove undef off the end
    return items

  removeItemByItem: (itemList, item) ->
    removed = _.reject itemList, (i) -> i.id is item.id
    return removed

  # returns the index of the van in vans
  findVanByItemId: (vans, id) ->
    found = _.find vans, (van) -> 
      _.find van.items, (item) ->
        item.id is id

    return -1 if not found?
    foundIndex = _.indexOf vans, found
    return foundIndex

  sortVans: (v1, v2) ->
    if parseFloat(v1.remainingWeight) is parseFloat(v2.remainingWeight)
      return 0
    else
      if parseFloat(v1.remainingWeight) > parseFloat(v2.remainingWeight)
        return 1
      else
        return -1

  sortItemsWeighted: (i1, i2) ->
    if (0.33 * parseFloat(i1.weight)) + (0.67 * parseFloat(i1.cube)) is (0.33 * parseFloat(i2.weight)) + (0.67 * parseFloat(i2.cube))
    # if parseFloat(i1.weight) + parseFloat(i1.cube) is parseFloat(i2.weight) + parseFloat(i2.cube)
      return 0
    else
      if (0.33 * parseFloat(i1.weight)) + (0.67 * parseFloat(i1.cube)) > (0.33 * parseFloat(i2.weight)) + (0.67 * parseFloat(i2.cube))
      # if parseFloat(i1.weight) + parseFloat(i1.cube) > parseFloat(i2.weight) + parseFloat(i2.cube)
        return 1
      else
        return -1

  pruneEmptyVans: (vans) ->
    pruned = _.reject vans, (van) -> van.items.length is 0
    return pruned

module.exports = PackingStrategy