%% Housekeeping
clear
close all
clc

addpath('../00_utils/Parallel')
addpath('../00_utils/QR')

%% Load variables

% factors
factors = load('../../data/outputs/factors_is.mat').factors_is;
factors_names = load('../../data/outputs/factors_is.mat').factors_is_names;
% averaged fred md series
load('../../data/outputs/prediction_targets.mat');

% quantile of interest
tau = 0.05;

[T,K,~] = size(factors);
N = size(targets,2);
H = [1 3 6 12];

%% Set up parallelization
start_parpool(10);

numTasks = K;
futures(numTasks) = parallel.FevalFuture; % Preallocate futures

%% Run QRs models

tic;   % start timing

for h = 1:numel(H)

    % submit K futures for this h
    for k = 1:K
        futures(k) = parfeval(@ConstructQuantiles_QR_IS, 5, ...
            targets, squeeze(factors(:,k,:)), tau, h, H);
    end
    
    % collect and store outputs
    for k = 1:K
        [M_k, TL_k, signif_k, bfac_k, bar1_k] = fetchOutputs(futures(k));
    
        M(:,:,h,k)              = M_k;
        TL(:,h,k)               = TL_k;
        significance_CI(:,h,k)  = signif_k;
        b_fac(:,h,k)            = bfac_k;
        b_ar1(:,h,k)            = bar1_k;
    end
    
    clear futures
end        

elapsedTime = toc;   % stop timing, returns seconds
fprintf('Elapsed time: %.4f seconds\n', elapsedTime);

save('../../data/outputs/quantiles/QR_IS.mat','M','factors_names')
save('../../data/outputs/QR_IS_TL.mat','TL','factors_names')
save('../../data/outputs/QR_IS_significance.mat','significance_CI','factors_names')
save('../../data/outputs/QR_IS_b_fac.mat','b_fac','factors_names')
save('../../data/outputs/QR_IS_b_ar1.mat','b_ar1','factors_names')
