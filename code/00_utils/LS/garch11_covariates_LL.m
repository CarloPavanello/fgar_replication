function [NLL,tv,trend,vt,zt] = garch11_covariates_LL(param,data,covariates,horizon)

    %   GARCH11_COVARIATES_LL Evaluate a GARCH(1,1) likelihood with scale covariates.
    %   The function computes the Gaussian negative log-likelihood of a
    %   GARCH(1,1)-type variance model for a column vector of residuals or
    %   observations. The conditional variance is decomposed into a
    %   covariate-driven multiplicative trend component and a short-term
    %   GARCH(1,1) variance component.
    %
    %   The trend component is defined as an exponential function of the
    %   supplied covariates. The short-term variance component is initialized at
    %   one for the first horizon periods and then updated using a GARCH(1,1)
    %   recursion driven by the trend-adjusted residuals.
    %
    %   Inputs:
    %       param       Parameter vector. param(1) and param(2) are the GARCH
    %                   alpha and beta coefficients. param(3:end) are the
    %                   coefficients of the scale trend equation. Include a
    %                   column of ones in covariates if an intercept is desired.
    %
    %       data        T x 1 vector of residuals or observations used to
    %                   evaluate the likelihood.
    %
    %       covariates  T x nScale matrix of covariates entering the scale
    %                   trend component.
    %
    %       horizon     Forecast horizon used in the GARCH recursion.
    %
    %   Outputs:
    %       NLL         Gaussian negative log-likelihood. A large penalty value
    %                   is returned if the GARCH parameters violate the
    %                   stationarity or positivity restrictions.
    %
    %       tv          T x 1 vector of total conditional variances, equal to
    %                   trend.^2 multiplied by the short-term variance component.
    %
    %       trend       T x 1 vector of multiplicative scale trend components.
    %
    %       vt          (T+horizon) x 1 vector of short-term GARCH variance
    %                   components.
    %
    %       zt          T x 1 vector of standardized residuals.
    
    %% function
    
    % Initializing
    [T , N]   = size(data);
    vt        = nan(T+horizon,1);
    trend     = exp(covariates*param(3:end)');
    eps       = data./trend;  
    
    if N~=1
      error('Error: data must be a column vector');
    end
    
    %Assign 1 to the first "horizon" variances
    vt(1:horizon) = 1; 
    
    % Compute the garch(1,1) variances
    for t = horizon+1:T+horizon 
    
      vt(t) = vt(1)*(1-param(1)-param(2)) + ...
        param(1)*(eps(t-horizon))^2 + ... 
        param(2)*vt(t-1);
    
    end
    
    tv = trend.^2.*vt(1:T); % total variance
    % tv = trend(horizon:end).^2.*vt(horizon:T); % total variance
    
    % Restrictions on parameters
    r1 = (param(1) + param(2))>(1 - 1e-02) ;
    r2 = (param(1)<=0);
    r3 = (param(2)<0);
    
    if any([r1, r2, r3])
    
      NLL=100000000;
    
    else
    
      % Compute LL
      [LL,~] = normloglik(data,0,tv);
      % [LL,~] = normloglik(data(horizon:end),0,tv_is);
    
      %standardized residuals
      zt = data./sqrt(tv);
      % zt = data(horizon:end)./sqrt(tv_is);
    
      %neg. likelihood
      NLL = -LL;
    
    end
end