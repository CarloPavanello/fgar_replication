%% Housekeeping
clear
close all
clc

addpath('../../00_utils/Statistics')

%% Load data - 1 Factor

% oos quantiles - 1 Factor
BM = load('../../../data/outputs/quantiles/BM_IS.mat').M;
bm_names = load('../../../data/outputs/quantiles/BM_IS.mat').bm_names;

QR = load('../../../data/outputs/quantiles/QR_IS.mat').M;
qr_names = load('../../../data/outputs/quantiles/QR_IS.mat').factors_names + "_qr";
% remove short factors
QR = QR(:,:,:,~ismember(qr_names,["PRISK_qr";"NPRISK_qr";"RISK_qr"]));
qr_names = qr_names(~ismember(qr_names,["PRISK_qr";"NPRISK_qr";"RISK_qr"]));

L = load('../../../data/outputs/quantiles/L_IS.mat').M_L;
l_names = load('../../../data/outputs/quantiles/L_IS.mat').factors_names + "_l";
S = load('../../../data/outputs/quantiles/S_IS.mat').M_S;
s_names = load('../../../data/outputs/quantiles/S_IS.mat').factors_names + "_s";
LS = load('../../../data/outputs/quantiles/LS_IS.mat').M_LS;
ls_names = load('../../../data/outputs/quantiles/LS_IS.mat').factors_names + "_ls";

data = cat(4,BM,QR,L,S,LS);

% targets - averaged fred md
load('../../../data/outputs/prediction_targets.mat');

% set up
tau = 0.05;
T_0 = find(targets_dates == '1989-12');
H = [1 3 6 12];

%% Full Sample

% full list of names
names = [ bm_names; qr_names; l_names; s_names; ls_names ];
names_reordered = [bm_names(1:2); qr_names; bm_names(3); l_names; bm_names(3); s_names; bm_names(3); ls_names];
% reordering indexes
[~, idx] = ismember(names_reordered, names);
% reorder data
data = data(:,:,:,idx);

%% Policy relevant variables
pr = ["W875RX1";"INDPRO";"UNRATE";"PAYEMS";"HOUST"; ...
    "WPSFD49207";"WPSFD49207_up";"CPIAUCSL";"CPIAUCSL_up"];

[~,idx] = ismember(pr,targets_names);
data_pr = data(:,idx,:,:);
targets_pr = targets(:,idx,:);

%% Statistics

% full
stats = is_statistics(targets,data,H,tau);
save('../../../data/outputs/stats_is_1_fac.mat','stats','names_reordered');
% policy relavant
stats_pr = is_statistics(targets_pr,data_pr,H,tau);
save('../../../data/outputs/stats_is_1_fac_PR.mat','stats_pr','names_reordered');