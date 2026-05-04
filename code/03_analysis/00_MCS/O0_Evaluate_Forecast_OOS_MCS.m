%% Housekeeping
clear
close all
clc

addpath('../../00_utils/Statistics')

%% Load data

% oos quantiles
BM = load('../../../data/outputs/quantiles/BM_OOS.mat').M;
bm_names = load('../../../data/outputs/quantiles/BM_OOS.mat').bm_names;

QR_S = load('../../../data/outputs/quantiles/QR_OOS_singletons.mat').M;
QR_S_names = load('../../../data/outputs/quantiles/QR_OOS_singletons.mat').factors_names;
QR_P = load('../../../data/outputs/quantiles/QR_OOS_pairs.mat').M;
QR_P_names = load('../../../data/outputs/quantiles/QR_OOS_pairs.mat').factors_names;
QR_T = load('../../../data/outputs/quantiles/QR_OOS_triplets.mat').M;
QR_T_names = load('../../../data/outputs/quantiles/QR_OOS_triplets.mat').factors_names;

LS_S = load('../../../data/outputs/quantiles/LS_OOS_singletons.mat').M;
LS_S_names = load('../../../data/outputs/quantiles/LS_OOS_singletons.mat').factors_names;
LS_P = load('../../../data/outputs/quantiles/LS_OOS_pairs.mat').M;
LS_P_names = load('../../../data/outputs/quantiles/LS_OOS_pairs.mat').factors_names;
LS_T = load('../../../data/outputs/quantiles/LS_OOS_triplets.mat').M;
LS_T_names = load('../../../data/outputs/quantiles/LS_OOS_triplets.mat').factors_names;

% concatenate
data = cat(4,BM,QR_S,QR_P,QR_T,LS_S,LS_P,LS_T);

% targets - averaged fred md
load('../../../data/outputs/prediction_targets.mat');

% set up
tau = 0.05;
T_0 = find(targets_dates == '1989-12');
H = [1 3 6 12];

%% reorder series

% qr
names_qr1 = QR_S_names + "_qr";
names_qr2 = QR_P_names(:,1) + "_" + QR_P_names(:,2) + "_qr";
names_qr3 = QR_T_names(:,1) + "_" + QR_T_names(:,2) + "_" + QR_T_names(:,3) + "_qr";

% ls
names_ls1 = LS_S_names + "_ls";
names_ls2 = LS_P_names(:,1) + "_" + LS_P_names(:,2) + "_ls";
names_ls3 = LS_T_names(:,1) + "_" + LS_T_names(:,2) + "_" + LS_T_names(:,3) + "_ls";

% full list of names
names = [bm_names; names_qr1; names_qr2; names_qr3; names_ls1; names_ls2; names_ls3];
names_reordered = [bm_names(1:2); names_qr1; names_qr2; names_qr3; bm_names(3); names_ls1; names_ls2; names_ls3];

% reordering indexes
[~, idx] = ismember(names_reordered, names);
% reorder data
data = data(:,:,:,idx);

%% Statistics
stats = oos_statistics(targets,data,T_0,H,tau,13);
save('../../../data/outputs/stats_MCS.mat','stats','names_reordered');