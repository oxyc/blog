---
layout: page
title: Categories
---
{{ page.title }}
================

<ul class="tags">
{% assign taglist = site.tags %}
{% include taglist %}
</ul>

{% for tag in site.tags %}
  <h2 id="{{ tag[0] }}">{{ tag[0] }}</h2>
  <ul>
  {% assign pagelist = tag[1] %}
  {% include pagelist %}
  </ul>
{% endfor %}
