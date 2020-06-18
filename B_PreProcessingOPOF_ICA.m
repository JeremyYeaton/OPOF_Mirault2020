% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : OPOF (Orthographic Parafoveal-On-Foveal effect)
% (c) Stephane DUFAU; Jonathan MIRAULT; Fanny BROQUA; Jeremy YEATON
% Date de creation : 18 Juin 2018
% Mise a jour : January 2020
%%
cd('C:\Users\LPC\Documents\OPOF_reanalyze')
clear all;close all;clc;home
disp(' ')
disp('ICA SUR DONNEES CONTINUES OPOF');

% 1_Nombre de sujet
path_to_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\A_trainingSet_preprocess';
file_struct = dir([path_to_data '/*.set']);
NumberOfset = dir([path_to_data '/*.set']);
S_vect = 1:size(NumberOfset,1);

disp(' ')
disp(['NOMBRE DE PARTICIPANTS: ', num2str(length(S_vect))]);
%% 3_Boucle pour chaque sujet
tic 
parfor ind_file = 1:length(file_struct) 
    % 3_1_Effacer les anciennes donnees et lancer eeglab
    eeglab
    
    filename_tmp = file_struct(ind_file).name;
    
    % 3_2_Lecture des donnees
    idx = isstrprop(filename_tmp,'digit'); 
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    % 3_3_ICA
    % Produce overweighted data for ICA
    EEG = pop_overweightevents(EEG,'R_saccade',[-0.02 0.01] ,0.5,1)
    EEG = pop_runica(EEG, 'extended',1,'interupt','on','chanind',1:68);
    EEG = eeg_checkset( EEG );
    
    % 3_4_Sauvegarder les donnees
    path_to_save = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\B_trainingSet_ICA\';
    EEG.setname = ['S' num2str(S_tmp) '_ICA'];
    parsave([path_to_save 'sub' num2str(S_tmp) '_ICAweighted.mat'], EEG);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp('SAUVEGARDE DES DONNEES: OK');
    disp(' ')
    disp(['\n FIN DU TRAITEMENT DU PARTICIPANT N°',num2str(S_tmp),'\n']);

    eeglab redraw

 end
toc

% Convert .mat files to .set
path_to_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\B_trainingSet_ICA\';
file_struct  = dir([path_to_data '/*.mat']);
    
for ind_file = 1:length(file_struct)
    filename_tmp = file_struct(ind_file).name;
    mat2set(path_to_data, filename_tmp)
end

% 4_Fin du script
disp(' ')
disp('FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');
waitbar(1,'FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');