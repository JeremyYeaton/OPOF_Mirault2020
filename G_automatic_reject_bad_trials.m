% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : OPOF (Orthographic Parafoveal-On-Foveal effect)
% (c) Stephane DUFAU; Jonathan MIRAULT; Fanny BROQUA; Jeremy YEATON
% Date de creation : 18 Juin 2018
% Mise a jour : January 2020
%% 0_Effacer les anciennes donnees
cd('C:\Users\LPC\Documents\OPOF_reanalyze')
clear all
close all
home
disp(' ')
disp('PRE-PROCESSING DES DONNEES OPOF : EM and EEG automatic rejection of bad trials');

% 1_Nombre de sujet
%path_to_data='C:\Users\LPC\Documents\MATLAB\Results\ICA_epochs\-0.1_0.8';
path_to_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\F_epoched';
file_struct = dir([path_to_data '/*.set']);
NumberOfBDF=dir([path_to_data '/*.set']);
S_vect = 1:size(NumberOfBDF,1);

disp(' ')
disp(['NOMBRE DE PARTICIPANTS: ', num2str(length(S_vect))]);
%% 3_Boucle pour chaque sujet
trialAutoRej = zeros(length(S_vect),2);
for ind_file = 1:length(file_struct)
    % 3_1_Effacer les anciennes donnees et lancer eeglab
    clearvars -except S_vect  path_to_data ind_S ind_file file_struct trialAutoRej
    eeglab
    
    filename_tmp = file_struct(ind_file).name;
    
    % 3_2_Lecture des donnees
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    trialAutoRej(ind_file,1) = size(EEG.data,3);
    
    % 3_4_1_Copier EEG pour trouver les essais supprimes /!\ SEUILS A DETERMINER /!\
    threshVal = 100;
    ThreshInf = -threshVal;
    ThreshSup = threshVal;
    EpochInf = -0.1; %
    EpochSup = 0.8;
    EEG = pop_eegthresh(EEG,1,1:64 ,ThreshInf,ThreshSup,EpochInf,EpochSup,2,0); % Si le dernier argument=0 -> marked sans suppr
    % Reject based on eyetrack
    EEG = pop_eegthresh(EEG,1,[70 71] ,[1 379] ,[1024 389] ,EpochInf,EpochSup,0,0);
    EEG = eeg_rejsuperpose( EEG, 1, 1, 1, 1, 1, 1, 1, 1);
    rej_epochs = (find(EEG.reject.rejglobal == 1));
    % voir EEG.reject.rejglobal pour le detail si besoin
    
    % 3_4_2_Rejeter les essais (mode: auto)
    EEG = pop_eegthresh(EEG,1,1:64 ,ThreshInf,ThreshSup,EpochInf,EpochSup,2,1); % Si =1 -> marked + suppri auto
    EEG = eeg_checkset( EEG );
    
    trialAutoRej(ind_file,2) = size(EEG.data,3);
    
    disp(' ')
    disp('REJET DES ESSAIS: OK')
    
    % 3_5_Sauvegarder les donnees
    path_to_save = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\G_rejectTrials';
    EEG.setname = ['S' num2str(S_tmp) '_ICA_epochs_rejtrials'];
    EEG = pop_saveset( EEG,[path_to_save '/sub_' num2str(S_tmp) '_epoched_rejtrials.set']);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp('SAUVEGARDE DES DONNEES: OK');
    disp(' ')
    disp(['\n FIN DU TRAITEMENT DU PARTICIPANT N°',num2str(S_tmp),'\n']);

    eeglab redraw
end

colNames = {'Before' 'afterEEGrej'};
save('C:\Users\LPC\Documents\OPOF_reanalyze\Results\F_epoched\trialAutoRej.mat','trialAutoRej','colNames')
% 4_Fin du script
disp(' ')
disp('FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');
waitbar(1,'FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');