var Item = require('../models/item');
var MergePackingStrategy = require('../models/mergePackingStrategy');

exports.mergePack = function(req, res) {
  var packer = new MergePackingStrategy({debug:0});
  var items  = [];
  for (var i = 0; i < req.body.items.length; i++) {
    var item = new Item(req.body.items[i]);
    items.push(item);
  };
  packer.pack(items, function(err, vans) {
    if (err) { res.send(500, { error: err.message }); }
    else {
      var response = { vans: [] };
      var cost = 0, noItems = 0;
      for (var i = 0; i < vans.length; i++) {
        cost    += vans[i].cost
        noItems += vans[i].items.length 
        var packages = []
        for (var j = 0; j < vans[i].items.length; j++) {
          packages.push(vans[i].items[j].id)
        };
        response.vans.push({ 
          van_id: vans[i].id,  
          packages: packages,
          total_weight: vans[i].maximum_weight - vans[i].remainingWeight,
          total_cube: vans[i].maximum_cube - vans[i].remainingCube
        })
      };
      response.cost = cost;
      response.noItems = noItems;
      response.noVans = vans.length;
      res.json(response);
    }
  })  
}