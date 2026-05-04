%% Housekeeping
clear
close all
clc

%% Load paths
addpath('../../data/')
addpath('../00_utils/FRED_MD')

%% Load data
% Load data from CSV file
fredmd = importdata('../../data/inputs/stlouis_fed/2025-08-MD.csv',',');

% Variable names
series = fredmd.textdata(1,2:end); % S&P: indust disappeared

% Transformation numbers
tcode=fredmd.data(1,:);

% Raw data
rawdata = fredmd.data(2:end,:);

% Transform raw data to be stationary using auxiliary function
yt = prepare_missing(rawdata, tcode);

% Remove some series
drop = {'ACOGNO','ANDENOx','TWEXAFEGSMTHx','UMCSENTx',...
    'M1SL','M2SL','M2REAL','BOGMBASE','TOTRESNS','NONBORRES',... %monetary base
    'FEDFUNDS','CP3Mx','TB3MS','TB6MS','GS1','GS5','GS10','AAA','BAA','COMPAPFFx',... %interest rates
    'TB3SMFFM','TB6SMFFM','T1YFFM','T5YFFM','T10YFFM','AAAFFM','BAAFFM'}; % 27 variables
yt = yt(:, ~ismember(series,drop));
series = series(:, ~ismember(series,drop));

% Reduce sample to usable dates: 
% (i) remove first 42 months because vix is missing before,
% (ii) remove the last 3 rows because some series take longer to update.
% Find the starting point: delete first missing obs for all series

% select the series with the maxium number of nan (it is VIX)
[nmaxnans, maxnanidx] = max(sum(isnan(yt)));
% drop the nmaxnans from the beginning of all the series
yt = yt(nmaxnans+1:(end-3),:); %drop first nmaxnans obs and last 3

% Dates
dates = fredmd.textdata(3:end,1);
dates = dates((nmaxnans+1):(end-3),:); %drop first nmaxnans obs and last 3
dates = datetime(dates,'InputFormat','MM/dd/yyyy','Format','yyyy-MM');

% Rotate some series so that high is bad.
to_rotate={'UNRATE','UEMPMEAN','UEMPLT5','UEMP5TO14','UEMP15OV','UEMP15T26','UEMP27OV',...
    'CLAIMSx','EXUSUKx','VIXCLSx'}; 

yt(:,ismember(series,to_rotate)) = -1*yt(:,ismember(series,to_rotate));

% Variables with two-sided risk (price variables)
ts_series = {'WPSFD49207','WPSFD49502','WPSID61','WPSID62','OILPRICEx','PPICMM',...
    'CPIAUCSL','CPIAPPSL','CPITRNSL','CPIMEDSL','CUSR0000SAC','CUSR0000SAD',...
    'CUSR0000SAS','CPIULFSL','CUSR0000SA0L2','CUSR0000SA0L5','PCEPI'...
    ,'DPCERA3M086SBEA','DDURRG3M086SBEA','DNDGRG3M086SBEA','DSERRG3M086SBEA'}; % 21 variables

ts_names = series(ismember(series,ts_series));
dt = [yt -1*yt(:,ismember(series,ts_series))];
series = [series strcat(ts_names,"_up")]';

% Remove outliers using auxiliary function remove_outliers(); see function
% or readme.txt for definition of outliers
[data_nan, n] = remove_outliers(dt);

% fill the NaN values with the previous value
data = fillmissing(data_nan,'previous');

% dates
fred_dates = dates;
% names
fred_names = series;
% data
fred = data;

% save
save("../../data/outputs/fred_md.mat","fred_dates","fred_names","fred")
