---
title: How to use Makefiles in your web projects
layout: post
tags: ['shell', 'makefile', 'build']
---
<p class="preamble">Every projected created has some form of build process, be
it a large web application or a small reusable AMD component, it has one.
There are also a ton of tools that can help you with automating this process,
one popular tool gaining a lot of traction these days is the awesome <a
href="http://gruntjs.com">grunt tool</a> which you definitely should take an
intense gaze at.</p>

<p class="preamble">However! For some projects grunt might not be the right
tool for you, sometimes you can be more productive with simple shell utilities
than you can with node.js. Today I'm going to give a very quick introduction
to the GNU Make utility and how you can use its awesome sauce (yes it's really
like a sauce connecting the awesomeness of the shell) to automate your build
steps.</p>

The concept of a makefile
-------------------------
A makefile consists of a set of entries that has its own specific purpose. As
we obviously love UNIX, now is the time to remind yourself of the "write
*entries* that do one thing and do it well" rule. Each of these entries has:

* a target, you know `make install`? install is the target. But it can also
  be a file, eg. `make bundle.min.js`.
* dependencies, an optional set of files the target depends on.
* and finally the commands to run.

When you create your entries you want to make them as easy to use as possible,
but at the same time as flexible as possible. For example by default you want
to minimize a predefined set of files but once in a while you might want to
specify some other file without going into the makefile and digging out the
commands.

Making targets flexible
-----------------------

To increase flexibility, predefined dependencies of a target can be overridden
from the command line by listing them after the target name:

    $ make min index.js plugins.js
    $ make min // defaults to index.js

Additionally a common way of overriding defaults is to set paths as variables
in the makefile itself and then allowing the user to override them like:

    $ make JSMIN=./bin/jsmin min

Implementing a min target
-------------------------

Alright, so create your Makefile and follow me.

The syntax for a target is:

    <target>: <dependencies>
        commands...

As I mentioned earlier, the target can be a general name or a file, for now
we'll keep to names such as `min` or `install`. Dependencies are a space
separated list of *files* you want to process or of other *targets* you want
to run. Let's create our first target.

{% highlight makefile %}
min: index.js plugins.js
    uglify --output scripts.min.js $^
{% endhighlight %}

The `$^` is a variable which holds a space separated list of the dependencies.
It will be expanded into: `uglify --output scripts.min.js index.js plugins.js`.

Now this is entry is somewhat flexible as you could run `make min plugins.js`
to replace the default dependencies and only minimize plugins.js. However,
let's refactor this into something prettier.

A web project makefile
----------------------

First lets define some variables.

{% highlight makefile %}
# ?= means the variable can be overridden from the command line like:
# make UGLIFY=./node_modules/.bin/uglify min
UGLIFY ?= uglify
OUTPUT ?= scripts.min.js
JS_FILES := index.js plugins.js

min: $(JS_FILES)
    $(UGLIFY) --output $(OUTPUT) $^
{% endhighlight %}

Now let's split out the concat task so we can use it separately

{% highlight makefile %}
UGLIFY ?= uglify
OUTPUT ?= scripts.min.js
JS_FILES := index.js plugins.js

min: $(JS_FILES)
    make concat $(JS_FILES)
    $(UGLIFY) --output $(OUTPUT) $(OUTPUT)

concat: $(JS_FILES)
    cat $^ > $(OUTPUT)
{% endhighlight %}

Now we're getting somewhere, however the min task looks really ugly. Let's put
in some awesome sauce.

{% highlight makefile %}
UGLIFY ?= uglify
OUTPUT ?= script.js
JS_FILES := index.js plugins.js

# For each file in JS_FILES, replace .js by .min.js and run it as the target
# with the original as a dependency.
# In plain English, iterate over each file and minimize as well as rename it.
min: $(JS_FILES:.js=.min.js)

# $@ is the target and $< is the dependency.
%.min.js: %.js
    $(UGLIFY) --output $@ $<

concat: $(JS_FILES)
    cat $^ > $(OUTPUT)
{% endhighlight %}

You better let that sink in for a bit. Next up is tying everything up in a
nice bow.

{% highlight makefile %}
UGLIFY ?= uglify
DIST ?= dist
OUTPUT ?= $(DIST)/script.js
JS_FILES := index.js plugins.js

# When you run make without a target, the first entry is the one to run,
# usually this is named `all` by convention.
all: concat min

# Rather than minifying every file, default to only minifying the final output.
min: $(OUTPUT:.js=.min.js)

# $@ is the target and $< is the dependency.
# When you put a `@` in front of a command, the stdout will be suppressed,
# making for a cleaner terminal.
%.min.js: %.js
    @$(UGLIFY) --output $@ $<

concat: $(JS_FILES)
    @cat $^ > $(OUTPUT)

# It's useful to have a cleanup task as well.
clean:
    @rm -f $(DIST)/*

# Phony targets are targets that do not accept dependencies, it's good
# practice to define this as targets might have the same name as files from time
# to time and therefore create confusion. Also it's a small performance
# improvement.
.PHONY: clean all
{% endhighlight %}

Alright, that's our makefile.

### How to use it

Concat and minify index.js and plugins.js into dist/script.min.js (these all do
the same thing).

    $ make
    $ make all
    $ make concat min

Specify the location of uglify

    $ make UGLIFY=./node_modules/.bin/uglify

Concat some other files

    $ make OUTPUT=temp.js concat js/*

Minify all files but put them in a separate directory

    $ make DIST=minified min js/*

Clean up all the distribution files created

    $ make clean

[grunt]: http://www.gruntjs.com
