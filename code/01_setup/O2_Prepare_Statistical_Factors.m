%% Housekeeping
clear
close all
clc

addpath('../00_utils/Parallel')
addpath('../00_utils/Factors')

%% Organize

% load fred
load('../../data/outputs/fred_md.mat');
% load factors
load('../../data/outputs/observable_factors.mat');

% filter out redundant price series
data = fred(:,~contains(fred_names,'_up'));
% filter out factors
factors = factors(:,~ismember(factors_names,["PRISK";"NPRISK";"RISK"]));

% useful elements
[T, N] = size(data);
t_0 = find(factors_dates == '1989-12');
n_fac = 5;

% allocate space
prcomp = nan(T,n_fac,T-t_0);
qcomp = nan(T,n_fac,T-t_0);
prfac = nan(T,n_fac,T-t_0);

% fix the tolerance for quantile factors 
tau = 0.05;


%% Construct factors in parallel

start_parpool(8);

numTasks = T;
futures(numTasks) = parallel.FevalFuture;  % Preallocate futures

% Submit tasks to run in parallel
for t = t_0:T
    futures(t) = parfeval(@ConstructFactors_Parallel, 3, t, data, factors,tau,n_fac);
end

for t = t_0:T % the last factor we will need is for T-1
  [pctmp, qftmp, pcftmp] = fetchOutputs(futures(t));
  prcomp(1:t,:,t) = pctmp;
  qcomp(1:t,:,t) = qftmp;
  prfac(1:t,:,t) = pcftmp;
end

S = struct('PC',prcomp,'QF',qcomp,'PCF',prfac);
save('../../data/outputs/statistical_factors.mat','S');

