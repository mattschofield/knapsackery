knapsackery
===========

An attempted solution to the problem posed by Ampersand Commerce at 2013's Manchester StudentHack. http://ampersandcommerce.com/studenthack13/

TODO:

Automatically calculate weightings to item ordering.
- need to know the average ratio of weight:cube and balance it out to order the items
- e.g. if weight = 2*cube, apply 0.33 to weight and 0.67 to cube. Should work (ish).

Build into a web-service and test

if there's time: 

Try different packing approach:
1. Keep instantiating large vans and adding item at a time
2. When all items are added to a van, try and minimise the van.