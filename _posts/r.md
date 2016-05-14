---
layout: post
title: "Visualizing MNIST"
description: "An Exploration of Dimensionality Reduction"
---


<script src="//d3js.org/d3.v3.min.js"></script>
<script src="/js/three.min.js"></script>
<script src="/js/TrackballControls.js"></script>
<link rel="stylesheet" href="https://ajax.googleapis.com/ajax/libs/jqueryui/1.11.2/themes/smoothness/jquery-ui.min.css">
<script src="/js/BasicVis.js" type="text/javascript"></script>
<script src="/js/MnistVis.js" type="text/javascript"></script>
<script src="/js/MNISTjs.js" type="text/javascript"></script>
<script src="/js/mnist_pca.js" type="text/javascript"></script>
<script src="/js/MNIST-SNE-good.js"></script>
<!-- <script src="./data/WordEmbed-Vecs.js" type="text/javascript"></script> -->
<!--  <script src="./data/WordEmbed-Meta.js" type="text/javascript"></script> -->

<script type="text/x-mathjax-config">
MathJax.Hub.Register.StartupHook("TeX Jax Ready",function () {
  var TEX = MathJax.InputJax.TeX,
      MML = MathJax.ElementJax.mml;
  var CheckDimen = function (dimen) {
    if (dimen === "" ||
        dimen.match(/^\s*([-+]?(\.\d+|\d+(\.\d*)?))\s*(pt|em|ex|mu|px|mm|cm|in|pc)\s*$/))
            return dimen.replace(/ /g,"");
    TEX.Error("Bad dimension for image: "+dimen);
  };
  TEX.Definitions.macros.img = "myImage";
  TEX.Parse.Augment({
    myImage: function (name) {
      var src = this.GetArgument(name),
          valign = CheckDimen(this.GetArgument(name)),
          width  = CheckDimen(this.GetArgument(name)),
          height = CheckDimen(this.GetArgument(name));
      var def = {src:src};
      if (valign) {def.valign = valign}
      if (width)  {def.width  = width}
      if (valign) {def.height = height}
      this.Push(this.mmlToken(MML.mglyph().With(def)));
    }
  });
});
</script>

<style>

  .hover_show {
    opacity: 0.0;
  }
  .hover_show:hover {
    opacity: 0.4;
  }

  .highlight {
    opacity: 0.8;
  }
  .highlight:hover {
    opacity: 1.0;
  }

  .figure {
    width: 100%;
    margin-top: 30px;
    margin-bottom: 20px;
  }

</style>

<script type="math/tex">\newcommand{mnist}[2][A]{\img{/img/mnist/#1-#2.png}{-0.15em}{1em}{1em}}</script>


<script type="text/javascript">
function mult_img_display (div, data) {
  var N = 7;
  div.style('width', '100%');
  var W = parseInt(div.style('width'));
  div.style('height', W/N);
  div.style('position', 'relative');
  for (var n = 0; n < 4; n++) {
    var div2 = div.append('div')
      .style('position', 'absolute')
      .style('left', (n+(N-4)/2)*W/N);
    //  .style('position', 'absolute')
    //  .left(n*W/5);
    var img_display = new BasicVis.ImgDisplay(div2)
      .shape([28,28])
      .imgs(data)
      .show(n);
    img_display.canvas
      .style('border', '2px solid #000000')
      .style('width', W/N*0.85);
  }
}

var mnist_tooltip = new BasicVis.ImgTooltip();
mnist_tooltip.img_display.shape([28,28]);
mnist_tooltip.img_display.imgs(mnist_xs);
setTimeout(function() {mnist_tooltip.hide();}, 3000);
</script>



At some fundamental level, no one understands machine learning.

It isn’t a matter of things being too complicated.
Almost everything we do is fundamentally very simple.
Unfortunately, an innate human handicap interferes with us understanding these simple things.

Humans evolved to reason fluidly about two and three dimensions. With some effort, we may think in four dimensions.
Machine learning often demands we work with thousands  of dimensions -- or tens of thousands, or millions!
Even very simple things become hard to understand when you do them in very high numbers of dimensions.

Reasoning directly about these high dimensional spaces is just short of hopeless.

As is often the case when humans can’t directly do something, we’ve built tools to help us.
There is an entire, well-developed field, called dimensionality reduction, which explores techniques for translating high-dimensional data into lower dimensional data.
Much work has also been done on the closely related subject of visualizing high dimensional data.

These techniques are the basic building blocks we will need if we wish to visualize machine learning, and deep learning specifically.
My hope is that, through visualization and observing more directly what is actually happening, we can understand neural networks in a much deeper and more direct way.

And so, the first thing on our agenda is to familiarize ourselves with dimensionality reduction.
To do that, we're going to need a dataset to test these techniques on.


MNIST
======

MNIST is a simple computer vision dataset.
It consists of 28x28 pixel images of handwritten digits, such as:

<br>

<div id="mnist_image_examples"> </div>
<script type="text/javascript">
(function () {
  var div = d3.select("#mnist_image_examples");
  mult_img_display(div, mnist_xs)
})()
</script>

<br>

Every MNIST data point, every image, can be thought of as an array of numbers describing how dark each pixel is.
For example, we might think of $$\mnist[1]{1}$$ as something like:

$$
\bbox[5px,border:2px solid black]{\img{/img/mnist/1-1.png}{-5.6em}{12em}{12em}}
~~ \simeq
\left[ {\scriptscriptstyle \begin{array}{cccccccccccccccccccccccccccc}
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & \bbox[#A0A0A0,1pt]{.6} & \bbox[#909090,1pt]{.8} & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & \bbox[#959595,1pt]{.7} & \bbox[#808080,1pt]{1} & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & \bbox[#959595,1pt]{.7} & \bbox[#808080,1pt]{1} & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & \bbox[#A5A5A5,1pt]{.5} & \bbox[#808080,1pt]{1} & \bbox[#B0B0B0,1pt]{.4} & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & \bbox[#808080,1pt]{1} & \bbox[#B0B0B0,1pt]{.4} & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & \bbox[#808080,1pt]{1} & \bbox[#B0B0B0,1pt]{.4} & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & \bbox[#808080,1pt]{1} & \bbox[#959595,1pt]{.7} & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & \bbox[#808080,1pt]{1} & \bbox[#808080,1pt]{1} & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & \bbox[#858585,1pt]{.9} & \bbox[#808080,1pt]{1} & \bbox[#E0E0E0,1pt]{.1} & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & \bbox[#C0C0C0,1pt]{.3} & \bbox[#808080,1pt]{1} & \bbox[#E0E0E0,1pt]{.1} & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 & 0 \\
\end{array} } \right]
$$


Since each image has 28 by 28 pixels, we get a 28x28 array.
We can flatten each array into a $28*28 = 784$ dimensional vector.
Each component of the vector is a value between zero and one describing the intensity of the pixel.
Thus, we generally think of MNIST as being a collection of 784-dimensional vectors.

Not all vectors in this 784-dimensional space are MNIST digits.
Typical points in this space are very different!
To get a sense of what a typical point looks like, we can randomly pick a few points and examine them.
In a random point -- a random 28x28 image -- each pixel is randomly black, white or some shade of gray.
The result is that random points look like noise.

<br>

<div id="random_image_examples"> </div>
<script type="text/javascript">
(function () {
  var div = d3.select("#random_image_examples");
  var data = new Float32Array(784*10);
  for (var n = 0; n < data.length; n++) {
    data[n] = Math.random();
  }
  mult_img_display(div, data)
})()
</script>
<br>

Images like MNIST digits are very rare.
While the MNIST data points are *embedded* in 784-dimensional space, they live in a very small subspace.
With some slightly harder arguments, we can see that they occupy a lower dimensional subspace.

People have lots of theories about what sort of lower dimensional structure MNIST, and similar data, have.
One popular theory among machine learning researchers is the *manifold hypothesis*: MNIST is a low dimensional manifold, sweeping and curving through its high-dimensional embedding space.
Another hypothesis, more associated with topological data analysis, is that data like MNIST consists of blobs with tentacle-like protrusions sticking out into the surrounding space.

But no one really knows, so lets explore!


t-Distributed Stochastic Neighbor Embedding
-------------------------------------------

The final technique I wish to introduce is the [t-Distributed Stochastic Neighbor Embedding] (t-SNE).
This technique is extremely popular in the deep learning community.
Unfortunately, t-SNE's cost function involves some non-trivial mathematical machinery and requires some significant effort to understand.

But, roughly, what t-SNE tries to optimize for is preserving the *topology* of the data.
For every point, it constructs a notion of which other points are it's 'neighbors,' trying to make all points have the same number of neighbors.
Then it tries to embed them so that those points all have the same number of neighbors.

In some ways, t-SNE is a lot like the graph based visualization.
But instead of just having points be neighbors (if there's an edge) or not neighbors (if there isn't an edge), t-SNE has a continuous spectrum of having points be neighbors to different extents.

t-SNE is often very successful at revealing clusters and subclusters in data.

<br>

<div id="tsne_mnist" class="figure" style="width: 60%; margin: 0 auto; margin-bottom: 8px;"> </div>
<div class="caption">**Visualizing MNIST with t-SNE**</div>
<script type="text/javascript">
  setTimeout(function(){
    var test = new GraphLayout("#tsne_mnist");
    test.scatter.size(3.1);
    var test_wrap = new AnimationWrapper(test);
    test_wrap.button.on("mousemove", function() { mnist_tooltip.hide(); d3.event.stopPropagation();});

    setTimeout(function() {
      test.scatter.xrange([-35,35]);
      test.scatter.yrange([-35,35]);
      mnist_tooltip.bind(test.scatter.points);
      mnist_tooltip.bind_move(test.scatter.s);
      test_wrap.layout();
    }, 50);

    var W = new Worker("/js/CostLayout-worker.js");

    test_wrap.bindToWorker(W);

    W.postMessage({cmd: "init", xs: mnist_xs, N: test.sne.length/2, D: 784, cost: "tSNE", perplexity:40});
    test_wrap.run   = function(){ W.postMessage({cmd: "run", steps: 1600, skip: 2, Kstep: 18.0, Kmu: 0.85})};

  }, 500);
</script>

t-SNE does an impressive job finding clusters and subclusters in the data, but is prone to getting stuck in local minima.
For example, in the following image we can see two clusters of zeros (red) that fail to come together because a cluster of sixes (blue) get stuck between them.

<br>

<div style = "width:35%; position: relative; margin: 0 auto;">
<img src="/img/tsne-localmin-1.png" style="width: 100%">
</div>

<br>

A number of tricks can help us avoid these bad local minima.
Firstly, using more data helps a lot.
Because these visualizations are embeded in a blog post, they only use 1,000 points.
Using the full 50,000 MNIST points works a lot better.
In addition, it is recommended that one use [simulated annealing] and carefully select a number of hyperparamters.

Well done t-SNE plots reveal many interesting features of MNIST.

<br>

<div id="tsne_mnist_nice" class="figure" style="width: 60%; margin: 0 auto; margin-bottom: 8px;"> </div>
<div class="caption">**A t-SNE plot of MNIST**</div>
<script type="text/javascript">
  setTimeout(function(){
    var sne = mnist_sne;
    var scatter = new BasicVis.ScatterPlot("#tsne_mnist_nice");
    scatter
      .N(mnist_sne.length/2)
      .xrange.fit(mnist_sne)
      .yrange.fit(mnist_sne)
      .x(function(i) {return mnist_sne[2*i  ];})
      .y(function(i) {return mnist_sne[2*i+1];})
      .size(3.1)
      .color(function(i){return d3.hsl(360*mnist_ys[i]/10.0,0.5,0.5);})
      //.enable_zoom()
      .bindToWindowResize();
    //scatter.s.style("border", "1px black solid");
    setTimeout(function() {
      scatter.xrange.fit(mnist_sne)
             .yrange.fit(mnist_sne);
      scatter.layout();
      mnist_tooltip.bind(scatter.points);
      mnist_tooltip.bind_move(scatter.s);
    }, 50);
  }, 500);
</script>

An even nicer plot can be found on the page labeled 2590, in the original t-SNE paper, [Maaten & Hinton (2008)].

It's not just the classes that t-SNE finds. Let's look more closely at the ones.

<br>

<div id="tsne_mnist_nice_ones" class="figure" style="width: 60%; margin: 0 auto; margin-bottom: 8px;"> </div>
<div class="caption">**A t-SNE plot of MNIST ones**</div>
<script type="text/javascript">
  setTimeout(function(){
    var sne = mnist_sne;
    var scatter = new BasicVis.ScatterPlot("#tsne_mnist_nice_ones");
    scatter
      .N(mnist_sne.length/2)
      .xrange.fit(mnist_sne)
      .yrange.fit(mnist_sne)
      .x(function(i) {return mnist_sne[2*i  ];})
      .y(function(i) {return mnist_sne[2*i+1];})
      .size(3.1)
      .color(function(i){
        if (mnist_ys[i] == 1) {
         return d3.hsl(360*mnist_ys[i]/10.0,0.5,0.5);
        } else {
         return d3.hsl(360*mnist_ys[i]/10.0,0.3,0.85);
        }
      })
      //.enable_zoom()
      .bindToWindowResize();
    //scatter.s.style("border", "1px black solid");
    setTimeout(function() {
      scatter.xrange.fit(mnist_sne)
             .yrange.fit(mnist_sne);
      scatter.layout();
      mnist_tooltip.bind(scatter.points, function(i) {return mnist_ys[i] == 1;});
      mnist_tooltip.bind_move(scatter.s);
    }, 50);

  }, 500);
</script>

The ones cluster is stretched horizontally. As we look at digits from left to right, we see a consistent pattern.

$$\mnist[1]{7} \to \mnist[1]{4} \to \mnist[1]{8} \to \mnist[1]{6} \to \mnist[1]{2} \to \mnist[1]{1}$$

They move from forward leaning ones, like $\mnist[1]{4}$, into straighter like $\mnist[1]{6}$, and finally to slightly backwards leaning ones, like $\mnist[1]{1}$.
It seems that in MNIST, the primary factor of variation in the ones is tilting.
This is likely because MNIST normalizes digits in a number of ways, centering and scaling them.
After that, the easiest way to be "far apart" is to rotate and not overlap very much.

Similar structure can be observed in other classes, if you look at the [t-SNE plot](#tsne_mnist_nice) again.


[t-Distributed Stochastic Neighbor Embedding]: http://jmlr.csail.mit.edu/papers/volume9/vandermaaten08a/vandermaaten08a.pdf
[simulated annealing]: http://en.wikipedia.org/wiki/Simulated_annealing
[Maaten & Hinton (2008)]: http://jmlr.org/papers/volume9/vandermaaten08a/vandermaaten08a.pdf


Visualization in Three Dimensions
=================================

Watching these visualizations, there's sometimes this sense that they're begging for another dimension.
For example, watching the graph visualization optimize, one can see clusters slide over top of each other.

Really, we're trying to compress this extremely high-dimensional structure into two dimensions.
It seems natural to think that there would be very big wins from adding an additional dimension.
If nothing else, at least in three dimensions a line connecting two clusters doesn't divide the plane, precluding other connections between clusters.

In the following visualization, we construct a nearest neighbor graph of MNIST, as before, and optimize the same cost function.
The only difference is that there are now three dimensions to lay it out in.

<br>

<div class="figure" style="width: 90%; margin: 0 auto; border: 1px solid black; padding: 5px; margin-bottom: 8px;">
<div id="graph_mnist_3D" style="width: 100%"></div>
</div>
<div class="caption">**Visualizing MNIST as a Graph in 3D** <br> (click and drag to rotate)</div>
<script type="text/javascript">
  setTimeout(function(){
    var test = new BasicVis.GraphPlot3("#graph_mnist_3D");
    test.controls.reset();
    test.layout();
    test._animate();
    test.point_classes = mnist_ys;

    var test_wrap = new AnimationWrapper(test);
    test_wrap.button.on("mousemove", function() { mnist_tooltip.hide(); d3.event.stopPropagation();});

    var tooltip = null;
    setTimeout(function() {
      test_wrap.layout();
      test.point_event_funcs["mouseover"] = function(i) {
        mnist_tooltip.display(i);
        mnist_tooltip.unhide();
      };
      test.point_event_funcs["mouseout"] = function(i) {
        mnist_tooltip.hide();
      };
      mnist_tooltip.bind_move(test.s);
      
    }, 50);

    var W = new Worker("/js/CostLayout-worker-3D.js");
    W.onmessage = function(e) {
      data = e.data;
      switch (data.msg) {
        case "edges":
          test.make_points(1000);
          test.make_edges(data.edges);
          break;
        case "update":
          test.position(data.embed);
          break;
        case "done":
          test_wrap.on_done();
          break;
      }
    };

    W.postMessage({cmd: "init", xs: mnist_xs, N: 1000, D: 784, cost: "graph"});

    test_wrap.run   = function(){ W.postMessage({cmd: "run", steps: 300, skip: 1,  Kstep: 8.0, Kmu: 0.8})};
    test_wrap.reset = function(){ W.postMessage({cmd: "reset"})};

  }, 500);
</script>


The three dimensional version, unsurprisingly, works much better.
The clusters are quite separated and, while entangled, no longer overlap.

In this visualization, we can begin to see why it is easy to achieve around 95% accuracy classifying MNIST digits, but quickly becomes harder after that.
You can make a lot of ground classifying digits by chopping off the colored protrusions above, the clusters of each class sticking out.
(This is more or less what a linear Support Vector Machine does.[^SVM_hedge])
But there's some much harder entangled sections, especially in the middle, that are difficult to classify.

[^SVM_hedge]: This isn't quite true. A linear SVM operates on the original space. This is a non-linear transformation of the original space. That said, this strongly suggests something similar in the original space, and so we'd expect something similar to be true. &nbsp;

Of course, we could do any of the above techniques in 3D! Even something as simple as MDS is able to display quite a bit in 3D.

<br>

<div class="figure" style="width: 90%; margin: 0 auto; border: 1px solid black; padding: 5px; margin-bottom: 8px;">
<div id="MDS_mnist_3D" style="width: 100%">
</div>
</div>
<div class="caption">**Visualizing MNIST with MDS in 3D** <br> (click and drag to rotate)</div>
<script type="text/javascript">
  setTimeout(function(){
    var test = new BasicVis.GraphPlot3("#MDS_mnist_3D", 200);
    test.controls.reset();
    test.layout();
    test._animate();
    test.point_classes = mnist_ys;

    var test_wrap = new AnimationWrapper(test);
    test_wrap.button.on("mousemove", function() { mnist_tooltip.hide(); d3.event.stopPropagation();});

    var tooltip = null;
    setTimeout(function() {
      test_wrap.layout();
      test.point_event_funcs["mouseover"] = function(i) {
        mnist_tooltip.display(i);
        mnist_tooltip.unhide();
      };
      test.point_event_funcs["mouseout"] = function(i) {
        mnist_tooltip.hide();
      };
      mnist_tooltip.bind_move(test.s);
      
    }, 50);

    var W = new Worker("/js/CostLayout-worker-3D.js");
    W.onmessage = function(e) {
      data = e.data;
      switch (data.msg) {
        case "edges":
          test.make_points(1000);
          test.make_edges(data.edges);
          break;
        case "update":
          test.position(data.embed);
          break;
        case "done":
          test_wrap.on_done();
          break;
      }
    };

    W.postMessage({cmd: "init", xs: mnist_xs, N: 1000, D: 784, cost: "MDS"});

    test_wrap.run   = function(){ W.postMessage({cmd: "run", steps: 300, skip: 1,  Kstep: 6.0, Kmu: 0.8})};
    test_wrap.reset = function(){ W.postMessage({cmd: "reset"})};

  }, 500);
</script>

In three dimensions, MDS does a much better job separating the classes than it did with two dimensions.

And, of course, we can do t-SNE in three dimensions.

<br>

<div class="figure" style="width: 90%; margin: 0 auto; border: 1px solid black; padding: 5px; margin-bottom: 8px;">
<div id="tsne_mnist_3D" style="width: 100%">
</div>
</div>
<div class="caption">**Visualizing MNIST with t-SNE in 3D** <br> (click and drag to rotate)</div>
<script type="text/javascript">
  setTimeout(function(){
    var test = new BasicVis.GraphPlot3("#tsne_mnist_3D", 400);
    test.controls.reset();
    test.layout();
    test._animate();
    test.point_classes = mnist_ys;

    var test_wrap = new AnimationWrapper(test);
    test_wrap.button.on("mousemove", function() { mnist_tooltip.hide(); d3.event.stopPropagation();});

    var tooltip = null;
    setTimeout(function() {
      test_wrap.layout();
      test.point_event_funcs["mouseover"] = function(i) {
        mnist_tooltip.display(i);
        mnist_tooltip.unhide();
      };
      test.point_event_funcs["mouseout"] = function(i) {
        mnist_tooltip.hide();
      };
      mnist_tooltip.bind_move(test.s);
      
    }, 50);

    var W = new Worker("/js/CostLayout-worker-3D.js");
    W.onmessage = function(e) {
      data = e.data;
      switch (data.msg) {
        case "edges":
          test.make_points(1000);
          test.make_edges(data.edges);
          break;
        case "update":
          test.position(data.embed);
          break;
        case "done":
          test_wrap.on_done();
          break;
      }
    };

    W.postMessage({cmd: "init", xs: mnist_xs, N: 1000, D: 784, cost: "tSNE"});

    test_wrap.run   = function(){ W.postMessage({cmd: "run", steps: 500, skip: 1,  Kstep: 10.0, Kmu: 0.85})};
    test_wrap.reset = function(){ W.postMessage({cmd: "reset"})};

  }, 500);
</script>

Because t-SNE puts so much space between clusters, it benefits a lot less from the transition to three dimensions.
It's still quite nice, though, and becomes much more so with more points.

If you want to visualize high dimensional data, there are, indeed, significant gains to doing it in three dimensions over two.

Conclusion
============

Dimensionality reduction is a well developed area, and we're only scratching the surface here.
There are hundreds of techniques and variants that are unmentioned here.
I'd encourage you to explore!

It's easy to slip into a mind set of thinking one of these techniques is better than the others.
But I think they're really complementary.
There's no way to map high-dimensional data into low dimensions and preserve all the structure.
So, an approach must make trade offs, sacrificing one property to preserve another.
PCA tries to preserve linear structure, MDS tries to preserve global geometry, and t-SNE tries to preserve topology (neighborhood structure).

These techniques give us a way to gain traction on understanding high-dimensional data.
While directly trying to understand high-dimensional data with the human mind is all but hopeless, with these tools we can begin to make progress.

In the next post, we will explore applying these techniques to some different kinds of data -- in particular, to visualizing representations of text.
Then, equipped with these techniques, we will shift our focus to understanding neural networks themselves, visualizing how they transform high-dimensional data and building techniques to visualize the space of neural networks.
If you're interested, you can subscribe to my [rss feed](../../rss.xml) so that you'll see these posts when they are published.

*(I would be delighted to hear your comments and thoughts: you can comment inline or at the end. For typos, technical errors, or clarifications you would like to see added, you are encouraged to make a pull request on [github](https://github.com/colah/Visualizing-Deep-Learning/))*

Acknowledgements
=================

I'm grateful for the hospitality of Google's deep learning research group, which had me as an intern while I wrote this post and did the work it is based on.
I'm especially grateful to my internship host, Jeff Dean.

I was greatly helped by the comments, advice, and encouragement of many Googlers, both in the deep learning group and outside of it. These include: 
Greg Corrado, Jon Shlens, Matthieu Devin,
Andrew Dai, Quoc Le,
Anelia Angelova,
Oriol Vinyals, Ilya Sutskever, Ian Goodfellow,
Jutta Degener, and Anna Goldie.

I was strongly influenced by the thoughts, comments and notes of Michael Nielsen, especially his notes on Bret Victor's work.
Michael's thoughts persuaded me that I should think seriously about interactive visualizations for understanding deep learning.

I was also helped by the support of a number of non-Googler friends, including Yoshua Bengio, Dario Amodei, Eliana Lorch, Taren Stinebrickner-Kauffman, and Laura Ball.

This blog post was made possible by a number of wonderful Javascript libraries, including [D3.js](http://d3js.org/), [MathJax](http://www.mathjax.org/), [jQuery](http://jquery.com/), and [three.js](http://threejs.org/). A big thank you to everyone who contributed to these libraries.



