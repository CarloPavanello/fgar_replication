function [M,TL,significance_CI,b_fac,b_ar1] = ConstructQuantiles_QR_IS(targets,factors,tau,h,H)

    %   CONSTRUCTQUANTILES_QR_IS Construct in-sample quantile-regression forecasts.
    %   The function estimates a quantile regression separately for each target
    %   variable and returns the fitted conditional quantile series at the
    %   specified quantile level tau.
    %
    %   For each target variable, the dependent variable is built using the
    %   selected forecast horizon h. The quantile regression includes an
    %   intercept, the selected factor series when available, and the
    %   first-horizon lag of the target variable. If no factors are provided, the
    %   model includes only an intercept and the first-horizon lag of the target
    %   variable.
    %
    %   Perfectly collinear factor regressors are removed, rows with missing
    %   regressors are excluded, and the model is estimated using rq.
    %
    %   When factors are included, the function also computes the average tick
    %   loss and uses a block bootstrap to assess whether the factor coefficient
    %   is statistically different from zero based on its empirical confidence
    %   interval.
    %
    %   Inputs:
    %       targets          T x N x nHorizons array of target variables
    %       factors          Matrix or array containing the factor series used in
    %                        the quantile regression. If empty, only the lagged
    %                        target variable is included besides the intercept
    %       tau              Quantile level used in the quantile regression
    %       h                Index of the forecast horizon
    %       H                Vector of forecast horizons
    %
    %   Outputs:
    %       M                T x N matrix containing the fitted in-sample
    %                        quantiles for each target variable
    %       TL               N x 1 vector containing the average tick loss when
    %                        factors are included
    %       significance_CI  N x 1 indicator equal to one when the bootstrap
    %                        confidence interval for the factor coefficient
    %                        excludes zero
    %       b_fac            N x 1 vector containing the estimated factor
    %                        coefficient when factors are included
    %       b_ar1            N x 1 vector containing the estimated coefficient
    %                        on the lagged target variable
    
    %% function
    
    T = size(targets(:,1,1),1);
    N = size(targets,2);
    M = nan(T,N);
    b_ar1 = nan(N,1);
    b_fac = nan(N,1);
    TL = nan(N,1);
    significance_CI = nan(N,1);
    t = T-H(h)+1;
    %repetitions bootstrap
    B = 1000;
    %size of the blocks for bootstrap
    w = 4+H(h); 
    
    for i = 1:N
    
        % dependent variable
        y = targets(2:t,i,h); % not scaled.
        % X and values for prediction for the location
        if size(factors,2) == 0
            X = [ ones(numel(y),1), targets(1:t-1,i,1) ];
        else
            X = [ ones(numel(y),1) , factors(1:t-1,t), targets(1:t-1,i,1) ];
        end
        
        % avoid collinearity (problematic case: VIX)
        if size(factors,2) ~= 0
            no_collinearity = ~all(X(:,2:end-1) == X(:,end) | X(:,2:end-1) == -X(:,end), 1);
            no_collinearity = [true, no_collinearity, true];
            X = X( : , no_collinearity);
        end
    
        % keep the rows where the factor is not missing
        valid_rows = ~any(isnan(X),2);
        y = y(valid_rows);
        X = X(valid_rows,:);
    
        % estimate models
        b = rq(X,y,tau);
        b_fac(i) = b(2);
        b_ar1(i) = b(end);
    
        % quantile
        M([false; valid_rows],i) = X*b;
    
        if size(factors,2) ~= 0
            % get the tick loss
            TL(i) = mean((tau-(y<X*b)).*(y-X*b));
        
            % allocate space to store the coefficient
            b_boot = nan(size(X,2),B);
            %prepare the block bootstrap for s.e.
            Z = (1:sum(valid_rows));
            %bootstrap
            idx = block_bootstrap(Z',B,w);
        
            % repeat over the B samples
            for r = 1:B
                % run the quantile regression
                b_boot(:,r) = rq(X(idx(:,r),:), y(idx(:,r)), tau);
            end
        
            % get the quantiles on b_boot
            q_025 = quantile(b_boot(2,:),0.025);
            q_975 = quantile(b_boot(2,:),0.975);
        
            % significance with the CI
            significance_CI(i) = ~((q_025<0)&(0<q_975));
        end
    end
end