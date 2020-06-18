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
disp('PRE-PROCESSING DES DONNEES OPOF : Component removal a la Dimigen');

% 1_Nombre de sujet
path_to_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\D_ICAweighted';
file_struct = dir([path_to_data '/*.set']);
NumberOfset=dir([path_to_data '/*.set']);

S_vect = 1:size(NumberOfset,1);

disp(' ')
disp(['NOMBRE DE PARTICIPANTS: ', num2str(length(S_vect))]);

% Keep track of components removed for each participant
compsRemoved = zeros(length(S_vect),2);
%% 3_Boucle pour chaque sujet
for ind_file = 1:length(file_struct)
    % 3_1_Effacer les anciennes donnees et lancer eeglab
    clearvars -except S_vect  path_to_data ind_file file_struct compsRemoved
    eeglab
    
    filename_tmp = file_struct(ind_file).name;
    
    % 3_2_Lecture des donnees
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    % Identify components for removal
    [EEG vartable] = pop_eyetrackerica(EEG,'R_saccade','R_fixation',[10 0] ,1.1,2,0,4); % using default settings
    components_to_remove = find(EEG.reject.gcompreject);
    
    % Remove components
    EEG = pop_subcomp( EEG, components_to_remove, 0);
    n_comp_removed = length(components_to_remove);
    
    % Record removed components for reporting
    compsRemoved(ind_file,1:2) = [S_tmp n_comp_removed];
    disp(['Number of components removed: ' num2str(n_comp_removed)])
    
    % Save the data
    path_to_save = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\E_ICAcompRemoved';
    EEG.setname = ['S' num2str(S_tmp) '_ICAcompRemoved'];
    EEG = pop_saveset( EEG,[path_to_save '/sub_' num2str(S_tmp) '_ICAcompRemoved.set']);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp('SAUVEGARDE DES DONNEES: OK');
    disp(' ')
    disp(['\n FIN DU TRAITEMENT DU PARTICIPANT N°',num2str(S_tmp),'\n']);
    %
    eeglab redraw
    
end

% Save component removal information
save([path_to_save filesep 'componentsRemoved.mat'],'compsRemoved')

% 4_Fin du script
disp(' ')
disp('FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');
waitbar(1,'FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');