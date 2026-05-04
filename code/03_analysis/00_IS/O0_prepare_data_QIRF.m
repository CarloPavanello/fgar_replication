%% Housekeeping
clear
close all
clc

addpath('../../00_utils/QR')
addpath('../../00_utils/LS')

%% Load variables
% observable factors
load('../../../data/outputs/observable_factors.mat');
% averaged fred md series
load('../../../data/outputs/prediction_targets.mat');
policy_relevant = [find(targets_names == 'W875RX1'),...
  find(targets_names == 'INDPRO'),find(targets_names == 'UNRATE'),...
  find(targets_names == 'WPSFD49207'),find(targets_names == 'WPSFD49207_up'),...
  find(targets_names == 'CPIAUCSL'),find(targets_names == 'CPIAUCSL_up')];

% All Emp. (Payroll employments), Housing Starts

Q = [0.1:0.1:0.9];
factors = factors(1:end-1,3); % munc
factors = (factors - mean(factors))./std(factors);

for i = 1:numel(policy_relevant)
  target = targets(2:end,policy_relevant(i),4); 
  if policy_relevant(i) == 24     
    target = -targets(2:end,policy_relevant(i),4); 
  else
    target = target.*100;
  end
  target = target.*12;
  lag_y = squeeze(targets(1:end-1,policy_relevant(i),1));

  %% Estimate quantiles with QR
  for tau = 1:numel(Q)
    y = target(1:end-12+1);
    X = [ ones(numel(y),1) , lag_y(1:end-12+1) , factors(1:end-12+1) ];
    X_shock = [1 median(lag_y) quantile(factors(1:end-12+1),0.95)];
    X_noshock = [1 median(lag_y) quantile(factors(1:end-12+1),0.5) ];
    % QR
    BETAS = rq(X,y,Q(tau));
    QR_IR(i,tau) = (X_shock * BETAS) - (X_noshock * BETAS);
    
    % LS
    X_scale = X(:,[1 3]);
    [coef, bint] = regress(y, X);
    delta = X_shock(3) - X_noshock(3);
    OLS(i,tau) = coef(3) * delta;
    if tau == 1
      OLS_lo(i) = bint(3,1) * delta;
      OLS_hi(i) = bint(3,2) * delta;
    end
    [loc_pars,scale_pars,yhat,trend,vt,tv,zt]= lsmem_garch(y,X,X_scale,[],12); % 12 months ahead
    shock_idx = knnsearch(X,X_shock,"K",50);
    baseline_idx = knnsearch(X,X_noshock,"K",50);
    ls_shock = (X_shock*loc_pars + exp(X_shock(:,[1 3])*scale_pars(3:end)').*mean(sqrt(vt(shock_idx))).*quantile(zt,Q(tau)));
    ls_noshock = (X_noshock*loc_pars + exp(X_noshock(:,[1 3])*scale_pars(3:end)').*mean(sqrt(vt(baseline_idx))).*quantile(zt,Q(tau)));
    LS_IR(i,tau) = ls_shock - ls_noshock;

  end
end

%% IR
fig1 = figure;
set(fig1, 'Units', 'pixels');
set(fig1, 'Position', [100, 100, 1800, 600]);  % [x, y, width, height]

% Tiled layout
t = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
title(t, '', 'FontSize', 16, 'FontWeight', 'bold')

nexttile;
hold on
bm=plot(Q,QR_IR(1,:), 'Color', [0 0 1]);
ir=plot(Q,LS_IR(1,:), 'Color', [0.85 0.33 0.10]);
avg_ls = plot(Q,OLS(1,:), 'Color',[0 0 0],'LineWidth',2);
hold off
box on;grid on;
legend({'QR','LS','OLS'},'Location','best')
title('RPI');

nexttile;
hold on
bm=plot(Q,QR_IR(2,:), 'Color', [0 0 1]);
ir=plot(Q,LS_IR(2,:), 'Color', [0.85 0.33 0.10]);
avg_ls = plot(Q,OLS(2,:), 'Color',[0 0 0],'LineWidth',2);
yline(0, 'k--', 'LineWidth', 1.5)
hold off
box on;grid on;
legend({'QR','LS','OLS'},'Location','best')
title('INDPRO');

nexttile;
hold on
bm=plot(Q,QR_IR(3,:), 'Color', [0 0 1]);
ir=plot(Q,LS_IR(3,:), 'Color', [0.85 0.33 0.10]);
avg_ls = plot(Q,OLS(3,:), 'Color',[0 0 0],'LineWidth',2);
yline(0, 'k--', 'LineWidth', 1.5)
hold off
box on;grid on;
legend({'QR','LS','OLS'},'Location','best')
title('UNRATE');

nexttile;
hold on
bm=plot(Q,QR_IR(6,:), 'Color', [0 0 1]);
ir=plot(Q,LS_IR(6,:), 'Color', [0.85 0.33 0.10]);
avg_ls = plot(Q,OLS(6,:), 'Color',[0 0 0],'LineWidth',2);
yline(0, 'k--', 'LineWidth', 1.5)
hold off
box on;grid on;
legend({'QR','LS','OLS'},'Location','best')
title('CPI');

writematrix([QR_IR' Q'],'../../../data/outputs/QR_IR.csv')
writematrix([LS_IR' Q'],'../../../data/outputs/LS_IR.csv')
writematrix([OLS' Q'],'../../../data/outputs/OLS_IR.csv')
OLS_lo_mat = repmat(OLS_lo(:)', numel(Q), 1);
OLS_hi_mat = repmat(OLS_hi(:)', numel(Q), 1);
writematrix([OLS_lo_mat OLS_hi_mat Q'], '../../../data/outputs/OLS_CI.csv')

% export to csvs for propert pictures
% 
% 
% 
% 
% %% Figure 3: Impulse Responses
% 
% fig3 = figure;
% set(fig3, 'Units', 'pixels');
% set(fig3, 'Position', [100, 100, 1800, 600]);  % [x, y, width, height]
% 
% % Tiled layout
% t = tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
% title(t, 'INDPRO', 'FontSize', 16, 'FontWeight', 'bold')
% 
% 
% % ---- First subplot ----
% nexttile;
% hold on
% bm=plot(Q,QR_IR(1,:), 'Color', [0 0 1]);
% ir=plot(Q,LS_IR(1,:), 'Color', [0.85 0.33 0.10],'LineStyle','--');
% ols=plot(Q,OLS(1,:), 'Color', [0 0 0],'LineStyle','-');
% hold off
% box on;grid on;
% legend({'QR','LS','OLS'},'Location','best')
% title('h=1');
% 
% % ---- Second subplot ----
% nexttile;
% hold on
% bm=plot(Q,QR_IR(4,:), 'Color', [0 0 1]);
% ir=plot(Q,LS_IR(4,:), 'Color', [0.85 0.33 0.10],'LineStyle','--');
% ols=plot(Q,OLS(4,:), 'Color', [0 0 0],'LineStyle','-');
% ylim([-1 1.5])
% hold off
% box on;grid on;
% %legend({'QR','LS','OLS'},'Location','best')
% title('h=12');
% 
% % Export with padding
% exportgraphics(fig3,'../../img/INDPRO_QRLS_TAU.pdf', ...
%     'Resolution', 300);
% 
% 
% 
% 
% %% Figure 1: Quantiles
% fig1 = figure;
% set(fig1, 'Units', 'pixels');
% set(fig1, 'Position', [100, 100, 1500, 900]);  % [x, y, width, height]
% 
% % Tiled layout
% t = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
% title(t, 'INDPRO, QR/LS + MUNC', 'FontSize', 16, 'FontWeight', 'bold')
% 
% x = factors_dates(1:end-1);
% ymin =-0.08;
% ymax = 0.08;
% yticks_vals = ymin:0.02:ymax;
% 
% % ---- First subplot ----
% nexttile;
% hold on
% plot(x, QR(:,[1 3 end],1), 'Color', [0 0 1])
% plot(x, LS(:,[1 3 end],1), 'Color', [0.85 0.33 0.10])
% hold off
% title('h=1');
% grid on; box on;
% ylim([ymin ymax]); yticks(yticks_vals);
% 
% % ---- Second subplot ----
% nexttile;
% hold on
% plot(x, QR(:,[1 3 end],2), 'Color', [0 0 1])
% plot(x, LS(:,[1 3 end],2), 'Color', [0.85 0.33 0.10])
% hold off
% title('h=3');
% grid on; box on;
% ylim([ymin ymax]); yticks(yticks_vals);
% 
% % ---- Third subplot ----
% nexttile;
% hold on
% plot(x, QR(:,[1 3 end],3), 'Color', [0 0 1])
% plot(x, LS(:,[1 3 end],3), 'Color', [0.85 0.33 0.10])
% hold off
% title('h=6');
% grid on; box on;
% ylim([ymin ymax]); yticks(yticks_vals);
% 
% % ---- Fourth subplot with legend ----
% nexttile;
% hold on
% q  = plot(x, QR(:,[1 3 end],4), 'Color', [0 0 1]);
% ls = plot(x, LS(:,[1 3 end],4), 'Color', [0.85 0.33 0.10]);
% hold off
% title('h=12');
% grid on; box on;
% ylim([ymin ymax]); yticks(yticks_vals);
% 
% % Only one legend for representative lines
% legend([q(1), ls(1)], {'QR','LS'}, 'Location', 'best');
% 
% % Adjust layout margins so titles/labels aren’t cut
% t.OuterPosition = [0.07 0.07 0.86 0.86];
% set(fig1, 'PaperUnits', 'inches');
% set(fig1, 'PaperSize', [8.5 11]);  % A4 size
% set(fig1, 'PaperPosition', [0.5 0.5 7.5 10]);  % Add 0.5 inch padding on all sides
% 
% % Export with padding
% exportgraphics(fig1,'../../img/INDPRO_Quantiles.pdf', ...
%     'Resolution', 300);
% 
