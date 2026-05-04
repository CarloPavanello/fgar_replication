function M = ConstructQuantiles_LS_IS(targets,factors,tau,h,H)

    %   CONSTRUCTQUANTILES_LS_IS Construct in-sample location-scale quantile forecasts.
    %   The function estimates a location-scale model separately for each target
    %   variable and returns the fitted conditional quantile series at the
    %   specified quantile level tau.
    %
    %   For each target variable, the dependent variable is built using the
    %   selected forecast horizon h. The location equation includes an intercept,
    %   the selected factor series when available, and the first-horizon lag of
    %   the target variable. The scale equation includes the intercept and the
    %   selected factor series, but excludes the lagged target variable.
    %
    %   Perfectly collinear location regressors are removed, rows with missing
    %   values are excluded, and the model is estimated using lsmem_garch.
    %
    %   The fitted quantile is computed as the fitted location plus the
    %   conditional scale multiplied by the empirical tau-quantile of the
    %   standardized residual component.
    %
    %   Inputs:
    %       targets  T x N x nHorizons array of target variables
    %       factors  Matrix or array containing the factor series used in both
    %                the location and scale equations
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
        if size(factors,2) == 0
            X_loc = [ ones(numel(y),1), targets(1:t-1,i,1) ];
        else
            X_loc = [ ones(numel(y),1) , factors(1:t-1,t), targets(1:t-1,i,1) ];
        end
    
        % avoid collinearity (problematic case: VIX) 
        if size(factors,2) ~= 0
            no_collinearity = ~all(X_loc(:,2:end-1) == X_loc(:,end) | X_loc(:,2:end-1) == -X_loc(:,end), 1);
            no_collinearity = [true, no_collinearity, true];
            X_loc = X_loc( : , no_collinearity);
        end
    
        % keep the rows where the factor is not missing
        valid_rows = ~any(isnan(X_loc),2);
        y = y(valid_rows);
        X_loc = X_loc(valid_rows,:);
        
        % X for the scale
        X_scale = X_loc(:,1:end-1); % keep only the constant and the factors
        
        % Estimate models
        [loc_pars,scale_pars,~,~,~,tv,zt] = lsmem_garch(y,X_loc,X_scale,scale_pars,H(h));
        
        % get the quantile
        % location
        loc = X_loc*loc_pars;
        % random component
        qt = quantile(zt,tau);
        % overall
        M([false; valid_rows],i) = loc + sqrt(tv)*qt;
    
    end
end