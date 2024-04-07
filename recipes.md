---
layout: default
title: Recipes
---

{% for recipe in site.recipes %}
  <div class="post-link">
    <a href="{{ recipe.url | prepend: site.baseurl }}">
      <h2>{{ recipe.title }}</h2>
    </a>
  </div>
{% endfor %}

<!-- 
{% for recipe in site.recipes %}

<a href="{{ recipes.url | prepend: site.baseurl }}">
  <h2>{{ recipes.title }}</h2>
</a>

<p class="post-excerpt">{{ recipes.description | truncate: 160 }}</p>

<h2><a href="{{ recipe.url }}">{{ recipe.title }}</a></h2>

{% endfor %} -->