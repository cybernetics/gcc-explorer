ifeq "" "$(shell which npm)"
default:
	@echo "Please install node.js"
	@echo "Visit http://nodejs.org/ for more details"
	@echo "On Ubuntu/Debian try: sudo apt-get install nodejs npm"
	exit 1
else
NODE:= $(shell which node || which nodejs)
default: run
endif

.PHONY: clean run test run-amazon c-preload optional-d-support prereqs
prereqs: optional-d-support node_modules c-preload

ifeq "" "$(shell which gdc)"
optional-d-support:
	@echo "D language support disabled"
else
optional-d-support:
	$(MAKE) -C d
endif

NODE_MODULES=.npm-updated
$(NODE_MODULES): package.json
	npm install
	@touch $@

node_modules: $(NODE_MODULES)

test:
	(cd test; $(NODE) test.js)
	@echo Tests pass

clean:
	rm -rf node_modules .npm-updated

run: node_modules optional-d-support c-preload
	$(NODE) ./node_modules/.bin/supervisor --exec $(NODE) ./app.js

c-preload:
	$(MAKE) -C c-preload

run-amazon: node_modules optional-d-support c-preload
	$(NODE) ./node_modules/.bin/supervisor --exec $(NODE) -- ./app.js --env amazon

run-amazon-d: node_modules optional-d-support c-preload
	$(NODE) ./node_modules/.bin/supervisor --exec $(NODE) -- ./app.js --env amazon-d

