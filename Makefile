
OUT_DIR=./dist
BROWSERS_TEST_DIR=./browsers-test
MODULES_DIR=$(OUT_DIR)/modules
MODULES_SUMO_DIR=$(OUT_DIR)/modules-sumo
BROWSERS_DIR=$(OUT_DIR)/browsers
BROWSERS_SUMO_DIR=$(OUT_DIR)/browsers-sumo
LIBSODIUM_DIR=./libsodium
LIBSODIUM_JS_DIR=$(LIBSODIUM_DIR)/libsodium-js
LIBSODIUM_JS_SUMO_DIR=$(LIBSODIUM_DIR)/libsodium-js-sumo

UGLIFY = uglifyjs --stats --mangle --compress sequences=true,dead_code=true,conditionals=true,booleans=true,unused=true,if_return=true,join_vars=true,drop_console=true --

all: pack
	@echo
	@echo Standard distribution
	@echo =====================
	@ls -l $(MODULES_DIR)/
	@echo
	@echo Sumo distribution
	@echo =================
	@ls -l $(MODULES_SUMO_DIR)/


standard: $(MODULES_DIR)/libsodium-wrappers.js
	@echo + Building standard distribution

sumo: $(MODULES_SUMO_DIR)/libsodium-wrappers.js
	@echo + Building sumo distribution

tests: browsers-tests

browsers-tests: $(LIBSODIUM_DIR)/test/default/browser/sodium_core.html
	@echo + Building web browsers tests

targets: standard sumo

pack: targets
	@echo + Packing
	for i in $(MODULES_DIR)/*.js $(MODULES_SUMO_DIR)/*.js $(BROWSERS_DIR)/*.js $(BROWSERS_SUMO_DIR)/*.js; do \
	  echo "Packing [$$i]" ; \
	  $(UGLIFY) $$i > $$i.tmp && mv -f $$i.tmp $$i  ; \
	done

$(MODULES_DIR)/libsodium-wrappers.js: wrapper/build-wrappers.js wrapper/build-doc.js wrapper/wrap-template.js
	@echo +++ Building standard/libsodium-wrappers.js
	mkdir -p $(MODULES_DIR)
	nodejs wrapper/build-wrappers.js libsodium API.md $(MODULES_DIR)/libsodium-wrappers.js 2>/dev/null || node wrapper/build-wrappers.js libsodium API.md $(MODULES_DIR)/libsodium-wrappers.js

$(MODULES_SUMO_DIR)/libsodium-wrappers.js: wrapper/build-wrappers.js wrapper/build-doc.js wrapper/wrap-template.js
	@echo +++ Building sumo/libsodium-wrappers.js
	mkdir -p $(MODULES_SUMO_DIR)
	nodejs wrapper/build-wrappers.js libsodium-sumo API.md $(MODULES_SUMO_DIR)/libsodium-wrappers.js 2>/dev/null || node wrapper/build-wrappers.js libsodium-sumo API_sumo.md $(MODULES_SUMO_DIR)/libsodium-wrappers.js

$(LIBSODIUM_DIR)/test/default/browser/sodium_core.html: $(LIBSODIUM_DIR)/configure
	cd $(LIBSODIUM_DIR) && ./dist-build/emscripten.sh --browser-tests
	rm -f $(LIBSODIUM_DIR)/test/default/browser/*.asm.html $(LIBSODIUM_DIR)/test/default/browser/*.asm.js
	rm -fr $(BROWSERS_TEST_DIR) && cp -R $(LIBSODIUM_DIR)/test/default/browser $(BROWSERS_TEST_DIR)

$(LIBSODIUM_DIR)/configure: $(LIBSODIUM_DIR)/configure.ac
	cd $(LIBSODIUM_DIR) && ./autogen.sh

$(LIBSODIUM_DIR)/configure.ac: .gitmodules
	git submodule update --init --recursive



clean:
	rm -f $(LIBSODIUM_DIR)/js.done $(LIBSODIUM_DIR)/js-sumo.done $(LIBSODIUM_DIR)/browser-js.done
	rm -rf $(BROWSERS_TEST_DIR)
	rm -fr $(LIBSODIUM_DIR)/test/default/browser
	rm -rf $(LIBSODIUM_JS_DIR)
	rm -rf $(LIBSODIUM_JS_SUMO_DIR)
	rm -rf $(OUT_DIR)
	-cd $(LIBSODIUM_DIR) && make distclean

distclean: clean

rewrap:
	rm -fr $(OUT_DIR)
	make
