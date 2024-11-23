---
layout: page
title: recipes
permalink: /recipes
---

## Recipes

{% for post in site.recipes %}
- {{ post.date | date_to_string }}: [{{ post.title }}]({{ post.url | relative_url }})
{% endfor %}