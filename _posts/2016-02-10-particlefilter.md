---
title: " Particle Filter "
layout: post
tags: [Julia]
description: "Julia Code for a Particle Filter implementation of the Dirichlet Mixture Model" 
---
{% include JB/setup %}

~~~ matlab

function update_posterior(n,ȳ =0,ỹỹᵀ=0)
 # Gelman's Bayesian Data Analysis 3rd Edition Page 73
 # the fucntion first updates the parameters of the posterior distribution
 # (μ,Σ) ∼ Normal-InverseWishart(μₙ,κₙ,Λₙ,νₙ)
 # n is the number of observations in the cluster
 # ȳ is the mean of these observations,
 # (ỹỹᵀ - n*ȳ*ȳ') is sum of squares of these observations.
  μₙ = κ₀/(κ₀+n)*μ₀ + n/(κ₀+n)*ȳ
  κₙ = κ₀+n
  νₙ = ν₀+n
  Λₙ = Λ₀ +κ₀*n/(κ₀+n)*(ȳ-μ₀)*(ȳ-μ₀)' + (ỹỹᵀ - n*ȳ*ȳ')
  #the parameters of the posterior predictive distribution of
  # new observation ỹ ∼tᵥ(μ,Σ)
  μ=μₙ
  Σ = Λₙ*(κₙ+1)/(κₙ*(νₙ-D+1))
  ν =νₙ-D+1
  return μ, Σ, ν
end

function log_posteriorpredictive(y,μ,Σ,ν,logdet_Σ=0, inv_Σ=0)
  # evaluate the the posterior predictive distribution of
  # new observation ỹ ∼tᵥ(μ,Σ)
  # Compute logdet_Σ and inv_Σ if they have not been computed before
  if logdet_Σ ==0
      logdet_Σ = logdet(Σ)
      inv_Σ = inv(Σ)
  end
  logposterior = log_Γ[ν+D]-(log_Γ[ν] + D*p_log[ν]/2 + D*log_π/2)-
        logdet_Σ/2-((ν+D)/2)*log(1+(1/(ν))*(y-μ)'*inv_Σ*(y-μ))
  return logposterior[1]
end


function resample_stratified(z,w,N)
   #Algorithm 2:Carpenter, J., Clifford, P., & Fearnhead, P. (1999).
   #Improved particle filter for nonlinear problems
    #no putative particle is resampled more than once.
    (D, M) = size(z)
    z_resampled = zeros(Int32,D,N)
    w_resampled = zeros(N)
    selected = zeros(M)
    #permute
    permuted_indx = randperm(M)
    w = w[permuted_indx]
    z = z[:,permuted_indx]
    cdf = cumsum(w)
    cdf[end]=1
    N!=1 ? p =linspace(rand(Uniform())/N,1,N):p =1
    j=1
    for i=1:N
            while j<M && cdf[j]<p[i]
            j=j+1
        end
            selected[j] = selected[j]+1
    end
    k=1
    for i=1:M
            if(selected[i]>0)
                for j=1:selected[i]
                    z_resampled[:,k] = z[:,i]
                    w_resampled[k]= w[i]
                k=k+1
            end
        end
    end
    w_resampled = w_resampled./sum(w_resampled)
    return z_resampled#returns N samples
end

function compute_putative_weights(y,t,alpha=0.4)
    # Given N particles for the first t-1 observations,
    # there are M(≥2N ) possible particles for the first t observations.
    # particle n generates  K₊(n)+1 distinct putative particles
    # iα and iω are the starting and ending indexes of the K₊(n)+1 put prtcls
    # For any given particle z 1:n , with k i distinct clusters,
    # there are k i + 1 possible allocations for the (n + 1)st ob-servation
    M = sum(K₊[:,t-1])+N # M =number of putative particles to generate.
    Wᴾ = ones(M)
    iα= 1 #starting index
    iω= K₊[1,t-1]+1 #ending index
    Zᴾ = zeros(Int32,2,M)
    for n = 1:N
        Zᴾ[1,iα:iω] = n
        Zᴾ[2,iα:iω]= 1:iω-iα+1  #num_options i.e. K₊(1)+1
        #calculate the probability of each new putative particle
        m_k = cluster_counts[1:K₊[n,t-1],n,t-1]
        # multinomial conditional prior distribution
        prior = [m_k; alpha]./(alpha + t -1)
        # update the weights so that the particles
        # (and weights) now represent the predictive distribution
        Wᴾ[iα:iω] = W[n,t-1]*prior
        posterior_predictive_p = zeros(size(prior))
        for pnp_id = 1: (iω-iα)
            (μ, Σ, ν)=update_posterior(cluster_counts[pnp_id,n,t-1],
                                        Ȳ[:,pnp_id,n,t-1],SS[:,:,pnp_id,n,t-1])
            posterior_predictive_p[pnp_id] = exp(
                      log_posteriorpredictive(y,μ,Σ,ν,logdetΣ[pnp_id,n,t-1],
                                        invΣ[:,:,pnp_id,n,t-1]))
        end
        (μ, Σ, ν)=update_posterior(0,y)
        posterior_predictive_p[end] = exp(log_posteriorpredictive(y,μ,Σ,ν))
        Wᴾ[iα:iω] = Wᴾ[iα:iω].*posterior_predictive_p
        iα= iω+1
        if n!=N
            iω= iα+K₊[n+1,t-1]
        end
    end
    Wᴾ = Wᴾ ./ sum(Wᴾ)
  return Wᴾ, Zᴾ, M
end

function find_optimal_c(Q,N)
    Q=sort(Q,rev=true)
    c = 0
    k = 0
    M = length(Q)
    k_old = -Inf
    while k_old !=k
        k_old = k
            c = (N-k)/sum(Q[k+1:end])
            k = k+ sum(Q[k+1:M]*c .> 1)
    end
    return 1/c
end
####################################################################
using Distributions,MLBase,Gadfly
dataset=readdlm("data.txt")'
Y=dataset[1:3,:]
const T = size(Y,2) # number of samples or time points
const D = size(Y,1) # dimension of  data
const N = 6000 # numuber of particles
#hyperparameters
const κ₀ = .05
const ν₀= D+2
const Λ₀ =0.04*eye(D)
const μ₀ = [0.  for i=1:D] #μ₀ = repmat([0],2,1)
# precomputed values
const max_class_index = T
const max_class_number = 20
const log_Γ = lgamma((1:max_class_index)/2)
const log_π = log(pi)
const p_log = log(1:max_class_index)
const class_type = Int16
#parameters θ={μₖ,Σₖ}∞
Ȳ = zeros(D,max_class_number,N,T) # means
SS = zeros(D,D,max_class_number,N,T) # sum of squares
cluster_counts = zeros(Int32,max_class_number,N,T) #
logdetΣ = zeros(max_class_number,N,T)
invΣ = zeros(D,D,max_class_number,N,T)
K₊ = ones(class_type,N,T) # number of distinct clusters
Z = zeros(class_type,N,T,2) # cluster labels (i.e. particles) where zₜ∈ {1,..,k}
W = zeros(N,T) #weights

# intialize
y = Y[:,1]
yyᵀ = y * y'
(μ, Σ, ν)=update_posterior(1,y,yyᵀ)
for i=1:N
    Ȳ[:,1,i,1] = y
    SS[:,:,1,i,1] = yyᵀ
    cluster_counts[1,i,1] = 1
    logdetΣ[1,i,1] = logdet(Σ)
    invΣ[:,:,1,i,1] =inv(Σ)
end
Z[:,1,1] = 1
W[:,1]= 1/N
cp =1  # cp is the set of current particles

for t = 2:T
    println("Observation Number = ",t)
    y = Y[:,t]
    yyᵀ = y*y'
    (Wᴾ,Zᴾ, M)=compute_putative_weights(y,t) # M= \Σ^N(k_i+1).
    # The M putative weights and particles give a discrete
    # approxmation of P(z_(1:t)|y_(1:t))
    #plot_particles(Wᴾ,vec(slicedim(Zᴾ,1,2)), M,t)
    #calculate the weights of all possible putative Z at the next time-step.
    survival_threshold= find_optimal_c(Wᴾ,N) # compute survival_threshold weight
    pass_inds = Wᴾ.> survival_threshold #indices of surviving particles
    num_pass = sum(pass_inds) # number of surviving particles
    if cp == 1
        np = 2
    else
        np = 1
    end
    Z[1:num_pass,1:t-1,np] = Z[vec(Zᴾ[1,pass_inds]),1:t-1,cp]
    Z[1:num_pass,t,np] = Zᴾ[2,pass_inds]
    #weight of the propagated particles is kept unchanged
    W[1:num_pass,t]= Wᴾ[pass_inds]
    # weight of resampled particles is set to the survival_threshold weight
    W[num_pass+1:end,t]= survival_threshold
    #resample the M possible particles to produce N particles for first t obs
    selected_Zᴾ = resample_stratified(Zᴾ[:,!pass_inds],Wᴾ[!pass_inds],N-num_pass)
    max_K₊ = maximum(K₊[:,t-1])+1  # number of possible allocat for next cluster
    for npind = 1:N
        if npind ≤  num_pass
            originating_particle_id = Zᴾ[1,pass_inds][npind]
            class_id_y = Zᴾ[2,pass_inds][npind]
        else
            originating_particle_id = selected_Zᴾ[1,npind-num_pass]
            class_id_y = selected_Zᴾ[2,npind-num_pass]
            Z[npind,1:t,np] = [Z[originating_particle_id,1:t-1,cp] ,class_id_y]
        end
        originating_particle_K₊ = K₊[originating_particle_id,t-1]
        new_count = cluster_counts[class_id_y,originating_particle_id,t-1]+1
        if new_count == 1
            K₊[npind,t] = originating_particle_K₊+1
        else
            K₊[npind,t] = originating_particle_K₊
        end
        cluster_counts[1:max_K₊,npind,t]= cluster_counts[1:max_K₊,originating_particle_id,t-1]
        cluster_counts[class_id_y,npind,t] = new_count
        old_mean = Ȳ[:,class_id_y,originating_particle_id,t-1]
        Ȳ[:,1:max_K₊,npind,t] = Ȳ[:,1:max_K₊,originating_particle_id,t-1]
        Ȳ[:,class_id_y,npind,t] =  old_mean + (1/new_count)*(y - old_mean)
        SS[:,:,1:max_K₊,npind,t]= SS[:,:,1:max_K₊,originating_particle_id,t-1]
        SS[:,:,class_id_y,npind,t] = SS[:,:,class_id_y,originating_particle_id,t-1] + yyᵀ
        (μ,Σ,ν)=update_posterior(new_count,Ȳ[:,class_id_y,npind,t],SS[:,:,class_id_y,npind,t])
        logdetΣ[1:max_K₊,npind,t] = logdetΣ[1:max_K₊,originating_particle_id,t-1]
        logdetΣ[class_id_y,npind,t] = logdet(Σ)
        invΣ[:,:,1:max_K₊,npind,t] = invΣ[:,:,1:max_K₊,originating_particle_id,t-1]
        invΣ[:,:,class_id_y,npind,t]=inv(Σ)
    end
    cp = np
end
#    return weights, Z,K₊
#end
#(W, Z,K₊)=particlefilter()

#cd("/home/rick/Dropbox/Candidacy/Answers/Code/Cudeck/data")
cd("/home/rick/Dropbox/Candidacy/Answers/Latex/images")

Ztrue=int16(dataset[4,:])

label_weights=Dict()
for t = 1:T
label_index=[find(Z[:,t,2].==i) for i=1:maximum(Z[:,t,2])]
label_weights["$t"]=[sum(W[:,t][label_index[i]]) for i=1:maximum(Z[:,t,2])]
end
Zpred=zeros(Int16,T)
for t = 1:T
  Zpred[t] =  findfirst(label_weights["$t"].==maximum(label_weights["$t"]))
end

p1=Dict();ind={[1,2],[1,3],[2,3]} # index of dataset
for i=1:3
    p1["$i"]=plot(x=Y[ind[i][1],:],y=Y[ind[i][2],:],
                  color=Ztrue,
                  Guide.xlabel("Dimension $(ind[i][1])"),
                  Guide.ylabel("Dimension $(ind[i][2])"),
                  Guide.title("True: View $i"),
                  Guide.colorkey("Cluster"),
                  Scale.color_discrete(),
                  Theme(default_point_size=.5mm))
end

p2=Dict()
for i=1:3
    p2["$i"]=plot(x=Y[ind[i][1],:],y=Y[ind[i][2],:],
                  color=Zpred,
                  Guide.xlabel("Dimension $(ind[i][1])"),
                  Guide.ylabel("Dimension $(ind[i][2])"),
                  Guide.title("Predicted: View $i"),
                  Guide.colorkey("Cluster"),
                  Scale.color_discrete(),
                  Theme(default_point_size=.5mm))
end
draw(PDF("Estimation2.pdf", 6inch, 9inch),#write to file
        hstack(vstack(p1["1"],p1["2"],p1["3"]),vstack(p2["1"],p2["2"],p2["3"])))

~~~ 





