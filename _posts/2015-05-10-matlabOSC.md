---
layout: post
title: "Matlab on the OSC"
category: code
tags: [Matlab]
description: "Submitting Batch Jobs from a Matlab Client to the Ohio Supercomputer Oakely Cluster" 
---
{% include JB/setup %}

## The Oakley Cluster

Oakley has 685 standard nodes with 12 cores and 48 GB of shared memory on each node. So basically each node consists of 
an 2.66 GHz Intel Xeon X5650 chip with 12 threads (i.e. logical cores). The Xeon X5650 was released early in 2010 but its performance is comparable to a 3.4 GHz Core i7-4770, a recently released Desktop processor with 8 logical cores. On the Ohio Supercomputer Center, a single user can use up to 2040 cores (170 nodes) at any one time. That is rougly the computing power of 170 desktops but with much more memory.


## Types of Parallelism

To illustrate the types of parallelism, we will work with this function that calculates the area of a unit circle.

### Example Function

~~~ m

function [results] = montecarlo(n)

% This function outputs a Monte Carlo approximation of pi by first calculating the
% area of circular sector enclosed in the first quadrant, then multiplying it by 4
% n = the number of draws
% z(j) is a randomly sampled complex number on [0,1]x[0,1]

tic;
for j=1:n
    z(j) = rand(1, 1) + i*rand(1, 1);
end
k = sum(abs(z) < 1);
results.area(1)= 4*k/n;
results.time(1)=toc;
clear k; clear z;

end
~~~


### Implicit Parallelism (Multithreading)

Parallism is initiated without coding modifications. A vector operation is  necessary to  trigger multithreading. For example, a function evaluation using a for loop might take 120 seconds, whereas a vectorized implemention on one core might take 6 second and on 8 threads (logical cores), the time can drop to 1 second or less, depending on the version of the Basic Linear Algebra Subprograms (BLAS) implementation installed on the system.


~~~ matlab

function [results] = montecarlo(n)

% inefficient for-loop

tic;
for j=1:n
    z(j) = rand(1, 1) + i*rand(1, 1);
end
k = sum(abs(z) < 1);
results.area(1)= 4*k/n;
results.time(1)=toc;
clear k; clear z;

% vectorized version
tic;
z = rand(n, 1) + i*rand(n, 1);
k=sum(abs(z) < 1);
results.area(2)= 4*k/n
results.time(2)=toc
clear k; clear z;

end
~~~


### Job Submission Script

~~~ matlab

myCluster = parcluster('local');

job= createJob(myCluster,'AttachedFiles',...
    {'/Documents/TempProjects/tests/montecarlo.m'});

ncores = 4;
for i = 1:ncores
    task = createTask(job, @montecarlo, 1,{10e5});
end

submit(job);

wait(job)
%get(job, 'State')

results = fetchOutputs(job);
for i = 1:ncores
    [results{i}.area; results{i}.time]
end
delete(job)

~~~


### Explicit Parallelism

For what follows we will deploy on Matlab worker on a single logical core for efficieny reasons. So worker will also refer to a core. Let's say that the job we have invovles repeating the same operation *n* times. 

#### work load distribution is determined implicitly
The *parfor* function distributes to the workers the *n* operations into *w* chunks, so that each work exectues a chunk of size *n/w*. once the all the workers finish execting, the *parfor* function performs a global reduction operation, such as addition, across all the workers. However, the operation must satisify the associative rule. If this not possible, we can use the distributed range  *drange* and then use communicating functions such as *gather* or *gplus* to perform reduction operations.

#### work load distribution is determined explicitly

spmd, it is up to the programmer to define a work load distribution scheme, such as prange


1. task-parallel (embarrassingly parallel) job

Multiple tasks running independently on multiple workers


2. data-parallel job

createCommunicatingJob

A single task running concurrently on multiple workers that may communicate with each other

Task parallel program is more efficient than a data-parallel program


Four types of submissions

1. One communicating job on 1 node
2. One independent job on 1 node with one task for each core
3. One independent job on 2 node with one task on each core
4. Two communicating jobs run independently, one on each node




    




