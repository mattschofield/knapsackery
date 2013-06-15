require 'should'
require 'mocha'
require 'colors'

Item = require '../models/item'

describe 'Item'.magenta, ->
  describe 'create'.yellow, ->
    item = null
    before ->
      item = new Item 
        id: 12
        weight: 150
        cube: 60

    it 'has all the attributes we want after creation', ->
      for attr in ['id','weight','cube']
        item.should.have.property attr

    it 'should be valid with all the correct attributes', ->
      item.valid.should.be.ok

  describe 'createFail'.yellow, -> 
    item = null
    attributes = null
    before -> 
      attributes =
        id: 12
        weight: 150

    it 'should be invalid if not all of the required attributes exist', ->
      item = new Item attributes
      item.valid.should.not.be.ok

  describe 'all'.yellow, ->
    it 'should return all items in the database', (done) ->
      Item.all (err, items) ->
        return done(err) if err
        items.should.be.ok
        items.should.be.an.instanceOf Array
        items.should.have.length 150
        item.should.be.an.instanceOf(Item) for item in items
        done()

  describe 'some'.yellow, ->
    it 'should return a small sample of some items', (done) ->
      Item.some 5, (err, items) ->
        return done(err) if err
        items.should.be.ok
        items.should.be.an.instanceOf Array
        items.should.have.length 5
        item.should.be.an.instanceOf Item for item in items
        done()
