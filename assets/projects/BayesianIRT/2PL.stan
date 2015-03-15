data {
  int<lower=0> K;		// number of items
  int<lower=0> J;		// number of persons
  int<lower=0> N;		// number of responses 
  int<lower=0,upper=J> jj[N];   // person index for response n
  int<lower=1,upper=K> kk[N];   // item index for response n
  int<lower=0,upper=1> y[N];    // data vector		
} 

parameters {
  vector[J] theta;		//person effect vector
 
  vector<lower=0> [K] alpha;           // item discrimination vector
  real<lower=0>  mu_alpha; 	     // mean of discrimination parameters
  real<lower=0> sigma_alpha; // scale of discrimination parameters
 

  vector[K] beta; 	     // item difficulty vector
  real mu_beta;   	     // mean of difficulty parameters
  real<lower=0> sigma_beta;  // scale of difficulty parameters
} 


model {
// the hyperpriors

mu_alpha~cauchy(0,3);
sigma_alpha~cauchy(0,3);
mu_beta~cauchy(0,5);
sigma_beta~cauchy(0,3);

// the priors
for( i in 1:K){
  alpha[i]~normal(mu_alpha,sigma_alpha) T[0,];  
}
  beta~normal(mu_beta,sigma_beta);  // implies the hierarchical prior 
  theta~ normal(0, 1);       // strong prior to fix location and scale invariance

//the likelihood       
  { 
  vector[N] nu;  //vector of predictor terms
  for (i in 1:N) 
     nu[i] <- (alpha[kk[i]]*theta[jj[i]] - beta[kk[i]]); 
  y ~ bernoulli_logit(nu); 
  }
}
