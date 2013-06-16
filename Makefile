test:
	@./node_modules/.bin/mocha --timeout 20000 --compilers coffee:coffee-script -R spec ./test/*_test.coffee

merge-test:
	@./node_modules/.bin/mocha --timeout 20000 --compilers coffee:coffee-script -R spec ./test/mergePackingStrategy_test.coffee

api-test:
	@./node_modules/.bin/mocha --timeout 20000 --compilers coffee:coffee-script -R spec ./test/api_test.coffee	

.PHONY: test