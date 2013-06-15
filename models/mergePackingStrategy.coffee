
async = require 'async'
_ = require 'underscore'

# superclass
PackingStrategy = require './packingStrategy'
Van = require './van'

class MergePackingStrategy extends PackingStrategy

  constructor: ->
    @

  pack: (items, callback) ->
    self = @
    optimalVans = []
    ### 
      The rough outline for this algorithm is as follows
      
      GIVEN: an array of items

      1. put each item into it's own maximally small van (i.e. the cheapest van it will fit into)
      2. order the vans by the amount of remaining space ASCENDING
      3. order each item by size ASCENDING
      4. foreach van in ordered vans ->
       .    if the space remaining in the van is smaller than the smallest item, it's optimally packed.
       .    otherwise, find the maximal smallest item that would fit, and pack it.
      5. Repeat until no more changes occur

    ###

    @packEachItem items, (err, unpackableItems, packedVans) ->
      sortedItems = self.sortItems items
      # we can ignore the unpackable items, we don't have vans big enough
      sortedPackables = _.difference sortedItems, unpackableItems

      sortedVans = self.sortVans packedVans

      while sortedVans.length > 0
        if sortedVans.length is 1 and sortedVans[0].items.length
          optimalVans.push sortedVans.shift()
          break
        sortedItems = _.reject sortedItems, (item) -> parseInt(item.id) is parseInt(sortedVans[0].items[0].id)

        if not sortedVans[0].fitsItem sortedItems[0] # the smallest item
          # then this van is optimally packed
          for item in sortedVans[0].items
            sortedItems = self.removeItemByItem sortedItems, item
          optimalVans.push sortedVans.shift()
        else

          # find the maximally small item that will fit
          lastFoundIndex = 0
          found = false

          while not found and lastFoundIndex < sortedItems.length-1
            if sortedVans[0].fitsItem sortedItems[lastFoundIndex+1]
              lastFoundIndex += 1
            else
              found = true

          # maximally small item that will fit in sortedVans[0] is sortedItems[lastFoundIndex]
          toPack      = sortedItems[lastFoundIndex]
          vanIndex    = self.findVanByItemId sortedVans, toPack.id
          sortedItems = self.removeSortedItem sortedItems, lastFoundIndex

          sortedVans[vanIndex].unpackItem toPack
          sortedVans[0].packItem toPack

          sortedVans = self.pruneEmptyVans sortedVans
          # sortedVans = self.sortVans sortedVans

      # console.log optimalVans
      # console.log "==========="
      # console.log sortedVans

      callback null, optimalVans

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

  sortVans: (vans) ->
    sorted = vans.sort (v1, v2) -> 
      w = v1.remainingWeight - v2.remainingWeight
      if w is not 0 
        return w
      else
        return v1.remainingCube - v2.remainingCube
    return sorted

  sortItems: (items) ->
    sorted = items.sort (i1, i2) ->
      w = i1.weight - i2.weight
      if w is not 0
        return w
      else
        return i1.cube - i2.cube
    return sorted

  pruneEmptyVans: (vans) ->
    pruned = _.reject vans, (van) -> van.items.length is 0
    return pruned

module.exports = MergePackingStrategy