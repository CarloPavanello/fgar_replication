%% Housekeeping
clear
close all
clc

addpath('../00_utils/Parallel')
addpath('../00_utils/QR')
addpath('../00_utils/LS')

%% Load variables

% fred md series
load('../../data/outputs/prediction_targets.mat');

tau = 0.05;

[T,N,~] = size(targets);
H = [1 3 6 12];
t_0 = find(targets_dates == '1989-12');
M = nan(T,N,numel(H),3);

%% Set up parallelization
start_parpool(8);

%% Benchmarks

% start timer
tic   

for h = 1:numel(H)

    % historical quantile
    for i = 1:N
        for t = t_0:(T-H(h))
           M(t+1,i,h,1) = quantile(targets(1:t-H(h)+1,i,h),tau);
        end
    end

    % QR AR(1)    
    futures = parfeval(@ConstructQuantiles_QR, 1, t_0, targets, [], tau, h, H); 
    M(:,:,h,2) = fetchOutputs(futures);

    % AR(1) GARCH(1,1)
    futures = parfeval(@ConstructQuantiles_LS, 1, t_0, targets, [], tau, h, H); 
    M(:,:,h,3) = fetchOutputs(futures);

end

% stop timer and get elapsed seconds
elapsedTime = toc;   
fprintf('\nElapsed time: %.2f seconds\n', elapsedTime);

bm_names = ["HIST"; "AR_qr"; "AR_ls"];

save('../../data/outputs/quantiles/BM_OOS.mat','M','bm_names')


