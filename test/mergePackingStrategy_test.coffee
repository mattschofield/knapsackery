require 'should'
require 'mocha'
colors = require 'colors'
_ = require 'underscore'
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
          van.items.length.should.be.above 0
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
        debug: false
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

        # we should return with the same number of items as we provided.
        n.should.be.equal someN
        result.cost = cost
        console.log "\n\t#{n}".magenta+" ITEMS PACKED INTO ".cyan+"#{vans.length}".magenta+" VAN#{(if vans.length > 1 then "S" else "")}".cyan
        console.log "\tTOTAL COST: £#{cost}".red
        # console.log result

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

    it 'finds the index of a van containing an item by item.id', ->
      vans[0].packItem items[0]
      vans[0].packItem items[1]
      vans[1].packItem items[2]
      vans[1].packItem items[3] 

      s.findVanByItemId(vans, items[0].id).should.be.equal 0
      s.findVanByItemId(vans, items[1].id).should.be.equal 0
      s.findVanByItemId(vans, items[2].id).should.be.equal 1
      s.findVanByItemId(vans, items[3].id).should.be.equal 1
      s.findVanByItemId(vans, items[4].id).should.be.equal -1 # not found

  describe 'sortItems'.yellow, ->

    s = null
    items = []
    before (done) ->
      s = new MergePackingStrategy
      Item.all (err, all) ->
        return done(err) if err
        items.push(new Item item) for item in all
        done()

    it 'should sort all the items in descending order', ->
      items.should.have.length 150
      items.sort s.sortItems
      items[0].should.be.an.instanceOf Item
      items[0].should.have.property "weight"
      # items[0].weight.should.be.equal 40



