---
layout: page
title: Oskar Schöldström's blog
---
{{ page.title }}
================

A web development blog. Frequent topics will include JavaScript, shell scripting, productivity tools
and archlinux.

### Recent articles

<ul class="posts">
{% for post in site.posts %}
  <li><a href="{{ post.url }}"><time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date_to_string }}</time><span>{{ post.title }}</span></a></li>
{% endfor %}
</ul>

### Categories

{% unless site.tags == empty %}
  <ul class="tags">
  {% assign taglist = site.tags %}
  {% include taglist %}
  </ul>
{% endunless %}
