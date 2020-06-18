% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : OPOF (Orthographic Parafoveal-On-Foveal effect)
% (c) Stephane DUFAU; Jonathan MIRAULT; Fanny BROQUA; Jeremy YEATON
% Date de creation : 18 Juin 2018
% Mise a jour : January 2020
%% Load mask to ID participants who made the final cut
load('all_data_the_end.mat','mask');
nSubs = sum(mask);
totalTrials = nSubs * 200;

%% Load ICA rejection data
load('C:\Users\LPC\Documents\OPOF_reanalyze\Results\E_ICAcompRemoved\componentsRemoved.mat')
data = compsRemoved(mask,:);

meanCompsRemoved = mean(data(:,2));

%% Load data from F
load('C:\Users\LPC\Documents\OPOF_reanalyze\Results\F_epoched\newEventsTrialCount.mat')
% See how many trials were excluded for EEG & blink reasons
data = newEventsTrialCount(mask,:);

blinkTrials = totalTrials - sum(data(:,1:2),[1 2]);
blinkPercent = blinkTrials/totalTrials;
totalRej = blinkTrials;

skipTrials = (totalTrials - sum(data(:,3:4),[1 2])) - totalRej;
skipPercent = skipTrials/totalTrials;
totalRej = totalRej + skipTrials;
%% Load final trial counts
load('all_data_the_end.mat','mask', 't1')

finalSum = sum(t1(mask,:),[1 2]);
autoRejTrials = totalTrials - totalRej - finalSum;
autoRejPercent = autoRejTrials/totalTrials;