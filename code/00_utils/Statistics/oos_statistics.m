function stats = oos_statistics(targets,data,T_0,H,tau,n_hits)
    
    %   OOS_STATISTICS Compute out-of-sample evaluation statistics.
    %   The function evaluates the out-of-sample performance of competing
    %   conditional quantile forecasts across forecast horizons, target
    %   variables, and model specifications.
    %
    %   For each forecast horizon and model, the function compares the realized
    %   target values with the corresponding quantile forecasts. It computes hit
    %   indicators, average hit frequencies, tick losses, benchmark-relative tick
    %   losses, average tick-loss gains, and standardized cross-sectional average
    %   losses.
    %
    %   The function also evaluates joint downside-risk behavior by comparing
    %   the empirical survival function of the number of simultaneous hits with
    %   the corresponding binomial survival function. Dynamic quantile tests are
    %   performed for each target variable using both an unconditional
    %   specification and a specification with four lagged hits.
    %
    %   Finally, the function records the share of dynamic-quantile test
    %   rejections and acceptances, and counts how often each model delivers the
    %   lowest benchmark-relative tick loss across target variables.
    %
    %   Inputs:
    %       targets  T x N x nHorizons array of realized target variables
    %       data     T x N x nHorizons x K array of quantile forecasts, where K
    %                is the number of model specifications
    %       T_0      Initial out-of-sample evaluation date
    %       H        Vector of forecast horizons
    %       tau      Quantile level used to evaluate the forecasts
    %       n_hits   Number of simultaneous hits used to compute the empirical
    %                to binomial survival ratio
    %
    %   Output:
    %       stats    Structure containing out-of-sample evaluation statistics
    %                for each forecast horizon and model specification
    
    %% function
    
    [T,N,~,K] = size(data);
    
    for h = 1:numel(H)
        for k = 1:K
            % targest and quantiles
            y = targets(T_0+1:T-H(h)+1,:,h); % not scaled.
            y_is = targets(1:T_0,:,h); % not scaled.
            quantiles = data(T_0+1:T-H(h)+1,:,h,k);
    
            % hits
            stats.hits{h,k} = y < quantiles;
            % overall average number of hits
            stats.avg_n_hits{h,k} = mean(mean(stats.hits{h,k}));
    
            % tick losses
            stats.rho{h,k} = (tau-stats.hits{h,k}).*(y - quantiles);
            stats.tick_loss{h,k} = mean(stats.rho{h,k});
            % benchmark tick loss
            stats.benchmark_tick_loss{h,k} = stats.tick_loss{h,k}./stats.tick_loss{h,1};
            % average benchmarked tick loss
            stats.avg_bm_tick_loss{h,k} = mean(stats.benchmark_tick_loss{h,k});
            % tick loss gain
            stats.avg_bm_tick_loss_gain(h,k) = (1-stats.avg_bm_tick_loss{h,k})*100;
            % standardized rho and cross section average
            is_std_inv = 1./std(y_is);
            stats.wavg_rho{h,1}(:,k) = sum(stats.rho{h,k}.*is_std_inv,2)./sum(is_std_inv);
    
            % survival function of the binomial
            surv_binom = 1 - binocdf(0:N, N, tau);
            % empirical survival 
            sum_hits = sum(stats.hits{h,k},2);
            surv_emp = (numel(sum_hits) - cumsum(histcounts(sum_hits, (0-0.5):1:(N+0.5))))/numel(sum_hits);
            % get the ratio of 12 (10% of sample) or more joint hist between model and binomial
            stats.surv_ratio{h,k} = surv_emp(n_hits)/surv_binom(n_hits);
    
            % perform two dynamic quantile tests considering as regressors:
            % 1) unconditional    
            % 2) 4 lagged hits
            for i = 1:N
                %p-values
                stats.DQ_unc_p{h,k}(i) = dq_unc(tau,stats.hits{h,k}(:,i),H(h));
                stats.DQ_ar4_p{h,k}(i) = dq_hits(tau,stats.hits{h,k}(:,i),H(h));
            end
            % share of rejections
            stats.DQ_unc_share_rej{h,k} = mean(stats.DQ_unc_p{h,k} < 0.05);
            stats.DQ_ar4_share_rej{h,k} = mean(stats.DQ_ar4_p{h,k} < 0.05);      
            % share of acceptance
            stats.DQ_unc_share_acc{h,k} = 1-stats.DQ_unc_share_rej{h,k};
            stats.DQ_ar4_share_acc{h,k} = 1-stats.DQ_ar4_share_rej{h,k};
    
            %assess how many times each model wins in terms of tick loss
            %put in one matrix all the relative performance of each model    
            if k == 1
                stats.benchmark_tick_loss_compact{h,1} = stats.benchmark_tick_loss{h,k};
            else
                stats.benchmark_tick_loss_compact{h,1} = [stats.benchmark_tick_loss_compact{h,1}; stats.benchmark_tick_loss{h,k}];
            end     
        end
    
        for i = 1:N
            [stats.minimum{h,1}(:,i),stats.win_idx{h,1}(:,i)] = min(stats.benchmark_tick_loss_compact{h,1}(:,i));
        end
        stats.win_counts{h,1} = histcounts(stats.win_idx{h,1}, 1:(K+1));
    end
end