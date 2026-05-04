%% Housekeeping
clear
close all
clc

addpath('../00_utils/Parallel')
addpath('../00_utils/LS')

%% Load variables

% averaged fred md series
load('../../data/outputs/prediction_targets.mat');

% quantile of interest
tau = 0.05;
H = [1 3 6 12];
t_0 = find(targets_dates == '1989-12');
N = size(targets,2);

%% Set up parallelization
start_parpool(10);

%% Run LS models for all factor sets

for n_fac = {'singletons','pairs','triplets'}
    n_fac = n_fac{1};

    load(sprintf('../../data/outputs/factors_%s.mat',n_fac));

    if strcmp(n_fac,'singletons')
        factors = factors_singletons;
        factors_names = factors_singletons_names;
    elseif strcmp(n_fac,'pairs')
        factors = factors_pairs;
        factors_names = factors_pairs_names;
    else
        factors = factors_triplets;
        factors_names = factors_triplets_names;
    end

    [T,K,~] = size(factors);
    M = nan(T,N,numel(H),K);

    numTasks = K;
    futures(numTasks) = parallel.FevalFuture;

    tic;

    for h = 1:numel(H)

        for k = 1:K
            futures(k) = parfeval(@ConstructQuantiles_LS, 1, t_0, targets, squeeze(factors(:,k,:)), tau, h, H);
        end

        for k = 1:K
            M(:,:,h,k) = fetchOutputs(futures(k));
        end

        clear futures
        futures(numTasks) = parallel.FevalFuture;
    end

    elapsedTime = toc;
    fprintf('Elapsed time (%s): %.4f seconds\n', n_fac, elapsedTime);

    save(sprintf('../../data/outputs/quantiles/LS_OOS_%s.mat',n_fac),'M','factors_names')
end

