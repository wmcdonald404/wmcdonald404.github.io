---
layout: default
title: Recipes
---

{% for recipe in site.recipes %}
  <div class="post-link">
    <a href="{{ recipe.url | prepend: site.baseurl }}">
      <h3>{{ recipe.title }}</h3>
    </a>
  </div>
{% endfor %}
