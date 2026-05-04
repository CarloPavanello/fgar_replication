%% Housekeeping
clear
close all
clc

addpath('../../00_utils/Tables')

%% load stats

% select the type of model
sample = ''; % '' '_PR'

if strcmp(sample, '')
    sample_name = 'FRED-MD';
else
    sample_name = 'Policy';
end

load(sprintf('../../../data/outputs/stats_1_fac%s.mat',sample));

if strcmp(sample, '_PR')
 stats = stats_pr;
end


%% load MCS information

% horizons
H = [1 3 6 12];

load('../../../data/outputs/result_MCS.mat');

for h = 1:numel(H)
    % dummy for chosen models
    result_MCS{h}.chosen = double(result_MCS{h}.MCS_p_val >= 0.10);
end

%% latex code for the table

% col names 
col_label_1 = {sprintf('%s',sample_name),'QR','LSR'};
col_label_2 = {'$h$','Class','Model','$\overline{TLG}$','W','$\overline{H}$','$DQU$','$DQC$','$MCS$','$\overline{TLG}$','W','$\overline{H}$','$DQU$','$DQC$','$MCS$'};

% row names
row_label_1 = {'Bench','','Fin','','','','','Macro','','','','Stat','','','Text','',''};
% how many rows with that name
n_row_1     = {2,'',5,'','','','',3,'','',3,'','',3,'',''};
row_label_2 = {'HIST','AR',...
               'NFCI','EBP','FUNC','VIX','CISS',...
               'MUNC','HPI','CTG',...
               'PC1','QF1','PCF1',...
               'WUI','GPR','EPU'};
n_models = length(row_label_2);

% begin the creation of the file
file = fopen(sprintf('../../../paper/tables/oos_1_fac%s.tex',sample),'w');

% set the col width
fprintf( file , '\\newcolumntype{C}{>{\\centering\\arraybackslash}p{0.6cm}} \n');
fprintf( file , '\\newcolumntype{s}{>{\\centering\\arraybackslash}p{0.2cm}} \n');

%begin the tabular
fprintf( file , '\\begin{tabular}{lllCsCCCCCsCCCC} \n');

%separating line
fprintf( file , '\\cmidrule{1-15} \n');

%col labels 1
fprintf(file, '\\multicolumn{3}{c}{%s} & \\multicolumn{6}{c}{%s} & \\multicolumn{6}{c}{%s} \\\\ \n',col_label_1{1},col_label_1{2},col_label_1{3});

%separating line
fprintf(file, '\\cmidrule{1-3} \\cmidrule(l){4-9} \\cmidrule(l){10-15}\n');

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
fprintf(file, '\\cmidrule{1-3} \\cmidrule(l){4-9} \\cmidrule(l){10-15}\n');

% HORIZONS
for h = 1:numel(H)

    % Compute the max avg_bm_tick_loss_gain across all j for this h
    [max_bm_tick_loss_gain,idx_max_gain] = max(stats.avg_bm_tick_loss_gain(h, :));
    % Compute the maximum win_counts across all j for this h
    [max_win_counts,idx_max_wins] = max(cell2mat(stats.win_counts(h, :)));
    
    for j = 1:n_models
        j_qr = j;
        j_ls = j+(n_models-1); % the first j_ls gets you the last QR specification (undesirable), but it is never used

        % bold tick loss gain
        bm_tl_gain_qr = bolder_gains(stats.avg_bm_tick_loss_gain(h,j_qr),idx_max_gain == j_qr);
        bm_tl_gain_ls = bolder_gains(stats.avg_bm_tick_loss_gain(h,j_ls),idx_max_gain == j_ls);
        % bold wins
        wins_qr = bolder_wins(stats.win_counts{h}(j_qr),idx_max_wins == j_qr);
        wins_ls = bolder_wins(stats.win_counts{h}(j_ls),idx_max_wins == j_ls);    
        % create checks for MCS
        
        % repeated part for fprinf
        rep_cols = '& %s & %s & %0.1f & %0.1f & %0.1f & %s & %s & %s & %0.1f & %0.1f & %0.1f & %s';

        %first row
        if j == 1
            fprintf(file, ['\\multirow{%d}{*}{%d} & \\multirow{%d}{*}{%s} & %s ' rep_cols ' \\\\ \n']...
                ,n_models,H(h),...
                n_row_1{j},row_label_1{j},...
                row_label_2{j},...       
                bm_tl_gain_qr, wins_qr, stats.avg_n_hits{h,j}*100, stats.DQ_unc_share_acc{h,j}*100, stats.DQ_ar4_share_acc{h,j}*100, checkmark(result_MCS{h}{row_label_2{j},'chosen'}),...
                bm_tl_gain_qr, wins_qr, stats.avg_n_hits{h,j}*100, stats.DQ_unc_share_acc{h,j}*100, stats.DQ_ar4_share_acc{h,j}*100, checkmark(result_MCS{h}{row_label_2{j},'chosen'}));
        %last rows in the class of models
        elseif j == 2 || j == 7 || j == 10 || j == 13  
            fprintf(file, ['& & %s ' rep_cols ' \\\\ [1.5mm] \n']...
                ,row_label_2{j},...
                bm_tl_gain_qr, wins_qr, stats.avg_n_hits{h,j_qr}*100, stats.DQ_unc_share_acc{h,j_qr}*100, stats.DQ_ar4_share_acc{h,j_qr}*100, checkmark(result_MCS{h}{row_label_2{j} + "_qr",'chosen'}),...
                bm_tl_gain_ls, wins_ls, stats.avg_n_hits{h,j_ls}*100, stats.DQ_unc_share_acc{h,j_ls}*100, stats.DQ_ar4_share_acc{h,j_ls}*100, checkmark(result_MCS{h}{row_label_2{j} + "_ls",'chosen'}));
        %first rows n the class of models
        elseif j == 3 || j == 8 || j == 11 || j == 14
            fprintf(file, ['& \\multirow{%d}{*}{%s} & %s ' rep_cols ' \\\\ \n']...
                ,n_row_1{j},row_label_1{j},...
                row_label_2{j},...
                bm_tl_gain_qr, wins_qr, stats.avg_n_hits{h,j_qr}*100, stats.DQ_unc_share_acc{h,j_qr}*100, stats.DQ_ar4_share_acc{h,j_qr}*100, checkmark(result_MCS{h}{row_label_2{j} + "_qr",'chosen'}),...
                bm_tl_gain_ls, wins_ls, stats.avg_n_hits{h,j_ls}*100, stats.DQ_unc_share_acc{h,j_ls}*100, stats.DQ_ar4_share_acc{h,j_ls}*100, checkmark(result_MCS{h}{row_label_2{j} + "_ls",'chosen'}));
        %last row
        else
            fprintf(file, ['& & %s ' rep_cols ' \\\\ \n']...
                ,row_label_2{j},...
                bm_tl_gain_qr, wins_qr, stats.avg_n_hits{h,j_qr}*100, stats.DQ_unc_share_acc{h,j_qr}*100, stats.DQ_ar4_share_acc{h,j_qr}*100, checkmark(result_MCS{h}{row_label_2{j} + "_qr",'chosen'}),...
                bm_tl_gain_ls, wins_ls, stats.avg_n_hits{h,j_ls}*100, stats.DQ_unc_share_acc{h,j_ls}*100, stats.DQ_ar4_share_acc{h,j_ls}*100, checkmark(result_MCS{h}{row_label_2{j} + "_ls",'chosen'}));
        end
        
    end

    % separating line
    if h == numel(H)
        fprintf(file, '\\cmidrule{1-15} \n');
    else
        %separating line
        fprintf(file, '\\cmidrule{1-3} \\cmidrule(l){4-9} \\cmidrule(l){10-15}\n');
    end

end

fprintf( file , '\\end{tabular}\n' );
fclose(file);
        