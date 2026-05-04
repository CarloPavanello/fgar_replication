%% Housekeeping
clear
close all
clc

addpath('../../00_utils/Tables')

%% load stats
load('../../../data/outputs/stats_mix.mat');
specification_selection = ["HIST"; specification_selection];

% labels
[prettyFactors, prettyTypes] = categorize_factors(specification_selection);
prettyTypes = keep_first(prettyTypes);

%% load MCS information

% horizons
H = [1 3 6 12];

load('../../../data/outputs/result_MCS.mat');

for h = 1:numel(H)
    % dummy for chosen models
    result_MCS{h}.chosen = double(result_MCS{h}.MCS_p_val >= 0.10);
end

%% latex code for the table

%col names
col_label_1 = {'FRED-MD','QR','LSR'};
col_label_2 =   {'$h$','Class','Model','$\overline{TLG}$','$\overline{H}$','$DQU$','$DQC$','$MCS$','$\overline{TLG}$','$\overline{H}$','$DQU$','$DQC$','$MCS$'};

%row names
row_label_1 = prettyTypes;

%how many rows with that name
row_label_2 = prettyFactors;
n_models= length(row_label_2);

%begin the creation of the file
file = fopen('../../../paper/tables/oos_mix_fac.tex','w');

% set the col width
fprintf( file , '\\newcolumntype{C}{>{\\centering\\arraybackslash}p{0.6cm}} \n');

%begin the tabular
fprintf( file , '\\begin{tabular}{lllCCCCCCCCCC} \n');

%separating line
fprintf( file , '\\cmidrule{1-13} \n');

%col labels 1
fprintf(file, '\\multicolumn{3}{c}{%s} & \\multicolumn{5}{c}{%s} & \\multicolumn{5}{c}{%s} \\\\ \n',col_label_1{1},col_label_1{2},col_label_1{3});

%separating line
fprintf(file, '\\cmidrule{1-3} \\cmidrule(l){4-8} \\cmidrule(l){9-13}\n');

%col labels 2
for i=1:length(col_label_2)
    if i == 1
        fprintf( file , '{%s}', col_label_2{i});
    elseif i == length(col_label_2)
        fprintf( file , '& {%s} \\\\ \n', col_label_2{i});
    else
       fprintf( file , '& {%s}', col_label_2{i});
    end
end 

%separating line
fprintf(file, '\\cmidrule{1-3} \\cmidrule(l){4-8} \\cmidrule(l){9-13}\n');

% HORIZONS
for h = 1:numel(H)

    % Compute the max avg_bm_tick_loss_gain across all j for this h
    [max_bm_tick_loss_gain,idx_max_gain] = max(stats.avg_bm_tick_loss_gain(h, :));

    for j = 1:n_models
        j_qr = j;
        j_ls = j+(n_models-1);

        % bold tick loss gain
        bm_tl_gain_qr = bolder_gains(stats.avg_bm_tick_loss_gain(h,j_qr),idx_max_gain == j_qr);
        bm_tl_gain_ls = bolder_gains(stats.avg_bm_tick_loss_gain(h,j_ls),idx_max_gain == j_ls);

        % repeated part for fprinf
        rep_cols = ' & %s & %0.1f & %0.1f & %0.1f & %s & %s & %0.1f & %0.1f & %0.1f & %s';

        %first row in the class of models
        if j == 1 
            fprintf(file, ['\\multirow{%d}{*}{%d} & %s & %s' rep_cols '\\\\ \n'],...
                length(row_label_2),H(h),...
                row_label_1{j},...
                row_label_2{j},...
                bm_tl_gain_qr, stats.avg_n_hits{h,j}*100, stats.DQ_unc_share_acc{h,j}*100, stats.DQ_ar4_share_acc{h,j}*100, checkmark(result_MCS{h}{specification_selection{j},'chosen'}),...
                bm_tl_gain_qr, stats.avg_n_hits{h,j}*100, stats.DQ_unc_share_acc{h,j}*100, stats.DQ_ar4_share_acc{h,j}*100, checkmark(result_MCS{h}{specification_selection{j},'chosen'}));
        
        %last row in the class of models        
        elseif j == n_models
            fprintf(file, ['& %s & %s' rep_cols '\\\\ \n'],...
                row_label_1{j}, ...
                row_label_2{j},...
                bm_tl_gain_qr, stats.avg_n_hits{h,j_qr}*100, stats.DQ_unc_share_acc{h,j_qr}*100, stats.DQ_ar4_share_acc{h,j_qr}*100, checkmark(result_MCS{h}{specification_selection{j} + "_qr",'chosen'}),...
                bm_tl_gain_ls, stats.avg_n_hits{h,j_ls}*100, stats.DQ_unc_share_acc{h,j_ls}*100, stats.DQ_ar4_share_acc{h,j_ls}*100, checkmark(result_MCS{h}{specification_selection{j} + "_ls",'chosen'}));
        
        else
            fprintf(file, ['& %s & %s' rep_cols '\\\\ \n'],...
                row_label_1{j}, ...
                row_label_2{j}, ...
                bm_tl_gain_qr, stats.avg_n_hits{h,j_qr}*100, stats.DQ_unc_share_acc{h,j_qr}*100, stats.DQ_ar4_share_acc{h,j_qr}*100, checkmark(result_MCS{h}{specification_selection{j} + "_qr",'chosen'}),...
                bm_tl_gain_ls, stats.avg_n_hits{h,j_ls}*100, stats.DQ_unc_share_acc{h,j_ls}*100, stats.DQ_ar4_share_acc{h,j_ls}*100, checkmark(result_MCS{h}{specification_selection{j} + "_ls",'chosen'}));

        end        
    end

    % separating line
    if h == numel(H)
        fprintf( file , '\\toprule \n');
    else
        fprintf(file, '\\cmidrule{1-3} \\cmidrule(l){4-8} \\cmidrule(l){9-13}\n');
    end

end

fprintf( file , '\\end{tabular}\n' );
fclose(file);