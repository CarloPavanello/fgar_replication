function [PC,QF,PCF] = ConstructFactors_Parallel(t,data,factors,tau,n_fac)

    %   CONSTRUCTFACTORS_PARALLEL Construct PCA and quantile-based factors.
    %   The function standardizes the data available up to time t and constructs
    %   three sets of factors: principal components from the input data,
    %   quantile factors from the input data, and principal components from the
    %   observed factors.
    %
    %   The input data and observed factors are standardized using their
    %   available-sample means and variances, ignoring missing values. PCA is
    %   then applied without additional centering because the variables have
    %   already been standardized.
    %
    %   Inputs:
    %       t        End point of the estimation sample
    %       data     Matrix of input variables used to construct latent factors
    %       factors  Matrix of observed factors
    %       tau      Quantile level used in the quantile factor estimation
    %       n_fac    Number of factors to extract
    %
    %   Outputs:
    %       PC       First n_fac principal components extracted from data
    %       QF       First n_fac quantile factors extracted from data
    %       PCF      First n_fac principal components extracted from factors
    
    %% function

    scale_var = @(x) (x - mean(x,'omitnan'))./sqrt(var(x,'omitnan'));
    X = scale_var(data(1:t,:));
    
    % PCA
    [~, score] = pca(X, 'Centered', false);
    PC = score(:,1:n_fac);
    
    % QFA
    tol=0.001;  
    [qfac,~] = IQR(X,n_fac,tol,tau);
    QF = qfac;
    
    % PCA on Observed factors
    F = scale_var(factors(1:t,:));
    [~, score_f] = pca(F, 'Centered', false);
    PCF = score_f(:,1:n_fac);
end