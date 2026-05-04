%% Housekeeping
clear
close all
clc

addpath('../00_utils/Parallel')
addpath('../00_utils/LS')

%% Load variables

% factors
factors = load('../../data/outputs/factors_singletons.mat').factors_singletons;
factors_names = load('../../data/outputs/factors_singletons.mat').factors_singletons_names;
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
futures_L(numTasks) = parallel.FevalFuture; % Preallocate futures
futures_S(numTasks) = parallel.FevalFuture; % Preallocate futures
futures_LS(numTasks) = parallel.FevalFuture; % Preallocate futures

%% Run LSs models

tic;   %start timing

for h = 1:numel(H)

  for k = 1:K
    futures_L(k) = parfeval(@ConstructQuantiles_L_IS, 1, targets, squeeze(factors(:,k,:)), tau, h, H);
    futures_S(k) = parfeval(@ConstructQuantiles_S_IS, 1, targets, squeeze(factors(:,k,:)), tau, h, H);
    futures_LS(k) = parfeval(@ConstructQuantiles_LS_IS, 1, targets, squeeze(factors(:,k,:)), tau, h, H);
  end

  for k = 1:K
    M_L(:,:,h,k)  = fetchOutputs(futures_L(k));
    M_S(:,:,h,k)  = fetchOutputs(futures_S(k));
    M_LS(:,:,h,k) = fetchOutputs(futures_LS(k));
  end

  clear futures_L futures_S futures_LS
  
  futures_L(numTasks) = parallel.FevalFuture; % Preallocate futures
  futures_S(numTasks) = parallel.FevalFuture; % Preallocate futures
  futures_LS(numTasks) = parallel.FevalFuture; % Preallocate futures

end

elapsedTime = toc;   % stop timing, returns seconds
fprintf('Elapsed time: %.4f seconds\n', elapsedTime);

save("../../data/outputs/quantiles/L_IS.mat",'M_L','factors_names')
save("../../data/outputs/quantiles/S_IS.mat",'M_S','factors_names')
save("../../data/outputs/quantiles/LS_IS.mat",'M_LS','factors_names')

