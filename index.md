---
layout: page
title: About me
tagline: 
---
{% include JB/setup %}

## Welcome

<img src="assets/img/rick.jpg" style="float:right; margin: 10px 10px;"/>
I am a third-year PhD student in quantitative psychology at the Ohio State University. 

This blog contains sample posts which help stage pages and blog data.

 I enjoy questions of ["Pasteur's Quadrant"](http://en.wikipedia.org/wiki/Pasteur%27s_quadrant), basic



### Skills

* **Analytic methods**: Dynamical systems, 
* **Numerical methods**: High-performance computing,
* **Data Science methods**:  (XML, regexp, semantic/linked data). Software development practices, authoring R packages, data management.

I also enjoy exposure to



<!--
### Projects
[nonparametric Bayesian](/projects/nonparametric-bayes.html)
approaches to management, quantifying the value of information

-->


Complete usage and documentation available at: [Current Reading List](http://www.mendeley.com/groups/6795211/nonparametric-bayes/)

## Update Author Attributes

In `_config.yml` remember to specify your own data:
    
    title : My Blog
    
    author : 
      name : Rick Farouni
      email : rfarouni@gmail.com
      github : username
      twitter : username
      facebook : username

The theme should reference these variables whenever needed.
    
## Sample Posts

This blog contains sample posts which help stage pages and blog data.
When you don't need the samples anymore just delete the `_posts/core-samples` folder.

    $ rm -rf _posts/core-samples

Here's a sample "posts list".

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>

## Links




