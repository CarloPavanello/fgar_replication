%% Housekeeping
clear
close all
clc

addpath('../00_utils/Factors')

%% Load variables and prepare factors

% factors to use in the combinations
factors_selection = ["MUNC";"FUNC";"NFCI";"VIX";"CISS";"EBP";"EPU"];

% observable factors
fac_obs = load('../../data/outputs/observable_factors.mat');
% factors for is analysis
factors_obs_is = fac_obs.factors;
factors_obs_is_names = fac_obs.factors_names;
% remove "short" factors for oos analysis
factors_obs = fac_obs.factors(:,~ismember(fac_obs.factors_names,["PRISK";"NPRISK";"RISK"]));
factors_obs_names = fac_obs.factors_names(~ismember(fac_obs.factors_names,["PRISK";"NPRISK";"RISK"]));
% find factors_selection
[~, loc] = ismember(factors_selection,factors_obs_names);
% keep only selected factors in the order of the 
factors_selection = factors_obs(:,loc);
factors_selection_names = factors_obs_names(loc);
% reshape obs factors
factors_obs_is = expandTriangular(factors_obs_is);
factors_obs = expandTriangular(factors_obs);
factors_selection = expandTriangular(factors_selection);

% statistical factors
load('../../data/outputs/statistical_factors.mat');

pc1 = S.PC(:,1,:);
pc1pc2 = S.PC(:,1:2,:);
pc1pc2pc3 = S.PC(:,1:3,:);

qf1 = S.QF(:,1,:);
qf1qf2 = S.QF(:,1:2,:);
qf1qf2qf3 = S.QF(:,1:3,:);

pcf1 = S.PCF(:,1,:);
pcf1pcf2 = S.PCF(:,1:2,:);
pcf1pcf2pcf3 = S.PCF(:,1:3,:);

pc1qf1 = cat(2,pc1,qf1);
pc1qf1_names = ["PC1"; "QF1"];
pc1qf1pcf1 = cat(2,pc1,qf1,pcf1);
pc1qf1pcf1_names = ["PC1"; "QF1";"PCF1"];

% concatenate factors for combinations 
factors = cat(2,factors_selection(:,1:end-2,:), pc1qf1, factors_selection(:,end-1:end,:));
factors_names = [factors_selection_names(1:end-2); pc1qf1_names; factors_selection_names(end-1:end)];

%% Combine factors

% one factors
% is
factors_is = cat(2,factors_obs_is(:,1:end-6,:),pc1qf1pcf1,factors_obs_is(:,end-5:end,:));
factors_is_names = [factors_obs_is_names(1:end-6); pc1qf1pcf1_names; factors_obs_is_names(end-5:end)];
% oos
factors_singletons = cat(2,factors_obs(:,1:end-3,:),pc1qf1pcf1,factors_obs(:,end-2:end,:));
factors_singletons_names = [factors_obs_names(1:end-3); pc1qf1pcf1_names; factors_obs_names(end-2:end)];

% two factors
% combinations
[factors_pairs, pairs] = columnCombinationsStack(factors, 2);
factors_pairs_names = factors_names(pairs);
% pc
[pc1pc2, ~] = columnCombinationsStack(pc1pc2, 2);
% qf
[qf1qf2, ~] = columnCombinationsStack(qf1qf2, 2);
% pcf
[pcf1pcf2, ~] = columnCombinationsStack(pcf1pcf2, 2);
% concatenate
factors_pairs = cat(2,factors_pairs,pc1pc2,qf1qf2,pcf1pcf2);
factors_pairs_names = [factors_pairs_names; "PC1" "PC2";...
    "QF1" "QF2";...
    "PCF1" "PCF2"];

% three factors
%combinations
[factors_triplets, triplets] = columnCombinationsStack(factors, 3);
factors_triplets_names = factors_names(triplets);
% pc
[pc1pc2pc3, ~] = columnCombinationsStack(pc1pc2pc3, 3);
% qf
[qf1qf2qf3, ~] = columnCombinationsStack(qf1qf2qf3, 3);
% pcf
[pcf1pcf2pcf3, ~] = columnCombinationsStack(pcf1pcf2pcf3, 3);
% concatenate
factors_triplets = cat(2,factors_triplets,pc1pc2pc3,qf1qf2qf3,pcf1pcf2pcf3);
factors_triplets_names = [factors_triplets_names; "PC1" "PC2" "PC3"; ...
    "QF1" "QF2" "QF3"; ...
    "PCF1" "PCF2" "PCF3"];

% save
% is
save('../../data/outputs/factors_is.mat', 'factors_is', 'factors_is_names');
% oos
save('../../data/outputs/factors_singletons.mat', 'factors_singletons', 'factors_singletons_names');
save('../../data/outputs/factors_pairs.mat', 'factors_pairs', 'factors_pairs_names')
save('../../data/outputs/factors_triplets.mat', 'factors_triplets'  , 'factors_triplets_names')