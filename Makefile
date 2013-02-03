BIN := ./node_modules/.bin

# Bin files
STYLUS ?= $(BIN)/stylus
BROWSERIFY ?= $(BIN)/browserify
JSHINT ?= $(BIN)/jshint
JEKYLL ?= jekyll
BOWER ?= bower
GEM ?= gem
NPM ?= npm

# Directories
ASSETS_DIR ?= assets
COMPONENTS_DIR ?= $(ASSETS_DIR)/components
DIST_DIR ?= $(ASSETS_DIR)/dist
STYLUS_DIR ?= $(ASSETS_DIR)/stylus
JS_DIR ?= $(ASSETS_DIR)/js

# 3rd party components
JS_COMPONENTS ?= $(COMPONENTS_DIR)/es5-shim/es5-shim.min.js \
								 $(COMPONENTS_DIR)/rsvp/rsvp.min.js \
								 $(COMPONENTS_DIR)/basket.js/dist/basket.min.js
CSS_COMPONENTS ?= $(COMPONENTS_DIR)/normalize-css/normalize.css

# Files to be compiled
JS_FILES ?= $(JS_DIR)/main.js
STYLUS_FILES ?= $(STYLUS_DIR)/styles.styl
COMPONENTS_DIST ?= $(DIST_DIR)/components.min.js
JS_DIST ?= $(DIST_DIR)/script.js

# Filename of the new article
TOPIC ?= new article
FILE = $(shell date "+./_posts/%Y-%m-%d-$(TOPIC).md" | sed -e y/\ /-/)

all: build

# Blogging ------------------------------------------------

new:
	@echo "---" >> $(FILE)
	@echo "title: $(TOPIC)" >> $(FILE)
	@echo "layout: post" >> $(FILE)
	@echo "published: false" >> $(FILE)
	@echo "---" >> $(FILE)

# Building ------------------------------------------------

build: clean css js
	@$(JEKYLL) $(ARGS)

serve: clean watch js
	@$(JEKYLL) --server --auto

css: stylus

js: browserify concat

# STYLESHEETS ---------------------------------------------

stylus: $(STYLUS_FILES)
	@$(STYLUS) $^ --out $(DIST_DIR) $(ARGS)

# Convert css into stylus syntax
convert: $(CSS_COMPONENTS:.css=.styl)

%.styl: %.css
	@$(STYLUS) --css $< $(STYLUS_DIR)/$(notdir $@)

watch:
	@make ARGS=--watch stylus &

# JAVASCRIPT ----------------------------------------------

browserify: $(JS_FILES)
	$(BROWSERIFY) $^ -o $(JS_DIST)

concat: $(JS_COMPONENTS)
	@cat $^ > $(COMPONENTS_DIST)

jshint: .bowerrc .jshintrc *.json $(JS_DIR)
	@$(JSHINT) $(ARGS) $^

# Development ---------------------------------------------

# https://github.com/mojombo/jekyll/issues/762
dev-install:
	@$(GEM) install rdoc jekyll
	@$(NPM) install --dev
	@$(BOWER) install
	@test -e .git/hooks/pre-commit || { cd .git/hooks && ln -s ../../bin/pre-commit . & cd -; }
	@make convert

clean:
	@rm -rf _site/*
	@rm -rf $(DIST_DIR)/*

.PHONY: build serve watch dev-install clean
