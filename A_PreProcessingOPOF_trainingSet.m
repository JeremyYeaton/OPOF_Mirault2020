% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : OPOF (Orthographic Parafoveal-On-Foveal effect)
% (c) Stephane DUFAU; Jonathan MIRAULT; Fanny BROQUA; Jeremy YEATON
% Date de creation : 18 Juin 2018
% Mise a jour : January 2020

% Revision
% Licence information:

%% 0_Clear the workspace
cd('C:\Users\LPC\Documents\OPOF_reanalyze')
clear all
close all
home
disp(' ')
disp('PRE-PROCESSING DES DONNEES OPOF: training set');

% 1_Nombre de sujet
path_to_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\BDF';
file_struct  = dir([path_to_data '/*.bdf']);
NumberOfBDF  = dir([path_to_data '/*.bdf']);
S_vect       = 1:size(NumberOfBDF,1);

disp(' ')
disp(['NOMBRE DE PARTICIPANTS: ', num2str(max(S_vect))]);

%% 3_Boucle pour chaque sujet
for ind_file = 1:length(file_struct)
    % 3_1_Effacer les anciennes donnees et lancer eeglab
    clearvars -except S_vect  path_to_data ind_S fid ind_file file_struct
    eeglab
    
    filename_tmp = file_struct(ind_file).name;
    
    % 3_2_Lecture des donnees
    idx = isstrprop(filename_tmp,'digit'); 
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    % 3_2_1_Oculometric
    parseeyelink(['ASC/' filename_tmp(1:end-4) '.asc'],['ET_mat/' filename_tmp(1:end-4) '.mat'],'trigger:');
    
    % 3_2_2_EEG
    data_file_name = [path_to_data filesep  filename_tmp];
    if strcmp(filename_tmp(1:end-4), 'sub_19')
        EEG = pop_biosig(data_file_name, 'blockrange',[213 1526] );
    elseif strcmp(filename_tmp(1:end-4), 'sub_5')
        EEG = pop_biosig(data_file_name, 'blockrange',[700 2161] );
    elseif strcmp(filename_tmp(1:end-4), 'sub_9')
        EEG = pop_biosig(data_file_name, 'blockrange',[225 1750] );
    else
        EEG = pop_biosig(data_file_name);
    end
    EEG = eeg_checkset( EEG );
    
    % 3_3_Verification du nb de channels = 64 et taux d'échantillonnage = 1024
    if EEG.nbchan==72 && EEG.srate==1024 %72= 64 electrodes + 8 externes (6 utilisees)
        disp(' ')
        disp(['DEBUT DU TRAITEMENT DU PARTICIPANT N°', num2str(S_tmp)]);
    else
        error('Error with the data dimension !');
    end
    
    % 3_4_Sous-echantillonnage (a 1000Hz)
    EEG = pop_resample( EEG, 500);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp('SOUS-ECHANTILLONNAGE: 1000HZ');
    
    % 3_5_Position des electrodes
    EEG = pop_chanedit(EEG, 'lookup','C:\Users\LPC\Documents\MATLAB\channel_location_LPC_add_ocular.ced');
    EEG = eeg_checkset( EEG );
    
    % 3_6_Modification des codes des triggers (0, 21, 22, 31, 32, 120)
    EV = [EEG.event.type]';
    for ii = 1:length(EV)
        val1 = EEG.event(ii).type;
        val2 = dec2bin(val1);
        val3 = val2(:,end-7:end);
        EEG.event(ii).type = bin2dec(val3);
    end
        
    % 3_7_Filtrage /!\ SEUILS A DETERMINER /!\
    LowFilt = 2.5;
    HighFilt = 100;
    EEG = pop_eegfiltnew(EEG, LowFilt,HighFilt);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp('FILTRAGE: OK');
    
    % 3_8_Remplacer les electrodes externes
    electrode_to_remove = 56;
    electrode_to_add = 71;
    if (S_tmp == 5) % Sujet 5
        for ind_elec = 1:length(electrode_to_remove)
            EEG.data( electrode_to_remove(ind_elec) , :,: ) = EEG.data( electrode_to_add(ind_elec) , :,: );
        end
    end
    EEG = eeg_checkset( EEG );
    
    % 3_9_Choix des electrodes
    EEG = pop_reref( EEG, [65 70]);
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG,'channel',1:68);
    EEG = eeg_checkset( EEG );

% % %     EEG = pop_select( EEG,'channel',[1:64,66:69]);
% % %     EEG = eeg_checkset( EEG );
% % %     
% % %     % 3_10_Re-referencement (mean of all scalp electrodes -- exclude EOG and mastoid ref)
% % %     EEG = pop_reref( EEG, [],'exclude',65:68 );
% % %     EEG = eeg_checkset( EEG );
    disp(' ')
    disp('Re-Referencement: OK');
    
    % Import and sync ET data
    EEG = pop_importeyetracker(EEG,['ET_mat/' filename_tmp(1:end-4) '.mat'],[120 EEG.event(end).type],1:4 ,{'TIME' 'R-GAZE-X' 'R-GAZE-Y' 'R-AREA'},1,1,0,0,4);
    EEG = eeg_checkset( EEG );
    
    % Remove blink segments
    blinkPad = 50; % ms
    blinks = [];
    for Idx = 1:length(EEG.event)
        if strcmp(EEG.event(Idx).type, 'R_blink')
            blinks = [blinks ; [EEG.event(Idx).latency - blinkPad EEG.event(Idx).endtime + blinkPad]];
        end
    end
    EEG = eeg_eegrej( EEG, blinks );
    
    % Remove pauses
    maxPauseLen = 5000; % ms
    EEG  = pop_erplabDeleteTimeSegments( EEG , 'displayEEG',  0, 'endEventcodeBufferMS',  500, 'ignoreUseType', 'ignore',...
        'startEventcodeBufferMS', 500, 'timeThresholdMS',  maxPauseLen );
    EEG = eeg_checkset( EEG );
    
    
    
    % 3_11_Charger le fichier de ref (noms des electrodes)
    load('name_list.mat')
    
    % 3_12_Interpolation
    if (S_tmp == 3)% SUBJECT 3
%         EEG = pop_interp(EEG, 57, 'spherical'); %P2
%         EEG = pop_interp(EEG, 30, 'spherical'); %P0Z
        EEG = pop_interp(EEG, 41, 'spherical'); %F6
        EEG = pop_interp(EEG, 42, 'spherical'); %F8
        EEG = pop_interp(EEG, 35, 'spherical'); %AF8
        EEG = eeg_checkset( EEG );
    end
    
%     if (S_tmp == 5)% SUBJECT 5
%         EEG = pop_interp(EEG, 63, 'spherical'); %P04
%         EEG = eeg_checkset( EEG );
%     end
    
%     if (S_tmp == 7)% SUBJECT 7
%         EEG = pop_interp(EEG, 26, 'spherical'); %P03
%         EEG = eeg_checkset( EEG );
%     end
    
    if (S_tmp == 10)% SUBJECT 10
        EEG = pop_interp(EEG, 8, 'spherical'); %FT7
        EEG = eeg_checkset( EEG );
    end

    if (S_tmp == 12)% SUBJECT 12
        EEG = pop_interp(EEG, 24, 'spherical'); %P9
        EEG = eeg_checkset( EEG );
    end
    
%     if (S_tmp == 14)% SUBJECT 14
%         EEG = pop_interp(EEG, 34, 'spherical'); %FP2
%         EEG = pop_interp(EEG, 41, 'spherical'); %F6
%         EEG = eeg_checkset( EEG );
%     end
    
    if (S_tmp == 18)% SUBJECT 18
        EEG = pop_interp(EEG, 16, 'spherical'); %TP7
        EEG = pop_interp(EEG, 25, 'spherical'); %PO7
        EEG = eeg_checkset( EEG );
    end

    if (S_tmp == 22)% SUBJECT 22
        EEG = pop_interp(EEG, 57, 'spherical'); %P2
        EEG = eeg_checkset( EEG );
    end
    
    if (S_tmp == 24)% SUBJECT 24
        EEG = pop_interp(EEG, 59, 'spherical'); %P6
        EEG = pop_interp(EEG, 63, 'spherical'); %P04
        EEG = eeg_checkset( EEG );
    end
    
    if (S_tmp == 25)% SUBJECT 25
        EEG = pop_interp(EEG, 63, 'spherical'); %P04
        EEG = eeg_checkset( EEG );
    end
    
    disp(' ')
    disp('INTERPOLATION: OK');
    
    % Detect and reject crazy data
    EEG = pop_continuousartdet( EEG , 'ampth', [ -200 200], 'chanArray',  1:64, 'colorseg', [ 1 0.9765 0.5294], 'forder',  100,...
        'numChanThreshold',  1, 'stepms',  250, 'threshType', 'peak-to-peak', 'winms',  500, 'winoffset',50 );
    
    % 3_11_Sauvegarder les donnees
    path_to_save = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\A_trainingSet_preprocess';
    EEG.setname = ['S' num2str(S_tmp) '_pre-ICA'];
    EEG = pop_saveset( EEG,[path_to_save '/sub_' num2str(S_tmp) '_trainingSet.set']);
    EEG = eeg_checkset( EEG );
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