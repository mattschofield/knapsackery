require 'should'
require 'mocha'
require 'colors'

MergePackingStrategy = require '../models/mergePackingStrategy'
Item = require '../models/item'
Van = require '../models/van'

describe 'MergePackingStrategy'.magenta, ->
  
  describe 'packEachItem'.yellow, ->

    items = []
    s = null
    before (done) ->
      s = new MergePackingStrategy
      Item.some 5, (err, someItems) ->
        return done(err) if err
        items.push(new Item item) for item in someItems
        done()

    it 'packs each item into it\'s own optimal van', (done) ->
      s.packEachItem items, (err, unpackableItems, packedVans) ->
        return done(err) if err
        packedVans.should.exist
        packedVans.should.be.an.instanceOf(Array).with.lengthOf items.length
        
        for van in packedVans
          van.should.be.an.instanceOf Van
          item.should.be.an.instanceOf Item for item in van.items when van.items.length > 0

        done()

  describe 'pack'.yellow, ->

    items = []
    s = null
    someN = 150
    cost = 0
    result = {}
    result.vehicles = []

    before (done) ->
      s = new MergePackingStrategy
      Item.some someN, (err, someItems) ->
        return done(err) if err
        items.push(new Item item) for item in someItems
        done()

    it 'packs items into vans without error', (done) ->
      s.pack items, (err, vans) ->
        return done(err) if err
        vans.should.exist
        vans.should.be.an.instanceOf Array

        n = 0
        for van in vans
          cost += parseFloat van.cost

          van.items.length.should.be.above 0
          n += van.items.length

          packages = []
          for item in van.items
            packages.push item.id
          result.vehicles.push { vanId: van.id, totalWeight: van.maximum_weight-van.remainingWeight, totalCube: van.maximum_cube-van.remainingCube, packages: packages }


        n.should.be.equal someN
        result.cost = cost
        console.log result

        done()

  describe 'findVanByItemId'.yellow, ->
    items = []
    vans = []
    s = null
    before (done) ->
      s = new MergePackingStrategy
      Item.some 5, (err, someItems) ->
        return done(err) if err
        items.push(new Item item) for item in someItems
        Van.some 2, (err, someVans) ->
          return done(err) if err
          vans.push(new Van van) for van in someVans
          done()

    it 'finds a van containing an item by item.id', ->
      vans[0].packItem items[0]
      vans[0].packItem items[1]
      vans[1].packItem items[2]
      vans[1].packItem items[3] 

      s.findVanByItemId(vans, items[0].id).should.be.equal 0
      s.findVanByItemId(vans, items[1].id).should.be.equal 0
      s.findVanByItemId(vans, items[2].id).should.be.equal 1
      s.findVanByItemId(vans, items[3].id).should.be.equal 1
      s.findVanByItemId(vans, items[4].id).should.be.equal -1 # not found


