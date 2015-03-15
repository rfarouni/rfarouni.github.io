---
layout: page
title: Site Info
group: navigation
---

------------------

List of All Pages
=======================
<div>
<ul>
{% assign pages_list = site.pages %}
{% include JB/pages_list %}
</ul>
</div>

------------------




Site Features & Credits
=======================

* Colors and syntax highlighting with [Solarized](http://ethanschoonover.com/solarized)
* equations rendered in [Mathjax](http://www.mathjax.org/)
* Reproducible code execution with [knitr](http://yihui.name/knitr/)
* CSS based on [twitter bootstrap](http://getboostrap.com)
* Scalable CSS icons from [FontAwesome](http://fortawesome.github.com/Font-Awesome)
* Static site generation with [Jekyll](https://github.com/mojombo/jekyll)
* Markdown parsing with [pandoc](http://johnmacfarlane.net/pandoc/)
* Site and source code hosting on [Github](https://github.com/)
* Uptime monitoring from my.pingdom.com; see [status report](http://stats.pingdom.com/fy1sae94ydyi/616612)

------------------

Notebook Archiving & Data Management
====================================

The lab notebook is written and maintained in plain text (UTF-8) using
markdown. All files are kept in a version managed repository system using
[git](http://git-scm.com/), which provides unique SHA hashes to protect
against corruption. Synchronized backups of the git repository are
maintained on both local and remote servers (RAID 6) to protect against
hardware failures, as well as on the public international software
repository, GitHub [github.com/rfarouni](https://github.com/cboettig).
Version history preserves a time-line of changes and protects against
user error file loss.  Archival copies of notebook entries shall be published
annually to [figshare](http://figshare.com) where they will be assigned
DOIs and preserved by the [CLOCKSS](http://www.clockss.org/clockss/Home)
geopolitically distributed 12 node global archive.

-----------------------------------------------------

Building from source
====================

_NOTE:_ If you are new
to Jekyll, consider starting with a basic Jekyll template such as
[jekyll-bootstrap](http://jekyllbootstrap.com/) which will be considerably
easier to adapt than working from this repository directly.




-----------------------------------------------------------------------------------------------------------

Copyrights & License
-------------------- 


<div>
<footer>
      <div class="container">
        <p>&copy; {{ site.time | date: '%Y' }} {{ site.author.name }}
          with help from <a href="http://jekyllbootstrap.com" target="_blank" title="The Definitive Jekyll Blogging Framework">Jekyll Bootstrap</a>, 
          <a href="http://github.com/dhulihan/hooligan" target="_blank">The Hooligan Theme</a>, and      <a property="http://creativecommons.org/ns#attributionURL" href="http://carlboettiger.info">http://carlboettiger.info</a>
        </p>
      </div>
</footer>
</div>


