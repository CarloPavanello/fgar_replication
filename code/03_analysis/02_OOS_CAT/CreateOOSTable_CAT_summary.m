%% Housekeeping
clear
close all
clc

%% Load the data
load('../../../data/outputs/stats_1_fac_CAT.mat');

%% Data Preparation

%horizons
H = [1 3 6 12];

% get the specification_names and remove from Stats_CAT
specification_names = Stats_CAT.specification_names;
Stats_CAT = rmfield(Stats_CAT, 'specification_names');    

% get field names
fn = string(fieldnames(Stats_CAT));

% allocate space
tl_gain_h = cell(numel(H),1);
win_idx = cell(numel(H),1);

for h = 1:numel(H)     
    for s = 1:numel(fn)
        % get the tick loss gains
        tl_gain_h{h}(:,s) = Stats_CAT.(fn(s)).avg_bm_tick_loss_gain(h,:)';
        % get the indexes for the winners
        [~,win_idx{h}(:,s)] = max(tl_gain_h{h}(:,s));
    end
end

%% latex code for the table

%begin the creation of the file
file = fopen('../../../paper/tables/CAT_summary.tex','w');

% set the col width
fprintf( file , '\\newcolumntype{C}{>{\\centering\\arraybackslash}p{0.6cm}} \n');

%begin the tabular
fprintf( file , '\\begin{tabular}{lllCCCCCCCCC}\n');

%separating line
% fprintf( file , '\\toprule\n');
fprintf( file , '\\cmidrule{1-12} \n');

%col labels
col_labels = {'$h$';'Class';'Model';'Output';'Labor';'Hous';'Ord Inv';'Credit';'Exch Rates';'Prices Down';'Prices Up';'Stocks'};;
line = strjoin(col_labels', ' & ');
fprintf(file, '%s \\\\ \n', line);

% row labels
row_labels_1 = strings(numel(specification_names), numel(H));          
row_labels_1(1, :) = string(H);         
row_labels_2 = ["Bench";"";"";"QR";"";"";"";"";"";"LSR";"";"";"";"";""];

% nuber of models for each model
idx    = find(strlength(row_labels_2) > 0);         % start of each block
counts = diff([idx; numel(row_labels_2) + 1]);      % run lengths incl. the label
labels = row_labels_2(idx);                              

% pick the three you want (robust to order)
n_bm = counts(labels == "Bench");
n_qr = counts(labels == "QR");
n_ls = counts(labels == "LSR");
n_specifications = n_bm + n_qr + n_ls;

%separating line
fprintf( file , '\\cmidrule{1-3} \\cmidrule(l){4-12} \n');

% HORIZONS
for h = 1:numel(H) 

    % round the tick loss gain
    tl_gain = round(tl_gain_h{h}, 1);

    % start with plain formatted strings 
    entries = string(compose('%.1f', tl_gain)); % 13x9 string array 

    % bold the selected entries
    [ri, cj] = ndgrid(1:size(tl_gain,1), 1:size(tl_gain,2));    
    mask = (ri == win_idx{h}(cj)); 
    entries(mask) = compose('\\textbf{%.1f}', tl_gain(mask));

    % get all the contendt for the table
    entries = [row_labels_1(:,h) row_labels_2 specification_names entries];

    for j = 1:size(entries,1)
        % first row
        if j == 1            
            fmt = '\\multirow{%d}{*}{%s} & \\multirow{%d}{*}{%s} & %s \\\\ \n';
            rowTail = strjoin(entries(j,3:12), ' & ');   % join last 10 columns once
            fprintf(file, fmt, ...
                n_specifications, entries(j,1), ...
                n_bm, entries(j,2), ...
                rowTail);        
        % first row in the model class
        elseif j == n_bm+1 || j == n_bm+n_qr+1              
            fmt = '& \\multirow{%d}{*}{%s} & %s \\\\ \n';
            rowTail = strjoin(entries(j,3:12), ' & ');
            fprintf(file, fmt, ...
                n_qr, entries(j,2), ...
                rowTail);
        % last row in the model class
        elseif j == n_bm || j == n_bm+n_qr             
            fmt = '& & %s \\\\ [1.5mm] \n';
            rowTail = strjoin(entries(j,3:12), ' & ');
            fprintf(file, fmt, ...
                rowTail);
        % central rows
        else 
            fmt = '& & %s \\\\ \n';
            rowTail = strjoin(entries(j,3:12), ' & ');
            fprintf(file, fmt, ...
                rowTail); 
        end
    end

    % separating line
    if h == length(H)
        fprintf( file , '\\cmidrule{1-12} \n');
    else
        fprintf( file , '\\cmidrule{1-3} \\cmidrule(l){4-12} \n');
    end

end

fprintf( file , '\\end{tabular}\n' );
fclose(file);