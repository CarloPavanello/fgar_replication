%% Housekeeping
clear
close all
clc

addpath('../../00_utils/Tables')

%% Load data
load('../../../data/outputs/summary_MCS.mat');

%% latex code for the table

H = [1 3 6 12];

%begin the creation of the file
file = fopen('../../../paper/tables/MCS.tex','w');

% set the col width
fprintf( file , '\\newcolumntype{C}{>{\\centering\\arraybackslash}p{0.6cm}} \n');

%begin the tabular
fprintf( file , '\\begin{tabular}{lCCCCCCCC} \n' );

%separating line
% fprintf( file , '\\toprule\n');
fprintf(file, '\\cmidrule{2-9} \n');

% h
fprintf(file, ' & \\multicolumn{8}{c}{Horizon} \\\\ \n');

%partial separating line
fprintf(file, '\\cmidrule{2-9} \n');

% col labels horizon
fprintf(file, ' & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} \\\\ \n',H(1),H(2),H(3),H(4));

%partial separating line
fprintf(file, '\\cmidrule{2-3} \\cmidrule(l){4-5} \\cmidrule(l){6-7} \\cmidrule(l){8-9} \n');

% col labels share and TL
fprintf(file, ' & %s & TLG & %s & TLG & %s & TLG & %s & TLG\\\\ \n','$\%$','$\%$','$\%$','$\%$');

%separating line
% fprintf( file , '\\midrule \n');
fprintf(file, '\\cmidrule{1-1} \\cmidrule(l){2-3} \\cmidrule(l){4-5} \\cmidrule(l){6-7} \\cmidrule(l){8-9} \n');

%share of chosen specifications
row = reshape([summary_MCS.share_chosen; summary_MCS.best_gain_chosen], 1, []);   % interleave -> [a1 b1 a2 b2 a3 b3 a4 b4]
fmt = ['All', repmat(' & %0.1f', 1, numel(row)), ' \\\\ \n'];
fprintf(file, fmt, row);

%separating line
fprintf(file, '\\cmidrule{1-1} \\cmidrule(l){2-3} \\cmidrule(l){4-5} \\cmidrule(l){6-7} \\cmidrule(l){8-9} \n');

% Share QR models
row = reshape([summary_MCS.share_qr; summary_MCS.best_gain_qr], 1, []);
fmt = ['QR', repmat(' & %0.1f', 1, numel(row)), ' \\\\ \n'];
fprintf(file, fmt, row);

% Share LS models
row = reshape([summary_MCS.share_ls; summary_MCS.best_gain_ls], 1, []);
fmt = ['LSR', repmat(' & %0.1f', 1, numel(row)), ' \\\\ \n'];
fprintf(file, fmt, row);

% separating line
fprintf(file, '\\cmidrule{1-1} \\cmidrule(l){2-3} \\cmidrule(l){4-5} \\cmidrule(l){6-7} \\cmidrule(l){8-9} \n');

% 1 2 3 Factors
row = reshape([summary_MCS.share_1fac; summary_MCS.best_gain_1fac], 1, []);
fmt = ['1 Factor', repmat(' & %0.1f', 1, numel(row)), ' \\\\ \n'];
fprintf(file, fmt, row);

row = reshape([summary_MCS.share_2fac; summary_MCS.best_gain_2fac], 1, []);
fmt = ['2 Factors', repmat(' & %0.1f', 1, numel(row)), ' \\\\ \n'];
fprintf(file, fmt, row);

row = reshape([summary_MCS.share_3fac; summary_MCS.best_gain_3fac], 1, []);
fmt = ['3 Factors', repmat(' & %0.1f', 1, numel(row)), ' \\\\ \n'];
fprintf(file, fmt, row);

%separating line
fprintf(file, '\\cmidrule{1-1} \\cmidrule(l){2-3} \\cmidrule(l){4-5} \\cmidrule(l){6-7} \\cmidrule(l){8-9} \n');

% AR_qr, NFCI_qr, AR_ls

row = reshape([summary_MCS.nfci_qr_chosen; summary_MCS.nfci_qr_best_gain], 1, []);
fmt = ['QR NFCI', repmat(' & %s', 1, numel(row)), ' \\\\ \n'];
fprintf(file, fmt, row);

row = reshape([summary_MCS.nfci_ls_chosen; summary_MCS.nfci_ls_best_gain], 1, []);
fmt = ['LSR NFCI', repmat(' & %s', 1, numel(row)), ' \\\\ \n'];
fprintf(file, fmt, row);

row = reshape([summary_MCS.ar_qr_chosen; summary_MCS.ar_qr_best_gain], 1, []);
fmt = ['QAR(1)', repmat(' & %s', 1, numel(row)), ' \\\\ \n'];
fprintf(file, fmt, row);

row = reshape([summary_MCS.ar_ls_chosen; summary_MCS.ar_ls_best_gain], 1, []);
fmt = ['AR(1)-GARCH(1,1)', repmat(' & %s', 1, numel(row)), ' \\\\ \n'];
fprintf(file, fmt, row);

%separating line
fprintf( file , '\\cmidrule{1-9} \n');

fprintf( file , '\\end{tabular}\n' );
fclose(file);