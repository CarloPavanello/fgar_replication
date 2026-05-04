function M = ConstructQuantiles_LS(t_0,targets,factors,tau,h,H)

    %   CONSTRUCTQUANTILES_LS Construct out-of-sample location-scale quantile forecasts.
    %   The function estimates a location-scale model recursively for each target
    %   variable and returns out-of-sample conditional quantile forecasts at the
    %   selected forecast horizon h and quantile level tau.
    %
    %   For each target variable and forecast origin, the dependent variable is
    %   built using the selected forecast horizon. The location equation includes
    %   an intercept, up to three selected factor series when available, and the
    %   first-horizon lag of the target variable. The scale equation includes the
    %   intercept and the same selected factor series, but excludes the lagged
    %   target variable. Therefore, factors enter both the location and scale
    %   equations, while the lagged target enters only the location equation.
    %
    %   Perfectly collinear location regressors are removed, rows with missing
    %   location regressors are excluded, and the model is estimated using
    %   lsmem_garch. Scale parameters are passed forward across forecast origins
    %   as warm-start values for the next optimization.
    %
    %   The forecasted quantile is computed as the predicted location plus the
    %   forecasted conditional scale multiplied by the empirical tau-quantile of
    %   the standardized residual component.
    %
    %   Inputs:
    %       t_0      Initial forecast origin
    %       targets  T x N x nHorizons array of target variables
    %       factors  Matrix containing zero, one, two, or three factor series.
    %                Multiple factor series are stored as separate T-column
    %                blocks: columns 1:T contain the first factor, columns
    %                T+1:2*T contain the second factor, and columns 2*T+1:3*T
    %                contain the third factor
    %       tau      Quantile level used to compute the conditional quantile forecast
    %       h        Index of the forecast horizon
    %       H        Vector of forecast horizons
    %
    %   Output:
    %       M        T x N matrix containing the out-of-sample quantile forecasts
    %                for each target variable
    
    %% function
    
    T = size(targets(:,1,1),1);
    N = size(targets,2);
    M = nan(T,N);
    n_fac = size(factors,2)/T;
    
    % split factors
    if n_fac == 1
        fac1 = factors(:,1:T);
    elseif n_fac == 2
        fac1 = factors(:,1:T);
        fac2 = factors(:,T+1:2*T);
    elseif n_fac == 3
        fac1 = factors(:,1:T);
        fac2 = factors(:,T+1:2*T);
        fac3 = factors(:,2*T+1:3*T);
    end
    
    for i = 1:N
    
      % allocate space for scale parameters  
      scale_pars =[];
    
      for t = t_0:(T-H(h))
        
        % dependent variable
        y = targets(2:t-H(h)+1,i,h); % not scaled.
        % X and values for prediction for the location
        if n_fac == 0
            X = [ ones(numel(y),1), targets(1:t-H(h),i,1) ];
            Xtest = [1 targets(t,i,1) ];
        elseif n_fac == 1 
            X = [ ones(numel(y),1) , fac1(1:t-H(h),t), targets(1:t-H(h),i,1) ];
            Xtest = [1 fac1(t,t) targets(t,i,1) ];
        elseif n_fac == 2 
            X = [ ones(numel(y),1) , fac1(1:t-H(h),t), fac2(1:t-H(h),t), targets(1:t-H(h),i,1) ];
            Xtest = [1 fac1(t,t) fac2(t,t) targets(t,i,1) ];
        else 
            X = [ ones(numel(y),1) , fac1(1:t-H(h),t), fac2(1:t-H(h),t), fac3(1:t-H(h),t), targets(1:t-H(h),i,1) ];
            Xtest = [1 fac1(t,t) fac2(t,t) fac3(t,t) targets(t,i,1) ];
        end
    
        % avoid collinearity (problematic case: VIX) 
        if n_fac ~= 0
            no_collinearity = ~all(X(:,2:end-1) == X(:,end) | X(:,2:end-1) == -X(:,end), 1);
            no_collinearity = [true, no_collinearity, true];
            X = X( : , no_collinearity);
            Xtest = Xtest( : , no_collinearity);
        end
    
        % keep the rows where the factor is not missing
        valid_rows = ~any(isnan(X),2);
        y = y(valid_rows);
        X = X(valid_rows,:);
    
        % X for the scale
        X_scale = X(:,1:end-1); % keep only the constant and the factors
        % X scale in the forecast    
        Xtest_scale = Xtest(:,1:end-1);
    
        % Estimate models
        [loc_pars,scale_pars,yhat,trend,vt,tv,zt] = lsmem_garch(y,X,X_scale,scale_pars,H(h));
    
        % Forecast    
        % location
        loc_forecast = Xtest*loc_pars;
        % trend
        trend_forecast = exp(Xtest_scale*scale_pars(3:end)');
        % total variance or multiplicative term
        tv_forecast = trend_forecast.^2.*vt(end);
        % random component
        qt_forecast = quantile(zt,tau);
        % overall
        M(t+1,i) = loc_forecast + sqrt(tv_forecast)*qt_forecast;
        
      end
    
      fprintf('.')
    end
end