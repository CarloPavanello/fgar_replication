%% Housekeeping
clear
close all
clc
scale_var = @(x) (x - nanmean(x))./sqrt(nanvar(x));
addpath('../../00_utils/LS')

%% Load variables
targets = load('../../../data/outputs/prediction_targets.mat');
targets_dates = targets.targets_dates;
targets_names = targets.targets_names;
targets = targets.targets;
tau = 0.05;

N = size(targets,2);
[~, score_mean, ~, ~, exp_mean, ~] = pca(scale_var(targets(:,:,1)));

fac = score_mean(:,1:4);
H=1;

%% GARCHs
for h = 1:numel(H)
    for i = 1:N
      target_tmp = scale_var(targets(:,i,h));
      latest_series_obs = scale_var(targets(1:end-H(h),i,1));
      y = target_tmp(2:end-H(h)+1);
      X = [ ones(numel(y),1), fac(1:end-H(h),:) , latest_series_obs  ];
      % last observed y , so we keep z dimension of target set to 1
      valid_rows = ~isnan(X(:,2));
      y = y(valid_rows);
      X = X(valid_rows,:);
      % Estimate models
      X_scale = X(:,1);
      [loc_pars,scale_pars,yhat,trend,vt,tv,zt] = lsmem_garch(y,X,X_scale,[],H(h));
      M(valid_rows,i,h) = tv;
      HIT(valid_rows,i,h) = y<quantile(y,0.05);
    end
end

%% Define objects
V = sqrt(M(:,:))./mean(sqrt(M));
avg = mean(V,2);
q1 = quantile(V,0.25,2);
q3 = quantile(V,0.75,2);
med = median(V,2);
dt = targets_dates(2:end);
ht = mean(HIT,2);


factors = load('../../../data/outputs/observable_factors.mat');
unobs = load('../../../data/outputs/statistical_factors.mat');
dates = factors.factors_dates;
names = factors.factors_names;
factors = factors.factors; % remove dates
dates = datetime(dates,'InputFormat','yyyy-MM');
dates = dates(2:end);
factors = factors(2:end,:);
qf = squeeze(unobs.S.QF(2:end,1,754));

% Create tables
TB = table(dt, med, avg, q1, q3, ht.*100,scale_var(avg),...
  'VariableNames',{'Date','Median','Average','Q1','Q3','HT','ScaledAvg'});

FAC = table(dates, scale_var(factors(:,1)), -scale_var(qf), scale_var(factors(:,6)), ...
    'VariableNames', {'Date','NFCI','QF','MUNC'});

% Export to CSV
writetable(TB, '../../../data/outputs/MacroVol.csv');
writetable(FAC, '../../../data/outputs/FactorTimeSeries.csv');

% Generate gnuplot recession shading (set object rect ... behind, drawn under grid)
usrec_raw = readtable('../../../data/inputs/stlouis_fed/USREC.csv');
usrec_raw.observation_date = datetime(usrec_raw.Date, 'InputFormat', 'yyyy-MM');
usrec_raw = usrec_raw(usrec_raw.observation_date >= datetime(1980,1,1), :);
rec_dates = usrec_raw.observation_date;
rec_vals  = usrec_raw.USREC;

fid = fopen('../../00_utils/Figures/recession_objects.gp', 'w');
obj_idx = 1;
in_rec  = false;
rec_start = '';
for k = 1:length(rec_vals)
    if rec_vals(k) == 1 && ~in_rec
        rec_start = datestr(rec_dates(k), 'yyyy-mm');
        in_rec = true;
    elseif rec_vals(k) == 0 && in_rec
        rec_end = datestr(rec_dates(k), 'yyyy-mm');
        fprintf(fid, 'set object %d rect from "%s", graph 0 to "%s", graph 1 fc rgb "#e8e8e8" fs solid noborder behind\n', ...
            obj_idx, rec_start, rec_end);
        obj_idx = obj_idx + 1;
        in_rec  = false;
    end
end
if in_rec
    rec_end = datestr(rec_dates(end), 'yyyy-mm');
    fprintf(fid, 'set object %d rect from "%s", graph 0 to "%s", graph 1 fc rgb "#e8e8e8" fs solid noborder behind\n', ...
        obj_idx, rec_start, rec_end);
end
fclose(fid);
