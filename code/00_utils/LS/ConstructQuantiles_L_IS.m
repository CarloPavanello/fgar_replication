function M = ConstructQuantiles_L_IS(targets,factors,tau,h,H)

    %   CONSTRUCTQUANTILES_L_IS Construct in-sample location-factor quantile forecasts.
    %   The function estimates a location-scale model separately for each target
    %   variable and returns the fitted conditional quantile series at the
    %   specified quantile level tau.
    %
    %   For each target variable, the dependent variable is built using the
    %   selected forecast horizon h. The location equation includes an intercept,
    %   the selected factor series, and the first-horizon lag of the target
    %   variable. The scale equation includes only an intercept, so factors enter
    %   the model only through the location equation.
    %
    %   Perfectly collinear location regressors are removed, rows with missing
    %   location regressors are excluded, and the model is estimated using
    %   lsmem_garch.
    %
    %   The fitted quantile is computed as the fitted location plus the
    %   conditional scale multiplied by the empirical tau-quantile of the
    %   standardized residual component.
    %
    %   Inputs:
    %       targets  T x N x nHorizons array of target variables
    %       factors  Matrix or array containing the factor series used only in
    %                the location equation
    %       tau      Quantile level used to compute the fitted conditional quantile
    %       h        Index of the forecast horizon
    %       H        Vector of forecast horizons
    %
    %   Output:
    %       M        T x N matrix containing the fitted in-sample quantiles for
    %                each target variable
    
    %% function

    T = size(targets(:,1,1),1);
    N = size(targets,2);
    M = nan(T,N);
    t = T-H(h)+1;
    
    for i = 1:N 
    
        % allocate space for scale parameters  
        scale_pars =[];
    
        % dependent variable
        y = targets(2:t,i,h); % not scaled.
        % X and values for prediction for the location
        X_loc   = [ ones(numel(y),1), factors(1:t-1,T) , targets(1:t-1,i,1) ];
        X_scale = [ ones(numel(y),1) ];
        
        % avoid collinearity (problematic case: VIX) 
        no_collinearity = ~all(X_loc(:,2:end-1) == X_loc(:,end) | X_loc(:,2:end-1) == -X_loc(:,end), 1);
        no_collinearity = [true, no_collinearity, true];
        X_loc = X_loc( : , no_collinearity);
        
        % keep the rows where the factor is not missing
        valid_rows = ~any(isnan(X_loc),2);
        y = y(valid_rows);
        X_loc = X_loc(valid_rows,:);
        X_scale = X_scale(valid_rows,:);
        
        % Estimate models
        [loc_pars,scale_pars,yhat,trend,vt,tv,zt] = lsmem_garch(y,X_loc,X_scale,scale_pars,H(h));
        
        % get the quantile
        % location
        loc = X_loc*loc_pars;
        % random component
        qt = quantile(zt,tau);
        % overall
        M([false; valid_rows],i) = loc + sqrt(tv)*qt;
    
    end
end