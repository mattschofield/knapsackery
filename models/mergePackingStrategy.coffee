
async = require 'async'
_ = require 'underscore'

# superclass
PackingStrategy = require './packingStrategy'
Van = require './van'

class MergePackingStrategy extends PackingStrategy

  constructor: (attributes) ->
    @[k]=v for k,v of attributes
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
      items.sort self.sortItems
      # we can ignore the unpackable items, we don't have vans big enough
      sortedPackables = _.difference items, unpackableItems

      sortedVans = packedVans.sort self.sortVans

      while sortedVans.length > 0
        if sortedVans.length is 1 and sortedVans[0].items.length
          console.log "OPTIMAL: 1(#{sortedVans[0].remainingWeight},#{sortedVans[0].remainingCube})".green if self.debug
          optimalVans.push sortedVans.shift()
          break
        
        # remove any items from items that are packed in sortedVans[0]
        items = _.reject items, (item) -> (_.contains sortedVans[0].items, item)

        if not sortedVans[0].fitsItem items[0] # the smallest item
          # then this van is optimally packed
          for item in sortedVans[0].items
            items = self.removeItemByItem items, item

          console.log "OPTIMAL: 1(#{sortedVans[0].remainingWeight},#{sortedVans[0].remainingCube})".green if self.debug
          optimalVans.push sortedVans.shift()
        else

          # find the maximally small item that will fit
          lastFoundIndex = 0
          found = false

          console.log "\n----------------" if self.debug
          console.log "Remaining W,C:(#{sortedVans[0].remainingWeight},#{sortedVans[0].remainingCube}). I:#{items[lastFoundIndex].id}(#{items[lastFoundIndex].weight},#{items[lastFoundIndex].cube}) in V:1 will fit. " if self.debug
          while not found and lastFoundIndex < items.length
            m = ""
            if lastFoundIndex is items.length-1
              console.log "REACHED THE LAST ITEM".green if self.debug
              break

            containingVan = self.findVanByItemId sortedVans, items[lastFoundIndex+1].id
            m += "Will I:#{items[lastFoundIndex+1].id}(#{items[lastFoundIndex+1].weight},#{items[lastFoundIndex+1].cube})(V:#{containingVan+1})?\t(#{lastFoundIndex+1}/#{items.length})"
            if sortedVans[0].fitsItem items[lastFoundIndex+1]
              m += "\tYes!"
              lastFoundIndex += 1
            else
              m += "\tNo."
              found = true
            console.log m if self.debug

          # maximally small item that will fit in sortedVans[0] is items[lastFoundIndex]
          toPack      = items[lastFoundIndex]
          console.log "PACKING: #{toPack.id}(#{toPack.weight},#{toPack.cube})".red if self.debug

          vanIndex    = self.findVanByItemId sortedVans, toPack.id
          items       = self.removeSortedItem items, lastFoundIndex

          console.log "UNPACKING: I:#{toPack.id} from V:#{vanIndex+1}(#{sortedVans[vanIndex].remainingWeight},#{sortedVans[vanIndex].remainingCube})".yellow if self.debug
          sortedVans[vanIndex].unpackItem toPack
          console.log "UNPACKED: I:#{toPack.id} from V:#{vanIndex+1}(#{sortedVans[vanIndex].remainingWeight},#{sortedVans[vanIndex].remainingCube})".cyan if self.debug

          console.log "PACKING: I:#{toPack.id} into V:1(#{sortedVans[0].remainingWeight},#{sortedVans[0].remainingCube})".yellow if self.debug
          sortedVans[0].packItem toPack
          console.log "PACKED: I:#{toPack.id} into V:1(#{sortedVans[0].remainingWeight},#{sortedVans[0].remainingCube})".cyan if self.debug

          sortedVans = self.pruneEmptyVans sortedVans
          sortedVans.sort self.sortVans

      if self.debug
        console.log optimalVans
        console.log "==========="
        console.log sortedVans

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

  sortVans: (v1, v2) ->
    if parseFloat(v1.remainingWeight) is parseFloat(v2.remainingWeight)
      return 0
    else
      if parseFloat(v1.remainingWeight) > parseFloat(v2.remainingWeight)
        return 1
      else
        return -1

  sortItems: (i1, i2) ->
    if parseFloat(i1.weight) + parseFloat(i1.cube) is parseFloat(i2.weight) + parseFloat(i2.cube)
      return 0
    else
      if parseFloat(i1.weight) + parseFloat(i1.cube) > parseFloat(i2.weight) + parseFloat(i2.cube)
        return 1
      else
        return -1

  pruneEmptyVans: (vans) ->
    pruned = _.reject vans, (van) -> van.items.length is 0
    return pruned

module.exports = MergePackingStrategy