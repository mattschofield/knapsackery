
PackingStrategy = require './packingStrategy'

class TwoSortPackingStrategy extends PackingStrategy

  constructor: (attributes) ->
    super attributes

  pack: (items, callback) ->
    ###
      The basic algorithm is an improvement of MergePackingStrategy, where
      the important detail is how the items are sorted.

      Rather than having a single list of items sorted by some function of weight and cube,
      this algorithm will use TWO sorted lists, one sorted by weight ascending, the other by cube ascending.

      The item to be packed will be chosen by checking the first item in BOTH lists, and seeing
      which would result in the least remaining space after packing.
  
    ###
    callback new Error "TODO"

module.exports = TwoSortPackingStrategy