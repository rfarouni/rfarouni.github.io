library("rstan")
library("parallel")
source("stan.R")

set.seed(42)

D<-2
J <- 800 
K <- 25
N <-J*K

mu_theta    <- c(0,0)
sigma_theta <- c(1,1)
mu_beta     <- -.5
sigma_beta  <-1.2

theta1  <- rnorm(J, mu_theta[1],sigma_theta[1] )
theta2  <- rnorm(J, mu_theta[2],sigma_theta[2] )
alpha1 <- sort(runif(K,.6,1.6),decreasing = TRUE)
alpha2 <- sort(runif(K,0,1.3))
beta   <- rnorm(K,mu_beta,sigma_beta)

y <- matrix(0,nrow=J,ncol=K)
for (j in 1:J)
  for (k in 1:K)
    y[j,k] <- rbinom(1,1,plogis(alpha1[k]*theta1[j] +alpha2[k]*theta2[j]+ beta[k]))
y<-as.vector(y)
jj <- rep(1,K)%x%c(1:J)
kk <- c(1:K)%x%rep(1,J)
data <-data.frame(Response=y, Item=kk, Person=jj)
head(data)

mirt.data <-list(J=J,K=K,N=N,jj=jj,kk=kk,y=y,D=D)
mirt.model<- stan("mirt.stan",iter=Niter, data = irt.data.1,chains =0)


Nchains <- 4
Niter <- 200
t_start <- proc.time()[3]
fit<-stan(fit = mirt.model, data =mirt.data, pars=c("alpha","beta","mu_alpha","mu_beta","sigma_alpha","sigma_beta"),
          iter=Niter,
          chains = Nchains)
t_end <- proc.time()[3]
t_elapsed <- t_end - t_start
(time <- t_elapsed / Nchains / (Niter/2))
print(fit)


traceplot(fit,pars=c("sigma_alpha"))
traceplot(fit,pars=c("alpha"))
mean.alpha<-get_posterior_mean(fit.irt.1 ,pars=c("alpha"))[,5]
mean.beta<-get_posterior_mean(fit.irt.1 ,pars=c("beta"))[,5]

estimates<-cbind(mean.alpha,alpha,mean.beta,beta)
