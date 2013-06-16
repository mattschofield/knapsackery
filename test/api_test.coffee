
require 'should'
require 'colors'

async = require 'async'
request = require 'request'
fs = require 'fs'

describe 'API'.magenta, ->
  
  describe 'POST /packer/merge', ->

    it 'should respond', (done) ->
      json = JSON.parse fs.readFileSync(__dirname+'/../lib/packages.json') 
      request { method: "POST", uri: 'http://localhost:3000/packer/merge', body: { "items": json }, json: true }, (err, res, body) ->
        return done(err) if err
        console.log "\n\ttotal_cost:\t#{body.cost}"
        console.log "\tnum_vans:\t#{body.noVans}"
        console.log "\tnum_items:\t#{body.noItems}"
        console.log "\tvans: ["
        for van in body.vans
          console.log "\t    { id: #{van.van_id}, packages: [#{item for item in van.packages}], total_weight: #{van.total_weight}, total_cube: #{van.total_cube} }"
        done()


