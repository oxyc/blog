BIN := ./node_modules/.bin

# 3rd party JavaScript components
COMPONENTS ?= assets/components/es5-shim/es5-shim.min.js assets/components/rsvp/rsvp.min.js assets/components/basket.js/dist/basket.min.js
# 3rd party CSS components
CSS_LIBS ?= assets/components/normalize-css/normalize.css

JS ?= assets/js/main.js
CSS_DIST ?= assets/stylesheets
JS_DIST ?= assets/scripts
STYLUS_DIR ?= assets/stylus
STYLUS_FILE ?= assets/stylus/styles.styl

# Filename of the new article
FILE = $(shell date "+./_posts/%Y-%m-%d-$(TOPIC).md" | sed -e y/\ /-/)
TOPIC ?= new article

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
	@jekyll

serve: build
	@jekyll --server

css: stylus

js: browserify concat

# STYLESHEETS ---------------------------------------------

stylus:
	@$(BIN)/stylus $(STYLUS_FILE) --out $(CSS_DIST) $(ARGS)

convert: $(CSS_LIBS:.css=.styl)

%.styl: %.css
	@$(BIN)/stylus --css $< $(STYLUS_DIR)/$(notdir $@)

watch:
	@make ARGS=--watch stylus &

# JAVASCRIPT ----------------------------------------------

browserify: $(JS)
	$(BIN)/browserify $^ -o $(JS_DIST)/script.js

concat: $(COMPONENTS)
	@cat $^ > $(JS_DIST)/components.min.js

jshint: .bowerrc .jshintrc *.json assets/js
	@$(BIN)/jshint $(ARGS) $^

# Development ---------------------------------------------

# https://github.com/mojombo/jekyll/issues/762
dev-install:
	@gem install rdoc jekyll
	@npm install --dev
	@bower install
	@make convert

clean:
	@rm -rf _site/*
	@rm -rf assets/stylesheets/*
	@rm -rf assets/scripts/*

.PHONY: build serve watch dev-install clean
