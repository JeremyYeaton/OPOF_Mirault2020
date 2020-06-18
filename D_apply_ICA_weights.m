% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : OPOF (Orthographic Parafoveal-On-Foveal effect)
% (c) Stephane DUFAU; Jonathan MIRAULT; Fanny BROQUA; Jeremy YEATON
% Date de creation : 18 Juin 2018
% Mise a jour : January 2020
%% 0_Effacer les anciennes donnees
clear all
close all
home
disp(' ')
disp('Copy ICA weights from training set to analysis set');

% 1_Nombre de sujet
% Directory for trained data
path_to_ica_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\B_trainingSet_ICA';
% Directory for analysis data
path_to_data='C:\Users\LPC\Documents\OPOF_reanalyze\Results\C_analysisSet_preprocess';
file_struct = dir([path_to_ica_data '/*.set']);
NumberOfset = dir([path_to_ica_data '/*.set']);
S_vect = 1:size(NumberOfset,1);

disp(' ')
disp(['NOMBRE DE PARTICIPANTS: ', num2str(length(S_vect))]);
%% 3_Boucle pour chaque sujet: add trained ICA weights to filtered continuous data
for ind_file = 1:length(file_struct)
    % 3_1_Effacer les anciennes donnees et lancer eeglab
    clearvars -except S_vect  path_to_data path_to_ica_data ind_S fid ind_file file_struct
    eeglab
    
    filename_tmp = file_struct(ind_file).name;
    
    % 3_2_Lecture des donnees
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    EEG = pop_loadset('filename', [path_to_ica_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    % Copy ICA weights from training data
    TMP.icawinv = EEG.icawinv;
    TMP.icasphere = EEG.icasphere;
    TMP.icaweights = EEG.icaweights;
    TMP.icachansind = EEG.icachansind;
    clear EEG;
    
    % Apply ICA weights to analysis data
    EEG = pop_loadset('filename', [path_to_data '\sub_' num2str(S_tmp) '_analysisSet_preprocess.set']);
    EEG.icawinv = TMP.icawinv;
    EEG.icasphere = TMP.icasphere;
    EEG.icaweights = TMP.icaweights;
    EEG.icachansind = TMP.icachansind;
    clear TMP;
    
    % 3_5_Sauvegarder les donnees
    path_to_save = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\D_ICAweighted';
    EEG.setname = ['S' num2str(S_tmp) '_ICA'];
    EEG = pop_saveset( EEG,[path_to_save '/sub_' num2str(S_tmp) '_ICAweighted.set']);
end

% 4_Fin du script
disp(' ')
disp('FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');
waitbar(1,'FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');