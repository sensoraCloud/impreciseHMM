# impreciseHMM

Imprecise bayesian version of Hidden Markov Model

## Description

A novel technique to classify time series with imprecise hidden Markov models is presented. The learning of these models is achieved by coupling the EM algorithm with the imprecise Dirichlet model. In the stationarity limit, each model corresponds to an imprecise mixture of Gaussian densities, this reducing the problem to the classification of static, imprecise-probabilistic, information. Two classifiers, one based on the expected value of the mixture, the other on the Bhattacharyya distance between pairs of mixtures, are developed. The computation of the bounds of these descriptors with respect to the imprecise quantification of the parameters is reduced to, respectively, linear and quadratic optimization tasks, and hence efficiently solved. Classification is performed by extending the k-nearest neighbors approach to interval-valued data. The classifiers are credal, meaning that multiple class labels can be returned in the output. Experiments on benchmark datasets for computer vision show that these methods achieve the required robustness whilst outperforming other precise and imprecise methods.

## Ref. Publication
Robust classification of multivariate time series by imprecise hidden Markov models  
Alessandro Antonucci, Rocco De Rosa, Alessandro Giusti, Fabio Cuzzolin  
International Journal of Approximate Reasoning (IJAR), 56, pp.249-263  
https://www.sciencedirect.com/science/article/pii/S0888613X14001212  
