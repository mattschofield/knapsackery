
require 'should'
require 'mocha'
require 'colors'

Van = require '../models/van'
Item = require '../models/item'

describe 'Van'.magenta, ->

  describe 'create'.yellow, ->
    van = null
    before ->
      van = new Van
        id: 1
        description: "Luton"
        maximum_weight: 720
        maximum_cube: 400
        cost: 120

    it 'should have all the attributes we expect after creation', ->
      for attr in ["id", "description", "maximum_weight", "maximum_cube", "cost"]
        van.should.have.property attr

    it 'should be valid with all the correct attributes', ->
      van.valid.should.be.ok
  describe 'createFail'.yellow, ->
    van = null
    before -> 
      van = new Van
        id: 1
        description: "Luton"
        maximum_weight: 720
        maximum_cube: 400

    it 'should be invalid if not all of the required attributes exist', ->
      van.valid.should.not.be.ok
  describe 'all'.yellow, ->
    it 'should return all vans in the database', (done) ->
      Van.all (err, vans) ->
        return done(err) if err
        vans.should.be.ok
        vans.should.be.an.instanceOf Array
        vans.should.have.length 3
        van.should.be.an.instanceOf(Van) for van in vans
        van.valid.should.be.ok for van in vans
        done()
  describe 'some'.yellow, ->
    it 'should return n number of vans', (done) ->
      Van.some 3, (err, vans) ->
        return done(err) if err
        vans.should.be.ok
        vans.should.be.an.instanceOf Array
        vans.should.have.length 3
        van.should.be.an.instanceOf Van for van in vans
        van.valid.should.be.ok for van in vans
        done()
  describe 'largest'.yellow, ->
    it 'should return the largest van in the database', (done) ->
      Van.largest (err, van) ->
        return done(err) if err
        parseInt(van.maximum_weight).should.be.equal 720
        parseInt(van.maximum_cube).should.be.equal 400
        done()
  describe 'smallest'.yellow, ->
    it 'should return the smallest van in the database', (done) ->
      Van.smallest (err, van) ->
        return done(err) if err
        parseInt(van.maximum_weight).should.be.equal 370
        parseInt(van.maximum_cube).should.be.equal 191
        done()
  describe 'medium'.yellow, ->
    it 'should return the medium van in the database', (done) ->
      Van.medium (err, van) ->
        return done(err) if err
        parseInt(van.maximum_weight).should.be.equal 480
        parseInt(van.maximum_cube).should.be.equal 250
        done()
 
  describe 'packItem'.yellow, ->
    tiny = small = mid = large = huge = toobig = null
    vans = []
    before (done) ->
      tiny  = { weight: 10,  cube: 10 }
      small = { weight: 360, cube: 180 }
      mid   = { weight: 380, cube: 180 }
      large = { weight: 470, cube: 260 }
      huge  = { weight: 690, cube: 350 }
      toobig= { weight: 1000,cube: 1000 }

      Van.all (err, allVans) ->
        return done(err) if err
        vans.push(new Van van) for van in allVans
        done()

    it 'should store an item if it has space', ->
      van.should.be.an.instanceOf Van for van in vans
      [sv,mv,bv] = [vans[2], vans[1], vans[0]]

      # before packing anything, the remaining weight should equal maximum
      sv.maximum_weight.should.be.equal sv.remainingWeight
      sv.maximum_cube.should.be.equal sv.remainingCube
      mv.maximum_weight.should.be.equal mv.remainingWeight
      mv.maximum_cube.should.be.equal mv.remainingCube
      bv.maximum_weight.should.be.equal bv.remainingWeight
      bv.maximum_cube.should.be.equal bv.remainingCube

      # sv should fit 2 x tiny and 1 x small item
      sv.packItem(tiny).should.be.ok
      sv.remainingWeight.should.be.equal sv.maximum_weight - 10
      sv.remainingCube.should.be.equal sv.maximum_cube - 10
      sv.items.should.be.an.instanceOf(Array).with.lengthOf 1

      sv.packItem(small).should.be.ok
      sv.remainingWeight.should.be.equal sv.maximum_weight - 10 - 360
      sv.remainingCube.should.be.equal sv.maximum_cube - 10 - 180
      sv.items.should.be.an.instanceOf(Array).with.lengthOf 2

      sv.packItem(tiny).should.not.be.ok 
      sv.items.should.be.an.instanceOf(Array).with.lengthOf 2

      # mv should fit 1 x mid
      mv.packItem(mid).should.be.ok
      mv.remainingWeight.should.be.equal mv.maximum_weight - 380
      mv.remainingCube.should.be.equal mv.maximum_cube - 180
      mv.items.should.be.an.instanceOf(Array).with.lengthOf 1

      mv.packItem(mid).should.not.be.ok
      mv.packItem(small).should.not.be.ok
      mv.packItem(tiny).should.be.ok

      # bv should fit 1 x huge or 2 x small
      bv.packItem(huge).should.be.ok
      bv.remainingWeight.should.be.equal bv.maximum_weight - 690
      bv.remainingCube.should.be.equal bv.maximum_cube - 350
      bv.items.should.be.an.instanceOf(Array).with.lengthOf 1

      # it should fit 3 more tinys, and then be full
      bv.packItem(tiny).should.be.ok for i in [0..2] 
      bv.packItem(tiny).should.not.be.ok
  
  describe 'unpackItem'.yellow, ->
    it 'should find an item packed in a van and remove it'

  describe 'unpackItem'.yellow, ->
    item = null
    van = null
    before (done) ->
      Item.some 1, (err, items) ->
        return done(err) if err
        item = items[0]
        Van.largest (err, lVan) ->
          return done(err) if err
          van = lVan
          done()

    it 'should return false if the van is already empty', ->
      van.unpackItem(item).should.not.be.ok
      van.remainingWeight.should.be.equal 720
      van.remainingCube.should.be.equal 400

    it 'should pack the item successfully', ->
      van.packItem(item).should.be.ok
      van.items.should.be.an.instanceOf(Array).with.lengthOf 1
      van.remainingWeight.should.be.equal van.maximum_weight - item.weight
      van.remainingCube.should.be.equal van.maximum_cube - item.cube

    it 'should find the item by id and remove it from the van', ->
      van.unpackItem(item).should.be.ok
      van.items.should.be.an.instanceOf(Array).with.lengthOf 0
      van.remainingWeight.should.be.equal van.maximum_weight
      van.remainingCube.should.be.equal van.maximum_cube

  describe 'containsItemById'.yellow, ->
    item1 = item2 = null
    van = null
    before (done) ->
      Item.some 2, (err, items) ->
        return done(err) if err
        item1 = items[0]
        item2 = items[1]
        Van.largest (err, lVan) ->
          return done(err) if err
          van = lVan
          done()

    it 'should return true if a van contains item with id, false otherwise', ->
      van.packItem item1
      van.items.should.be.an.instanceOf(Array).with.lengthOf 1
      van.containsItemById(item1.id).should.be.ok
      van.containsItemById(item2.id).should.not.be.ok

  describe 'fitsItem'.yellow, ->
    tiny = small = mid = large = huge = toobig = null
    vans = []
    before (done) ->
      tiny  = { weight: 10,  cube: 10 }
      small = { weight: 365, cube: 180 }
      mid   = { weight: 380, cube: 180 }
      large = { weight: 470, cube: 260 }
      huge  = { weight: 690, cube: 350 }
      toobig= { weight: 1000,cube: 1000 }

      Van.all (err, allVans) ->
        return done(err) if err
        vans.push(new Van van) for van in allVans
        done()

    it 'should return true if an item fits in a van, false otherwise', ->
      van.should.be.an.instanceOf Van for van in vans
      [sv,mv,bv] = [vans[2], vans[1], vans[0]]

      sv.fitsItem(tiny).should.be.ok
      sv.fitsItem(small).should.be.ok
      sv.fitsItem(mid).should.not.be.ok
      sv.fitsItem(large).should.not.be.ok
      sv.fitsItem(huge).should.not.be.ok
      sv.fitsItem(toobig).should.not.be.ok

      mv.fitsItem(tiny).should.be.ok
      mv.fitsItem(small).should.be.ok
      mv.fitsItem(mid).should.be.ok
      mv.fitsItem(large).should.not.be.ok
      mv.fitsItem(huge).should.not.be.ok
      mv.fitsItem(toobig).should.not.be.ok

      bv.fitsItem(tiny).should.be.ok
      bv.fitsItem(small).should.be.ok
      bv.fitsItem(mid).should.be.ok
      bv.fitsItem(large).should.be.ok
      bv.fitsItem(huge).should.be.ok
      bv.fitsItem(toobig).should.not.be.ok
  describe 'bestVanForItem'.yellow, ->
    tiny = small = mid = large = huge = toobig = null
    before ->
      tiny  = { weight: 10,  cube: 10 }
      small = { weight: 365, cube: 180 }
      mid   = { weight: 380, cube: 180 }
      large = { weight: 470, cube: 260 }
      huge  = { weight: 690, cube: 350 }
      toobig= { weight: 1000,cube: 1000 }

    it 'should return an error for negative weights/volumes', (done) ->
      # this is handled by the Item constructor
      done()

    it 'should return the smallest van for tiny', (done) ->
      Van.bestVanForItem tiny, (err, van) ->
        return done(err) if err
        van.id.should.be.equal "3"
        done()

    it 'should return the smallest van for small', (done) ->
      Van.bestVanForItem small, (err, van) ->
        return done(err) if err
        van.id.should.be.equal "3"
        done()

    it 'should return the medium van for mid', (done) ->
      Van.bestVanForItem mid, (err, van) ->
        return done(err) if err
        van.id.should.be.equal "2"
        done()

    it 'should return the largest van for large', (done) ->
      Van.bestVanForItem large, (err, van) ->
        return done(err) if err
        van.id.should.be.equal "1"
        done()

    it 'should return the largest van for huge', (done) ->
      Van.bestVanForItem huge, (err, van) ->
        return done(err) if err
        van.id.should.be.equal "1" 
        done()

    it 'should return null if the item is just too damn big', (done) ->
      Van.bestVanForItem toobig, (err, van) ->
        return done(err) if err
        if van?
          return done(new Error "Van somehow exists...")
        else
          return done()