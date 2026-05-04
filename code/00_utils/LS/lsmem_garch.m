function [loc_pars,scale_pars,yhat,trend,vt,tv,zt] = lsmem_garch(y,x_loc,x_scale,scl_pars_0,horizon)
    
    %   LSMEM_GARCH Estimate a location-scale model with GARCH-type volatility.
    %   The function first estimates the location equation by OLS and then
    %   models the resulting residuals using a GARCH(1,1)-type scale equation
    %   with covariates in the multiplicative volatility trend.
    %
    %   The location parameters are estimated from y and x_loc. The residuals
    %   from this location equation are then passed to garch11_covariates_LL,
    %   which estimates the scale parameters by minimizing the Gaussian negative
    %   log-likelihood. The scale specification decomposes the conditional
    %   variance into a covariate-driven trend component and a short-term
    %   GARCH(1,1) component.
    %
    %   If no initial scale parameters are provided, the function uses a grid
    %   search over the GARCH parameters to choose starting values for the
    %   likelihood optimization. If initial scale parameters are provided, they
    %   are used as a warm start. The final estimate is compared with a baseline
    %   GARCH specification, and the baseline is used as the starting point when
    %   it gives a lower negative log-likelihood.
    %
    %   Inputs:
    %       y           T x 1 vector of observations
    %       x_loc       T x nLoc matrix of regressors entering the location
    %                   equation
    %       x_scale     T x nScale matrix of regressors entering the scale trend
    %                   equation. Include a column of ones if an intercept is
    %                   desired.
    %       scl_pars_0  Initial values for the scale parameters. If empty, the
    %                   function selects starting values by grid search.
    %       horizon     Forecast horizon used in the GARCH recursion
    %
    %   Outputs:
    %       loc_pars    Estimated location parameters
    %       scale_pars  Estimated scale parameters. The first two entries are
    %                   the GARCH alpha and beta coefficients, and the remaining
    %                   entries are the coefficients of the scale trend equation
    %       yhat        Fitted values from the location equation
    %       trend       Multiplicative scale trend component
    %       vt          Short-term GARCH variance component
    %       tv          Total conditional variance
    %       zt          Standardized residuals
    
    %% function
    
    % Location model:
    loc_pars = x_loc\y; % OLS estimation 
    yhat = x_loc*loc_pars; % fitted values
    loc_res = y-yhat; % residuals
    
    % unconditional volatility
    unc_vol = log(std(loc_res));
    
    % options for the optimizer 
    options = optimset('fminsearch');
    options = optimset(options,'TolFun',1e-005);
    options = optimset(options,'TolX',1e-005);
    options = optimset(options,'Display','Off');
    
    if isempty(scl_pars_0)
    
      % Set options
      options = optimset(options,'MaxFunEvals',10000);
    
      % Do a grid search over parameters to select the best parameters where to start the optimization
      par = [ [0.01:0.01:0.2]' , [0.96:-0.01:0.77]']; % garch parameters
      par = [par repmat(unc_vol,[size(par,1) 1]) zeros([size(par,1) size(x_scale,2)-1])]; % all parameters, add zeros for trend parameters
    
      % Allocate space
      NLL = nan(size(par));
    
      for j=1:size(par,1)
        for k=1:size(par,1)
          NLL(j,k) = garch11_covariates_LL([par(j,1),par(k,2:end)],loc_res,x_scale,horizon);
        end
      end
    
      % Get the row and col index of the minimum
      [mr , mc] = find(NLL==min(NLL(:)));
      % First Minimization on the min of grid
      if numel(mr) > 1
        options = optimset(options,'MaxFunEvals',10000);
        [scale_pars, NLLmin] = fminsearch('garch11_covariates_LL',[0.1,0.8,zeros(1,size(x_scale,2))],options,loc_res,x_scale,horizon);
      else
        [scale_pars, NLLmin] = fminsearch('garch11_covariates_LL',[par(mr,1),par(mc,2:end)],options,loc_res,x_scale,horizon);
      end
    
    else
    
      % First Minimization on the warm start
      options = optimset(options,'MaxFunEvals',1000);
      [scale_pars, NLLmin] = fminsearch('garch11_covariates_LL',scl_pars_0,options,loc_res,x_scale,horizon);
    
    end
    
    % Robustness against standard garch
    [NLLcheck] = garch11_covariates_LL([0.1,0.8,zeros(1,size(x_scale,2))],loc_res,x_scale,horizon);
    
    % Choose the best
    if NLLmin > NLLcheck
      % Set options
      options = optimset(options,'MaxFunEvals',10000);
      scale_pars = fminsearch('garch11_covariates_LL',[0.1,0.8,zeros(1,size(x_scale,2))],options,loc_res,x_scale,horizon);
    end
    
    % Set final output
    [~, tv, trend, vt,zt] = garch11_covariates_LL(scale_pars,loc_res,x_scale,horizon);
end
