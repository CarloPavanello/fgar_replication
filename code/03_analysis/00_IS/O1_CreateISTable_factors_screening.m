%% Housekeeping
clear
close all
clc

addpath('../../00_utils/Tables')

%% load data
load('../../../data/outputs/QR_IS_significance.mat');

%% prepare data
H = [1 3 6 12];

% labels
[prettyFactors, prettyTypes] = categorize_factors(factors_names);

%get the significance share
for h = 1:numel(H)
    share_significance(:,h) = mean(squeeze(significance_CI(:,h,:)));
end

avg_significance = mean(share_significance,2);

%reorder everything in descending order
[~, sortedIdx] = sort(avg_significance, 'descend');

%use the index on the objects of interest
prettyFactors = prettyFactors(sortedIdx);
prettyTypes = prettyTypes(sortedIdx);
share_significance = share_significance(sortedIdx,:);

%% table

% begin the creation of the file
file = fopen('../../../paper/tables/factors_screening.tex','w');

% set the col width
fprintf( file , '\\newcolumntype{C}{>{\\centering\\arraybackslash}p{0.5cm}} \n');

%begin the tabular
fprintf( file , '\\begin{tabular}{llCCCC}\n');

% separating line
fprintf( file , '\\cmidrule(l){3-6} \n');

% heading
fprintf( file , '\\multicolumn{2}{c}{} & \\multicolumn{4}{c}{Horizon} \\\\ \n');
fprintf( file , '\\cmidrule{1-2} \\cmidrule(l){3-6} \n');
fprintf( file , 'Model & Class & 1 & 3 & 6 & 12\\\\ \n');

% separating line
fprintf( file , '\\cmidrule{1-2} \\cmidrule(l){3-6} \n');

% loop to generate the table
for j = 1:length(prettyFactors)
       
    fprintf(file, '%s & %s & %0.1f & %0.1f & %0.1f & %0.1f \\\\ \n',...
        prettyFactors(j), prettyTypes(j),...
        share_significance(j,1)*100, share_significance(j,2)*100,... 
        share_significance(j,3)*100, share_significance(j,4)*100);

end

% separating line
fprintf( file , '\\cmidrule(l){1-6} \n');

% end tablular and close file
fprintf( file , '\\end{tabular} \n' );
fclose(file);
