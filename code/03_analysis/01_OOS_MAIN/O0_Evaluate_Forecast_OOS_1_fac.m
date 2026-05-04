%% Housekeeping
clear
close all
clc

addpath('../../00_utils/Statistics')

%% Load data - 1 Factor

% oos quantiles - 1 Factor
BM = load('../../../data/outputs/quantiles/BM_OOS.mat').M;
bm_names = load('../../../data/outputs/quantiles/BM_OOS.mat').bm_names;
QR = load('../../../data/outputs/quantiles/QR_OOS_singletons.mat').M;
qr_names = load('../../../data/outputs/quantiles/QR_OOS_singletons.mat').factors_names + "_qr";
LS = load('../../../data/outputs/quantiles/LS_OOS_singletons.mat').M;
ls_names = load('../../../data/outputs/quantiles/LS_OOS_singletons.mat').factors_names + "_ls";
data = cat(4,BM,QR,LS);

% targets - averaged fred md
load('../../../data/outputs/prediction_targets.mat');

% set up
tau = 0.05;
T_0 = find(targets_dates == '1989-12');
H = [1 3 6 12];

%% Full Sample

% full list of names
names = [ bm_names; qr_names; ls_names ];
names_reordered = [bm_names(1:2); qr_names; bm_names(3); ls_names];
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

%% Specification selecton for summary table by Categories and Policy Relevant variables
specification_selection = ["HIST";"AR_qr";"AR_ls";"NFCI_qr"; "EBP_qr"; "FUNC_qr"; "MUNC_qr"; "QF1_qr"; "PCF1_qr";"NFCI_ls"; "EBP_ls"; "FUNC_ls"; "MUNC_ls"; "QF1_ls"; "PCF1_ls"];
specification_names = ["HIST";"AR QR";"AR LS";"NFCI"; "EBP"; "FUNC"; "MUNC"; "QF1"; "PCF1"; "NFCI"; "EBP"; "FUNC"; "MUNC"; "QF1"; "PCF1"];

%% Policy relevant variables - summary
[~,idx_spec] = ismember(specification_selection,names_reordered);
data_pr_summary = data_pr(:,:,:,idx_spec);

%% Categories

% Variables in each category
groups = struct( ...
    'output',  ["RPI";"W875RX1";"INDPRO";"IPFPNSS";"IPFINAL";"IPCONGD";"IPDCONGD";"IPNCONGD";...
    "IPBUSEQ";"IPMAT";"IPDMAT";"IPNMAT";"IPMANSICS";"IPB51222S";"IPFUELS";...
    "CUMFNS"], ...
    'labor',   ["HWI";"HWIURATIO";"CLF16OV";"CE16OV";"UNRATE";"UEMPMEAN";"UEMPLT5";"UEMP5TO14";...
    "UEMP15OV";"UEMP15T26";"UEMP27OV";"CLAIMSx";"PAYEMS";"USGOOD";"CES1021000001";"USCONS";...
    "MANEMP";"DMANEMP";"NDMANEMP";"SRVPRD";"USTPU";"USWTRADE";"USTRADE";...
    "USFIRE";"USGOVT";"CES0600000007";"AWOTMAN";"AWHMAN";"CES0600000008";"CES2000000008";"CES3000000008"], ...
    'housing', ["HOUST";"HOUSTNE";"HOUSTMW";"HOUSTS";"HOUSTW";"PERMIT";"PERMITNE";"PERMITMW";"PERMITS";"PERMITW"],...
    'ord_inv', ["CMRMTSPLx";"RETAILx";"AMDMNOx";"AMDMUOx";"BUSINVx";"ISRATIOx"],...
    'mon_cred', ["BUSLOANS";"REALLN";"NONREVSL";"CONSPI";"DTCOLNVHFNM";"DTCTHFNM";"INVEST"],...
    'rates', ["EXSZUSx";"EXJPUSx";"EXUSUKx";"EXCAUSx"],...
    'prices_downside', ["WPSFD49207";"WPSFD49502";"WPSID61";"WPSID62";"OILPRICEx";"PPICMM";...
    "CPIAUCSL";"CPIAPPSL";"CPITRNSL";"CPIMEDSL";"CUSR0000SAC";"CUSR0000SAD";...
    "CUSR0000SAS";"CPIULFSL";"CUSR0000SA0L2";"CUSR0000SA0L5";"PCEPI";...
    "DPCERA3M086SBEA";"DDURRG3M086SBEA";"DNDGRG3M086SBEA";"DSERRG3M086SBEA"],...
    'prices_upside', ["WPSFD49207_up";"WPSFD49502_up";"WPSID61_up";"WPSID62_up";"OILPRICEx_up";"PPICMM_up";...
    "CPIAUCSL_up";"CPIAPPSL_up";"CPITRNSL_up";"CPIMEDSL_up";"CUSR0000SAC_up";"CUSR0000SAD_up";...
    "CUSR0000SAS_up";"CPIULFSL_up";"CUSR0000SA0L2_up";"CUSR0000SA0L5_up";"PCEPI_up";...
    "DPCERA3M086SBEA_up";"DDURRG3M086SBEA_up";"DNDGRG3M086SBEA_up";"DSERRG3M086SBEA_up"],...
    'stocks', ["S&P 500";"S&P div yield";"S&P PE ratio";"VIXCLSx"]);

CAT = struct();
categories = string(fieldnames(groups));

for k = 1:numel(categories)
    gname = categories(k);
    names = groups.(gname);

    [tf, idx] = ismember(names, targets_names);
    if any(~tf)
        error('Missing in targets_names for group "%s": %s', gname, strjoin(names(~tf), ', '));
    end

    CAT.(gname).idx     = idx;
    CAT.(gname).data    = data(:, idx, :, idx_spec);
    CAT.(gname).targets = targets(:, idx, :);
end


%% Statistics

% full
stats = oos_statistics(targets,data,T_0,H,tau,13);
save('../../../data/outputs/stats_1_fac.mat','stats','names_reordered');
% policy relavant
stats_pr = oos_statistics(targets_pr,data_pr,T_0,H,tau,3);
stats_pr_summary = oos_statistics(targets_pr,data_pr_summary,T_0,H,tau,3);
save('../../../data/outputs/stats_1_fac_PR.mat','stats_pr','names_reordered');
save('../../../data/outputs/stats_1_fac_PR_summary.mat','stats_pr_summary','specification_names');
% categories
Stats_CAT = struct();
for c = 1:numel(categories)
    Stats_CAT.(sprintf("stats_%s", categories(c))) = oos_statistics(CAT.(categories(c)).targets, CAT.(categories(c)).data, T_0, H, tau, 3);
end
Stats_CAT.specification_names = specification_names;
save("../../../data/outputs/stats_1_fac_CAT.mat", "Stats_CAT");