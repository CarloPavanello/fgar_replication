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

load(sprintf('../../../data/outputs/stats_is_1_fac%s.mat',sample));

if strcmp(sample, '_PR')
 stats = stats_pr;
end

%% latex code for the table

% horizons
H = [1 3 6 12];

%col names
col_label_1 = {sprintf('%s',sample_name), '$\overline{TLG}$'};

col_label_2 = {'$h$','Class','Model','QR','LR','SR','LSR'};

%row names`
row_label_1 = {'Bench','','Fin','','','','','Macro','','','','Stat','','','Text','',''};
%how many rows with that name
n_row_1     = {2,'',5,'','','','',3,'','',3,'','',3,'',''};
row_label_2 = {'HIST','AR',...
               'NFCI','EBP','FUNC','VIX','CISS',...
               'MUNC','HPI','CTG',...
               'PC1','QF1','PCF1',...
               'WUI','GPR','EPU'};
n_models = length(row_label_2);

% begin the creation of the file
file = fopen(sprintf('../../../paper/tables/models_screening%s.tex',sample),'w');

% set the col width
fprintf( file , '\\newcolumntype{C}{>{\\centering\\arraybackslash}p{0.6cm}} \n');

%begin the tabular
fprintf( file , '\\begin{tabular}{lllCCCC} \n');

%separating line
fprintf( file , '\\cmidrule{1-7} \n');

%col labels 1
fprintf(file, '\\multicolumn{3}{c}{%s} & \\multicolumn{4}{c}{%s} \\\\ \n',col_label_1{1},col_label_1{2});

%separating line
fprintf(file, '\\cmidrule{1-3} \\cmidrule(l){4-7}\n');

%col labels 2
fprintf( file , '{%s} & {%s} & {%s} & {%s} & {%s} & {%s} & {%s} \\\\ \n', col_label_2{1},col_label_2{2},col_label_2{3},col_label_2{4},col_label_2{5},col_label_2{6},col_label_2{7});

% separating line
fprintf(file, '\\cmidrule{1-3} \\cmidrule(l){4-7}\n');

% HORIZONS
for h = 1:numel(H)

    % Compute the max avg_bm_tick_loss_gain across all j for this h
    [max_bm_tick_loss_gain,idx_max_gain] = max(stats.avg_bm_tick_loss_gain(h, :));
    
    for j = 1:n_models
        j_qr = j;
        j_l  = j+(n_models-1); % the first j_ls, j_l, j_s are never used (first row in the table is HIST)
        j_s  = j+(2*n_models-2);
        j_ls = j+(3*n_models-3);

        % bold tick loss gain
        bm_tl_gain_qr = bolder_gains(stats.avg_bm_tick_loss_gain(h,j_qr),idx_max_gain == j_qr);
        bm_tl_gain_l  = bolder_gains(stats.avg_bm_tick_loss_gain(h,j_l),idx_max_gain == j_l);
        bm_tl_gain_s  = bolder_gains(stats.avg_bm_tick_loss_gain(h,j_s),idx_max_gain == j_s);
        bm_tl_gain_ls = bolder_gains(stats.avg_bm_tick_loss_gain(h,j_ls),idx_max_gain == j_ls);

        %first row
        if j == 1
            fprintf(file, '\\multirow{%d}{*}{%d} & \\multirow{%d}{*}{%s} & %s & %s & %s & %s & %s \\\\ \n'...
                ,n_models,H(h),...
                n_row_1{j},row_label_1{j},...
                row_label_2{j},...       
                bm_tl_gain_qr, bm_tl_gain_qr, bm_tl_gain_qr, bm_tl_gain_qr);
        %last rows in the class of models
        elseif j == 2 || j == 7 || j == 10 || j == 13  
            fprintf(file, '& & %s & %s & %s & %s & %s\\\\ [1.5mm] \n'...
                ,row_label_2{j},...
                bm_tl_gain_qr, bm_tl_gain_l, bm_tl_gain_s, bm_tl_gain_ls);
        %first rows in the class of models
        elseif j == 3 || j == 8 || j == 11 || j == 14
            fprintf(file, '& \\multirow{%d}{*}{%s} & %s & %s & %s & %s & %s \\\\ \n'...
                ,n_row_1{j},row_label_1{j}, ...
                row_label_2{j}, ...
                bm_tl_gain_qr, bm_tl_gain_l, bm_tl_gain_s, bm_tl_gain_ls);
        %last row
        else
            fprintf(file, '& & %s & %s & %s & %s & %s \\\\ \n'...
                ,row_label_2{j},...
                bm_tl_gain_qr, bm_tl_gain_l, bm_tl_gain_s, bm_tl_gain_ls);
        end
    end

    % separating line
    if h == H(end)
        fprintf(file, '\\cmidrule{1-7} \n');
    else
        fprintf(file, '\\cmidrule{1-3} \\cmidrule(l){4-7}\n');
    end

end

fprintf( file , '\\end{tabular}\n' );
fclose(file);