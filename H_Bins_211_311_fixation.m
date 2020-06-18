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
path_to_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\G_rejectTrials';
file_struct = dir([path_to_data '/*.set']);
NumberOfBDF=dir([path_to_data '/*.set']);
S_vect = 1:size(NumberOfBDF,1);

disp(' ')
disp(['NOMBRE DE PARTICIPANTS: ', num2str(length(S_vect))]);
%% 3_Boucle pour chaque sujet
for ind_file = 1:length(file_struct)
    % 3_1_Effacer les anciennes donnees et lancer eeglab
    clearvars -except S_vect  path_to_data ind_S ind_file file_struct
    eeglab
    
    filename_tmp = file_struct(ind_file).name;
    
    % 3_2_Lecture des donnees
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx));
    
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    fprintf(fid, ['\n' filename_tmp ': pop_loadset OK\n']);
    
    % 3_17_Decoupage selon les triggers
    path_to_save = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\H_binEpochs';

    % 3_17_1_Trigger 211 (Condition 0)
    EEG_211 = pop_selectevent(EEG, 'type',211,'deleteevents','off','deleteepochs','on','invertepochs','off');
    EEG_211.setname='BDF file epochs 211';
    EEG_211 = eeg_checkset(EEG_211);
    
    eegName211 = [path_to_save '/sub_' num2str(S_tmp) '_bin211.set'];
    EEG_211 = pop_saveset(EEG_211,eegName211);
    EEG_211 = eeg_checkset(EEG_211);
    
    % 3_17_2_Trigger 311 (Condition 1)
    EEG_311 = pop_selectevent(EEG, 'type',311,'deleteevents','off','deleteepochs','on','invertepochs','off');
    EEG_311.setname='BDF file epochs 311';
    EEG_311 = eeg_checkset(EEG_311);
    
    eegName311 = [path_to_save '/sub_' num2str(S_tmp) '_bin311.set'];
    EEG_311 = pop_saveset(EEG_311,eegName311);
    EEG_311 = eeg_checkset(EEG_311);
    
    disp(' ')
    disp('SAUVEGARDE DES DONNEES: OK');
    disp(' ')
    disp(['\n FIN DU TRAITEMENT DU PARTICIPANT N°',num2str(S_tmp),'\n']);
    
    eeglab redraw
end

% 4_Fin du script
disp(' ')
disp('FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');
waitbar(1,'FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');