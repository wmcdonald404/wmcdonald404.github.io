---
layout: default
title: Recipes
---

{% for recipe in site.recipes %}
  <div class="post-link">
    <h2><a href="{{ recipe.url }}">{{ recipe.title }}</a></h2>
  </div>
{% endfor %}

<!-- 
{% for recipe in site.recipes %}

<a href="{{ recipes.url | prepend: site.baseurl }}">
  <h2>{{ recipes.title }}</h2>
</a>

<p class="post-excerpt">{{ recipes.description | truncate: 160 }}</p>

{% endfor %} -->