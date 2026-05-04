%% Housekeeping
clear
close all
clc

addpath('../../00_utils/Statistics')

%% Load data

% oos quantiles
BM = load('../../../data/outputs/quantiles/BM_OOS.mat').M;
BM_names = load('../../../data/outputs/quantiles/BM_OOS.mat').bm_names;

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

% targets - averaged fred md
load('../../../data/outputs/prediction_targets.mat');

% set up
tau = 0.05;
T_0 = find(targets_dates == '1989-12');
H = [1 3 6 12];

%% Concatenate
data_qr = cat(4,QR_S,QR_P,QR_T);
data_ls = cat(4,LS_S,LS_P,LS_T);

% qr
names_qr1 = QR_S_names;
names_qr2 = QR_P_names(:,1) + "_" + QR_P_names(:,2);
names_qr3 = QR_T_names(:,1) + "_" + QR_T_names(:,2) + "_" + QR_T_names(:,3);
names_qr = [names_qr1; names_qr2; names_qr3];

% ls
names_ls1 = LS_S_names;
names_ls2 = LS_P_names(:,1) + "_" + LS_P_names(:,2);
names_ls3 = LS_T_names(:,1) + "_" + LS_T_names(:,2) + "_" + LS_T_names(:,3);
names_ls = [names_ls1; names_ls2; names_ls3];

%% Specifications selection

% manually select the specifications (careful, the order matters)
specification_selection = ["MUNC"; "MUNC_FUNC"; "MUNC_NFCI"; "MUNC_EBP"; "MUNC_FUNC_EBP"; "MUNC_EPU"; "MUNC_PC1"; "MUNC_PC1_QF1";...
"FUNC_CISS"; "FUNC_EBP"; "CISS_EBP"; "FUNC_EPU"; "NFCI_PC1"; "FUNC_PC1_EPU"; "FUNC_QF1_EPU";...
"NFCI_CISS_QF1";...
"NFCI_EPU";...
"QF1_QF2_QF3"; "PC1_QF1"; "PC1_QF1_EPU"];
% benchmark
data_bm = BM(:,:,:,1);
names_bm = BM_names(1); 

% select models
[~, idx] = ismember(specification_selection, names_qr);
% select data
data_qr = data_qr(:,:,:,idx);
names_qr = names_qr(idx);

% select models
[~, idx] = ismember(specification_selection, names_ls);
% select data
data_ls = data_ls(:,:,:,idx);
names_ls = names_ls(idx);

% concatenate
data = cat(4,data_bm,data_qr,data_ls);
names = [names_bm; names_qr + "_qr"; names_ls + "_ls"];

%% Statistics
stats = oos_statistics(targets,data,T_0,H,tau,13);
save('../../../data/outputs/stats_mix.mat','stats','names','specification_selection');

