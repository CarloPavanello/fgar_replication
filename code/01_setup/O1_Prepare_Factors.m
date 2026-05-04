%% Housekeeping
clear
close all
clc


%% NFCI

%load fred
load('../../data/outputs/fred_md.mat');
%load nfci
nfci = importdata('../../data/inputs/factors_clean/nfci-data-series-csv.csv',',');

rawdata_nfci = nfci.data(:,1);
nfci_dates = nfci.textdata(2:end,1);
nfci_dates = datetime(nfci_dates,'InputFormat','MM/dd/yyyy');

% nfci = timetable(nfci_dates,rawdata_nfci,'VariableNames',{'NFCI'}); 

% Extract the month from serial date numbers
days_nfci = day(nfci_dates);
months_nfci = month(nfci_dates);
years_nfci = year(nfci_dates);

% NFCI monthly version
yyyymm_nfci = years_nfci*100 + months_nfci;
nfci_dmy = [days_nfci months_nfci years_nfci yyyymm_nfci rawdata_nfci];

nfci_dt = nan(length(unique(yyyymm_nfci)),5);
unique_ym = unique(yyyymm_nfci);

for i = 1:length(unique_ym)
  tmp = nfci_dmy(yyyymm_nfci == unique_ym(i),:);
  nfci_dt(i,1) = tmp(end,1); % days
  nfci_dt(i,2) = tmp(end,2); % months
  nfci_dt(i,3) = tmp(end,3); % years
  nfci_dt(i,4) = tmp(end,4); % yearmonth
  nfci_dt(i,5) = tmp(end,5); % lastweek
end

nfci_dates = datetime(nfci_dt(:,3),nfci_dt(:,2),1, 'Format','yyyy-MM'); 
nfci = timetable(nfci_dates,nfci_dt(:,5),'VariableNames',{'NFCI'}); % use last week

%dates for final dataset
dates = fred_dates;
%timetable
data = retime(nfci, dates, 'fillwithmissing');
data.Properties.DimensionNames{1} = 'dates';

%% EBP
ebp = importdata('../../data/inputs/factors_clean/ebp_csv.csv');
ebp_dates = datetime(ebp.textdata(2:end,1),'InputFormat','MM/dd/yyyy','Format','yyyy-MM');
ebp = timetable(ebp_dates,ebp.data,'VariableNames',{'EBP'});
data = synchronize(data,ebp);

%% FUNC
func_tbl = readtable('../../data/inputs/factors_clean/FinancialUncertaintyToCirculate.xlsx');
func_dates = func_tbl{:,1};
func_dates.Format = 'yyyy-MM';
func = timetable(func_dates, func_tbl{:,2}, 'VariableNames',{'FUNC'});
data = synchronize(data,func);

%% VIX
% change sign
vix = -fred(:, ismember(fred_names,"VIXCLSx"));
vix = timetable(dates, vix,'VariableNames',{'VIX'});
data = synchronize(data,vix);

%% CISS
ciss = importdata('../../data/inputs/factors_clean/ECB Data Portal_20250925120603 CISS.csv');
ciss_data = ciss.data;
ciss_dates = datetime(ciss.textdata(2:end,1),'InputFormat','MM/dd/yyyy','Format','yyyy-MM-dd');
days_ciss = day(ciss_dates);
months_ciss = month(ciss_dates);
years_ciss = year(ciss_dates);

% Create two monthly versions of ciss
yyyymm_ciss = years_ciss*100 + months_ciss;
ciss_dmy = [days_ciss months_ciss years_ciss yyyymm_ciss ciss_data];

ciss_dt = nan(length(unique(yyyymm_ciss)),5);
unique_ym = unique(yyyymm_ciss);

for i = 1:length(unique_ym)
  tmp = ciss_dmy(yyyymm_ciss == unique_ym(i),:);
  ciss_dt(i,1) = tmp(end,1); % days
  ciss_dt(i,2) = tmp(end,2); % months
  ciss_dt(i,3) = tmp(end,3); % years
  ciss_dt(i,4) = tmp(end,4); % yearmonth
  ciss_dt(i,5) = tmp(end,5); % lastweek
end

ciss_dates = datetime(ciss_dt(:,3),ciss_dt(:,2),1, 'Format','yyyy-MM');
ciss = timetable(ciss_dates, ciss_dt(:,5),'VariableNames',{'CISS'});
data = synchronize(data,ciss);

%% MUNC
munc_tbl = readtable('../../data/inputs/factors_clean/MacroUncertaintyToCirculate.xlsx');
munc_dates = munc_tbl{:,1};
munc_dates.Format = 'yyyy-MM';
munc = timetable(munc_dates, munc_tbl{:,2}, 'VariableNames',{'MUNC'});
data = synchronize(data,munc);

%% HPI 

% NOTE:
% monthly version of HPI available only from 1987-01-01, quarterly from 1975-01-01.
% we take both series notmalized at 100 in 1987-01-01
hpi_q = importdata('../../data/inputs/factors_clean/USSTHPI.csv');
hpi_m = importdata('../../data/inputs/factors_clean/CSUSHPINSA.csv');

% extract data and dates
hpi_m_data = hpi_m.data;
hpi_m_dates = datetime(hpi_m.textdata(2:end,1),'InputFormat','yyyy-MM-dd','Format','yyyy-MM');
hpi_q_data = hpi_q.data;
hpi_q_dates = datetime(hpi_q.textdata(2:end,1),'InputFormat','yyyy-MM-dd','Format','yyyy-MM');

% transform the quarterly data for stationarity and divide by three to have monthly change
hpi_q_data = 100.*diff(log(hpi_q_data))/3;
hpi_q_dates = hpi_q_dates(2:end);

% make quarteryl data monthly
start_date = min(hpi_q_dates); % the -calmonths(2) is there because the data show the last value in the quarter (e.g. march june sept dec) 
end_date = max(hpi_q_dates)+calmonths(2); % the +calmonths(2) is there because the data show the first value in the quarter (e.g. jan apr jul oct)
hpi_q_dates = datetime(start_date:calmonths(1):end_date,'Format','yyyy-MM')';
hpi_q_dates = datetime(year(hpi_q_dates),month(hpi_q_dates),1,'Format','yyyy-MM'); % this resets the dates so they always fall on the first of the month (e.g. 2020-01-01, 2020-02-01), regardless of what the original day-of-month was.
hpi_q_data = repelem(hpi_q_data,3);

% transform the monthly data for stationarity
hpi_m_data = 100.*diff(log(hpi_m_data));
hpi_m_dates = hpi_m_dates(2:end);

% append the two series
hpi_q_dates = hpi_q_dates(hpi_q_dates <  hpi_m_dates(1));
hpi_q_data = hpi_q_data(hpi_q_dates <  hpi_m_dates(1));
hpi_data = [hpi_q_data ; hpi_m_data];
hpi_dates = [hpi_q_dates ; hpi_m_dates];

% get the timetable
hpi = timetable(hpi_dates,hpi_data,'VariableNames',{'HPI'});
data = synchronize(data,hpi);

%% CTG
ctg_tbl = readtable('../../data/inputs/factors_clean/CTG bis_dp_search_export_20250925-143239.xlsx');
ctg_dates = datetime(string(ctg_tbl{:,1}),'InputFormat','yyyy-MM-dd','Format','yyyy-MM');
start_date = min(ctg_dates)-calmonths(2); % the -calmonths(2) is there because the data show the last value in the quarter (e.g. march june sept dec) 
end_date = max(ctg_dates);
ctg_dates = datetime(start_date:calmonths(1):end_date,'Format','yyyy-MM')';
ctg_dates = datetime(year(ctg_dates),month(ctg_dates),1,'Format','yyyy-MM'); % this resets the dates so they always fall on the first of the month (e.g. 2020-01-01, 2020-02-01), regardless of what the original day-of-month was.
ctg = repelem(ctg_tbl{:,2},3);
ctg = timetable(ctg_dates, ctg,'VariableNames',{'CTG'});
data = synchronize(data,ctg);

%% WUI - USA
wui_tbl = readtable('../../data/inputs/factors_clean/WUI_Data.xlsx');
wui_dates = wui_tbl{:,1};
wui_data = wui_tbl{:,2};
        
q2m = [1 4 7 10];
parse = @(s) sscanf(s, '%dq%d');

% start date
sYQ = parse(wui_dates{1});
sY = sYQ(1); 
sQ = sYQ(2);
first_date = datetime(sY(1), q2m(sQ), 1);
% end date
eYQ = parse(wui_dates{end});
eY = eYQ(1); 
eQ = eYQ(2);
last_date  = datetime(eY(1), q2m(eQ), 1);

% table
wui_dates = datetime(first_date:calmonths(1):last_date+calmonths(2),'Format','yyyy-MM')';
wui_data = repelem(wui_data,3);
wui = timetable(wui_dates, wui_data,'VariableNames',{'WUI'});

data = synchronize(data,wui);

%% GPR
gpr = importdata('../../data/inputs/factors_clean/data_gpr_export.csv');
gpr_dates = datetime(gpr.textdata(2:end,1),'InputFormat','MM/dd/yyyy','Format','yyyy-MM');
gpr = timetable(gpr_dates,gpr.data,'VariableNames',{'GPR'});
data = synchronize(data,gpr);

%% Policy Uncertainty
epu_tbl = readtable('../../data/inputs/factors_clean/US_Policy_Uncertainty_Data.xlsx', 'ReadVariableNames', false);
epu_dates = datetime(epu_tbl{:,1},epu_tbl{:,2},1,'Format','yyyy-MM');
epu = timetable(epu_dates, epu_tbl{:,3},'VariableNames',{'EPU'});
data = synchronize(data,epu);

%% PRisk
prisk = importdata('../../data/inputs/factors_clean/PRisk.csv');
prisk_dates = datetime(prisk.textdata,'InputFormat','yyyy-MM','Format','yyyy-MM');
prisk = timetable(prisk_dates,prisk.data,'VariableNames',{'PRISK'});
data = synchronize(data,prisk);

%% NPRisk
nprisk = importdata('../../data/inputs/factors_clean/NPRisk.csv');
nprisk_dates = datetime(nprisk.textdata,'InputFormat','yyyy-MM','Format','yyyy-MM');
nprisk = timetable(nprisk_dates,nprisk.data,'VariableNames',{'NPRISK'});
data = synchronize(data,nprisk);

%% Risk
risk = importdata('../../data/inputs/factors_clean/Risk.csv');
risk_dates = datetime(risk.textdata,'InputFormat','yyyy-MM','Format','yyyy-MM');
risk = timetable(risk_dates,risk.data,'VariableNames',{'RISK'});
data = synchronize(data,risk);

%% Select dates and save

% cut data according to FRED-MD dates
data = data(ismember(data.Properties.RowTimes,dates),:);

% extract the time (row times of the timetable)
factors_dates = data.Properties.RowTimes;
% extract the variable (column) names
factors_names = string(data.Properties.VariableNames)';
% extract the numeric (or mixed) data
factors = data.Variables;

% save
save('../../data/outputs/observable_factors.mat', 'factors_dates', 'factors_names', 'factors')
