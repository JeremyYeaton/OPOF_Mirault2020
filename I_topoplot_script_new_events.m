% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : OPOF (Orthographic Parafoveal-On-Foveal effect)
% (c) Stephane DUFAU; Jonathan MIRAULT; Fanny BROQUA; Jeremy YEATON
% Date de creation : 18 Juin 2018
% Mise a jour : January 2020
%%
cd('C:\Users\LPC\Documents\OPOF_reanalyze')
clear all;close all;clc
home
disp(' ')
disp('COMPILE DES DONNEES OPOF');

%1_Nombre de sujet
path_to_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\H_binEpochs';
file_struct = dir([path_to_data '/*.set']);

NumberOfBDF=dir([path_to_data '/*.set']);
nParticipants = size(NumberOfBDF,1)/4;
S_vect = 1:nParticipants;

disp(' ')
disp(['NOMBRE DE PARTICIPANTS: ', num2str(nParticipants)]);

% Load files
load('EEG_times_900ms.mat');
load('chanlocs.mat');
load('all_data_the_end.mat');
load('chan_labels.mat');
%% Aggregate data by condition
% Regrouper les EEG.data des bins 211 et 311 de chaque sujet dans un même all_data.mat (channels*timepoints*subjects)
all_data.c21 = zeros(72,900,nParticipants);
all_data.c31 = zeros(72,900,nParticipants);
totalTrials = zeros(length(file_struct)/2,1);
idx21 = 1;
idx31 = 1;

for ind_file = 1:length(file_struct)
    filename_tmp = file_struct(ind_file).name;
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    if strcmp(filename_tmp(end-6:end-4), '211')
        nTrials = size(EEG.data,3);
        totalTrials(ind_file) = nTrials;
        all_data.c21(:,:,idx21) = mean(EEG.data(:,:,:),3);
        idx21 = idx21 + 1;
    elseif strcmp(filename_tmp(end-6:end-4), '311')
        nTrials = size(EEG.data,3);
        totalTrials(ind_file) = nTrials;
        all_data.c31(:,:,idx31) = mean(EEG.data(:,:,:),3);
        idx31 = idx31 + 1;
    end
end

% % Get # trials & remove subs with less than 35 in either condition
tt = totalTrials(:,1);

t0 = tt(1:2:end);
t1(:,1) = t0(1:2:end);
t1(:,2) = t0(2:2:end);
mask0 = t1(:,1:2) > 35;
mask = sum(mask0,2) == 2; 

all_data_unproc = all_data;
disp('Saving the data...')
save all_data_the_end all_data mask t1
disp('Saved!')