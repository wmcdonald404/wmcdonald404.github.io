---
layout: page
title: Recipes
permalink: /recipes
---

<img src="/assets/images/Under-Siege-Seagal-Cover-3554673406.jpg" width="500" title="I also cook!" alt="Steven Segal, from Under Siege" />

{% for post in site.recipes %}
- {{ post.date | date_to_string }}: [{{ post.title }}]({{ post.url | relative_url }})
{% endfor %}