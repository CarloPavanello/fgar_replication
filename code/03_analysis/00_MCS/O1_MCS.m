%% Housekeeping
clear
close all
clc

addpath('../../00_utils/MCS')

%% Load data
load('../../../data/outputs/stats_MCS.mat');

%% MCS
H = [1 3 6 12];

tic;   % start timer

for h = 1:numel(H)

    % prepare table
    Table_MCS{h} = array2table(stats.wavg_rho{h},'VariableNames',names_reordered);
    % Apply the MCS function
    result_MCS{h} = sortrows(estMCS(Table_MCS{h},5000,4),"MCS_p_val","descend");

end

elapsedTime = toc;   % end timer and return elapsed time
fprintf('Elapsed time: %.4f seconds\n', elapsedTime);

save('../../../data/outputs/result_MCS.mat','result_MCS')


