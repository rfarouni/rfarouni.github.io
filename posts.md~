---
layout: page
title : Posts
header : Posts
group: navigation
---
{% include JB/setup %}



<div>
{% assign posts_collate = site.posts %}
{% include JB/posts_collate %}
</div>

---


Categories
=======================
<div>
<ul class="tag_box inline">
  {% assign categories_list = site.categories %}
  {% include JB/categories_list %}
</ul>
{% for category in site.categories %} 
  <h2 id="{{ category[0] }}-ref">{{ category[0] | join: "/" }}</h2>
  <ul>
    {% assign pages_list = category[1] %}  
    {% include JB/pages_list %}
  </ul>
{% endfor %}
</div>

------------------

<!--
Posts by Date
--------------
<div>
<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
</div>
-->
