%% Housekeeping
clear
close all
clc

%% Load data
load('../../../data/outputs/stats_MCS.mat');
load('../../../data/outputs/result_MCS.mat');

% horizons
H = [1 3 6 12];

% first add to the chosen models the column with the tick loss of the model
for h = 1:numel(H)
    % create table of tick loss gains with keys for the merge
    tl_gain = stats.avg_bm_tick_loss_gain(h,:)';
    tl_gain_keys = (1:numel(tl_gain))';
    table_tl_gain = table(tl_gain_keys, tl_gain);    
    % merge
    result_MCS{h} = join(result_MCS{h}, table_tl_gain, 'LeftKeys','Model','RightKeys','tl_gain_keys');
end

%% Enrich MCS results

% Factors types
macro = {'MUNC','HPI','CTG'};
fin   = {'FUNC','CISS','NFCI','VIX','EBP'};
stat  = {'PC1','PC2','PC3','PCF1','PCF2','PCF3','QF1','QF2','QF3'};
text  = {'GPR','WUI','EPU'};

for h = 1:numel(H)

    rowNames_all = result_MCS{h}.Properties.RowNames;

    % Count the total occurrences of specified substrings in each name
    result_MCS{h}.macro_count = cellfun(@(name) sum(cellfun(@(s) count(name, s), macro)), rowNames_all);
    result_MCS{h}.fin_count   = cellfun(@(name) sum(cellfun(@(s) count(name, s), fin)), rowNames_all);
    result_MCS{h}.stat_count  = cellfun(@(name) sum(cellfun(@(s) count(name, s), stat)), rowNames_all);
    result_MCS{h}.text_count  = cellfun(@(name) sum(cellfun(@(s) count(name, s), text)), rowNames_all);
    
    % Get the number of factors for each model
    result_MCS{h}.n_fac = sum(result_MCS{h}{:,{'macro_count','fin_count','stat_count','text_count'}}, 2); 

    % count LS and QR
    result_MCS{h}.ls = double(cellfun(@(name) contains(name,'_ls'), rowNames_all));
    result_MCS{h}.qr = double(cellfun(@(name) contains(name,'_qr'), rowNames_all));

    % dummy for chosen models
    result_MCS{h}.chosen = double(result_MCS{h}.MCS_p_val >= 0.10);

end


%% Statistics for MCS table

summary_MCS = struct();
summary_MCS.nfci_qr_chosen = strings(1,numel(H));
summary_MCS.nfci_ls_chosen = strings(1,numel(H));
summary_MCS.ar_qr_chosen = strings(1,numel(H));
summary_MCS.ar_ls_chosen = strings(1,numel(H));

for h = 1:numel(H)
    
    % column 1 of MCS table
    summary_MCS.share_chosen(h) = mean(result_MCS{h}.chosen)*100;

    summary_MCS.share_ls(h)     = sum(result_MCS{h}.ls(result_MCS{h}.chosen == 1))*100/sum(result_MCS{h}.ls);
    summary_MCS.share_qr(h)     = sum(result_MCS{h}.qr(result_MCS{h}.chosen == 1))*100/sum(result_MCS{h}.qr);

    summary_MCS.share_0fac(h)   = sum(result_MCS{h}.n_fac == 0 & result_MCS{h}.chosen == 1)*100/sum(result_MCS{h}.n_fac == 0);
    summary_MCS.share_1fac(h)   = sum(result_MCS{h}.n_fac == 1 & result_MCS{h}.chosen == 1)*100/sum(result_MCS{h}.n_fac == 1);
    summary_MCS.share_2fac(h)   = sum(result_MCS{h}.n_fac == 2 & result_MCS{h}.chosen == 1)*100/sum(result_MCS{h}.n_fac == 2);
    summary_MCS.share_3fac(h)   = sum(result_MCS{h}.n_fac == 3 & result_MCS{h}.chosen == 1)*100/sum(result_MCS{h}.n_fac == 3);
    
    if result_MCS{h}{'NFCI_qr','chosen'} == 1
        summary_MCS.nfci_qr_chosen(h) = "$\checkmark$";
    else
        summary_MCS.nfci_qr_chosen(h) = "$\times$";
    end
    if result_MCS{h}{'NFCI_ls','chosen'} == 1
        summary_MCS.nfci_ls_chosen(h) = "$\checkmark$";
    else
        summary_MCS.nfci_ls_chosen(h) = "$\times$";
    end
    if result_MCS{h}{'AR_qr','chosen'} == 1
        summary_MCS.ar_qr_chosen(h) = "$\checkmark$";
    else
        summary_MCS.ar_qr_chosen(h) = "$\times$";
    end        
    if result_MCS{h}{'AR_ls','chosen'} == 1
        summary_MCS.ar_ls_chosen(h) = "$\checkmark$";
    else
        summary_MCS.ar_ls_chosen(h) = "$\times$";
    end
    
    % column 2 of MCS table
    summary_MCS.best_gain_chosen(h) = max(result_MCS{h}.tl_gain(result_MCS{h}.chosen == 1));

    summary_MCS.best_gain_ls(h) = max(result_MCS{h}.tl_gain(result_MCS{h}.ls == 1 & result_MCS{h}.chosen == 1));
    if summary_MCS.share_qr(h) == 0 
        summary_MCS.best_gain_qr(h) = max(result_MCS{h}.tl_gain(result_MCS{h}.qr == 1));
    else
        summary_MCS.best_gain_qr(h) = max(result_MCS{h}.tl_gain(result_MCS{h}.qr == 1 & result_MCS{h}.chosen == 1));
    end

    summary_MCS.best_gain_0fac(h) = max(result_MCS{h}.tl_gain(result_MCS{h}.n_fac == 0 & result_MCS{h}.chosen == 1));
    summary_MCS.best_gain_1fac(h) = max(result_MCS{h}.tl_gain(result_MCS{h}.n_fac == 1 & result_MCS{h}.chosen == 1));
    summary_MCS.best_gain_2fac(h) = max(result_MCS{h}.tl_gain(result_MCS{h}.n_fac == 2 & result_MCS{h}.chosen == 1));
    summary_MCS.best_gain_3fac(h) = max(result_MCS{h}.tl_gain(result_MCS{h}.n_fac == 3 & result_MCS{h}.chosen == 1));

    summary_MCS.nfci_qr_best_gain(h) = string(round(result_MCS{h}{'NFCI_qr','tl_gain'},1));
    summary_MCS.nfci_ls_best_gain(h) = string(round(result_MCS{h}{'NFCI_ls','tl_gain'},1));
    summary_MCS.ar_qr_best_gain(h)   = string(round(result_MCS{h}{'AR_qr'  ,'tl_gain'},1));
    summary_MCS.ar_ls_best_gain(h)   = string(round(result_MCS{h}{'AR_ls'  ,'tl_gain'},1));

end

save('../../../data/outputs/summary_MCS.mat','summary_MCS')