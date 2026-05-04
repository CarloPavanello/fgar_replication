function stats = is_statistics(targets,data,H,tau)

    %   IS_STATISTICS Compute in-sample model-comparison statistics.
    %   The function evaluates the in-sample performance of competing
    %   conditional quantile estimates across forecast horizons, target
    %   variables, and model specifications.
    %
    %   For each forecast horizon and model, the function keeps the rows with
    %   available quantile estimates and compares the realized target values
    %   with the corresponding fitted quantiles. It computes hit indicators,
    %   tick losses, benchmark-relative tick losses, average benchmark-relative
    %   tick losses, and average tick-loss gains.
    %
    %   The function also counts how often each model delivers the lowest
    %   benchmark-relative tick loss across target variables.
    %
    %   Inputs:
    %       targets  T x N x nHorizons array of realized target variables
    %       data     T x N x nHorizons x K array of fitted quantiles, where K is
    %                the number of model specifications
    %       H        Vector of forecast horizons
    %       tau      Quantile level used to evaluate the fitted quantiles
    %
    %   Output:
    %       stats    Structure containing in-sample model-comparison statistics
    %                for each forecast horizon and model specification
    
    %% function
    
    [~,N,~,K] = size(data);
    
    for h = 1:numel(H)
        for k = 1:K
            % targest and quantiles
            valid_rows = ~any(isnan(data(:,:,h,k)),2);
            y = targets(valid_rows,:,h); % not scaled.
            quantiles = data(valid_rows,:,h,k);
    
            % hits
            stats.hits{h,k} = y < quantiles;
    
            % tick losses
            stats.rho{h,k} = (tau-stats.hits{h,k}).*(y - quantiles);
            stats.tick_loss{h,k} = mean(stats.rho{h,k});
            % becnhmark tick loss
            stats.benchmark_tick_loss{h,k} = stats.tick_loss{h,k}./stats.tick_loss{h,1};
            % average benchmarked tick loss
            stats.avg_bm_tick_loss{h,k} = mean(stats.benchmark_tick_loss{h,k});
            % tick loss gain
            stats.avg_bm_tick_loss_gain(h,k) = (1-stats.avg_bm_tick_loss{h,k})*100;          
         
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