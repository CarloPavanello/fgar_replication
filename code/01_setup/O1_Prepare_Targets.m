%% Housekeeping
clear
close all
clc
rng(12) % Set seed
H = [1 3 6 12];

%% Load data
% fred
load('../../data/outputs/fred_md.mat');
targets_dates = fred_dates;
targets_names = fred_names;

[T,n] = size(fred);
targets = nan(T,n,numel(H));

for h = 1:numel(H)
  for i = 1:n
    for s = H(h):T
      targets(s-(H(h)-1),i,h) = mean(fred(s-(H(h)-1):s,i))';
    end
  end
end

%save
save('../../data/outputs/prediction_targets.mat','targets_dates','targets_names','targets');

