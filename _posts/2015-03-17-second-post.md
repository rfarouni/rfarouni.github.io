---
layout: post
title: "Gardyloo"
description: "Nullam tempor lorem in risus ullamcorper aliquam. Nunc pulvinar tortor sed auctor suscipit. Morbi ultrices ipsum orci. Donec eget urna accumsan, mattis metus sollicitudin, sodales augue. Praesent euismod metus quis ligula maximus aliquam. Morbi ac vehicula lectus. Nulla quis nisi at ipsum dignissim scelerisque."
tags: [how-to]
category: Latex
tags: [equation]
---
{% include JB/setup %}


An equation

$$
\begin{align*}
  & \phi(x,y) = \phi \left(\sum_{i=1}^n x_ie_i, \sum_{j=1}^n y_je_j \right)
  = \sum_{i=1}^n \sum_{j=1}^n x_i y_j \phi(e_i, e_j) = \\
  & (x_1, \ldots, x_n) \left( \begin{array}{ccc}
      \phi(e_1, e_1) & \cdots & \phi(e_1, e_n) \\
      \vdots & \ddots & \vdots \\
      \phi(e_n, e_1) & \cdots & \phi(e_n, e_n)
    \end{array} \right)
  \left( \begin{array}{c}
      y_1 \\
      \vdots \\
      y_n
    \end{array} \right)
\end{align*}
$$

