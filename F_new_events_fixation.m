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
disp('PRE-PROCESSING DES DONNEES OPOF : ID first fixation events & epoch');

% 1_Nombre de sujet
path_to_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\E_ICAcompRemoved';
% path_to_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\C_analysisSet_preprocess';
file_struct = dir([path_to_data '/*.set']);
NumberOfset=dir([path_to_data '/*.set']);
S_vect = 1:size(NumberOfset,1);

disp(' ')
disp(['NOMBRE DE PARTICIPANTS: ', num2str(length(S_vect))]);

%% 3_Boucle pour chaque sujet
newEventsTrialCount = zeros(length(file_struct),4);
refMs = 1000/85;
for ind_file = 1:length(file_struct)
    % 3_1_Effacer les anciennes donnees et lancer eeglab
    clearvars -except S_vect  path_to_data ind_S fid ind_file file_struct newEventsTrialCount refMs
    eeglab;
    
    filename_tmp = file_struct(ind_file).name;
    
    % 3_2_Lecture des donnees
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx)); %ind_file;
    
    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    % Record number of events at import
    newEventsTrialCount(ind_file,1) = sum(ismember({EEG.event.type},'21'));
    newEventsTrialCount(ind_file,2) = sum(ismember({EEG.event.type},'31'));
    
    % Initialise new event table and make it empty
    newEvent = EEG.event;
    newEvent(1:end) = [];
    fix = 0;
    blinkOffset = 0;
    count211 = 0;
    count311 = 0;
    limInf = 0;limSup = 0;xMax = 0;newTrial = 1;trialOnset = 0;

    % Add events for first fixations
    for Idx = 1:length(EEG.event)
        % Reset variables for new trial
        if strcmp(EEG.event(Idx).type, '120')
            limInf = 0;limSup = 0;xMax = 0;newTrial = 2;
            trialOnset = EEG.event(Idx).latency;
            % Find trial type
            for tIdx = Idx:length(EEG.event)
                if strcmp(EEG.event(tIdx).type, '21') || strcmp(EEG.event(tIdx).type, '31')
                    trialType = [EEG.event(tIdx).type '1'];
                    break
                end
            end

        % If lower bound event, store in lower bound variable
        elseif strcmp(EEG.event(Idx).type, 'R_limInf')
            limInf = EEG.event(Idx).fix_avgpos_x;

        % If upper bound event, store in upper bound variable
        elseif strcmp(EEG.event(Idx).type, 'R_limSup')
            limSup = EEG.event(Idx).fix_avgpos_x;
            
        % Add fixation onset event at beginning of first fixation
        elseif strcmp(EEG.event(Idx).type, 'R_fixation')
            if EEG.event(Idx).fix_avgpos_x > xMax
                xMax = EEG.event(Idx).fix_avgpos_x;
            end
            if EEG.event(Idx).duration < 100
                fixDur = EEG.event(Idx).duration;
                for tIdx = Idx:length(EEG.event)
                    if strcmp(EEG.event(tIdx).type, 'R_fixation')
                        if EEG.event(tIdx).fix_avgpos_x > limSup || EEG.event(tIdx).fix_avgpos_x < limInf
                            break
                        else
                            fixDur = fixDur + EEG.event(tIdx).duration;
                        end
                    end
                end
                if fixDur < 100
                    newTrial = 0;
                end
            end
            timeDiff = EEG.event(Idx).latency - trialOnset;
            refreshCheck = mod(timeDiff, refMs) >= 4 && mod(timeDiff, refMs) <= 10;
            if xMax > limInf && xMax < limSup && newTrial == 2 %&& refreshCheck
                fix = fix + 1;
                % Add new 211 or 311 event (copy orig fix and change type)
                newEvent(end + 1) = EEG.event(Idx); 
                newEvent(end).type = trialType; 
                
                % Increment trial count
                if strcmp(trialType,'211')
                    count211 = count211 + 1;
                elseif strcmp(trialType,'311')
                    count311 = count311 + 1;
                end

                newTrial = 1; % so you only add one fixation
            % Add n + 1 fixations as well
            elseif xMax > limSup && xMax < limSup + 200 && newTrial == 1
                % Add new 212 or 312 event (copy orig fix and change type)
                newEvent(end + 1) = EEG.event(Idx); 
                newEvent(end).type = num2str(str2num(trialType) + 1);
                
                newTrial = 0;
            end
        % If saccade endpoint > xMax, update xMax
        elseif strcmp(EEG.event(Idx).type, 'R_saccade')
            if EEG.event(Idx).sac_endpos_x > xMax
                xMax = EEG.event(Idx).sac_endpos_x;
            end
        end
        newEvent(end + 1) = EEG.event(Idx);
    end
    
    disp(['Number of fixation events added: ' num2str(fix)])
    % Use newEvent as EEG event table
    EEG.event = newEvent;
    
    % 3_7_Definir les epochs /!\ SEUILS A DETERMINER /!\
    EpochInf = -0.1; %
    EpochSup = 0.8;
    EEG = pop_epoch( EEG, { '211' '311' '212' '312' }, [EpochInf  EpochSup], 'newname', 'BDF file epochs', 'epochinfo', 'yes');
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp('EPOCHS: OK');
    
    % 3_8_Definir la baseline /!\ SEUILS A DETERMINER /!\
    BaseMin = -100;%
    BaseMax = 0;%
    EEG = pop_rmbase( EEG, [BaseMin BaseMax]);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp('BASELINE: OK');
    
    % Record number of 211 and 311 events
    newEventsTrialCount(ind_file,3) = count211;
    newEventsTrialCount(ind_file,4) = count311;
    
    % 3_9_Sauvegarder les donnees
    path_to_save = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\F_epoched';
    EEG.setname = ['S' num2str(S_tmp) '_ICA_epoched'];
    EEG = pop_saveset( EEG,[path_to_save '\sub_' num2str(S_tmp) '_epoched.set']);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp('SAUVEGARDE DES DONNEES: OK');
    disp(' ')
    disp(['\n FIN DU TRAITEMENT DU PARTICIPANT N°',num2str(S_tmp),'\n']);
    eeglab redraw
end

colNames = {'21', '31', '211', '311'};
save('C:\Users\LPC\Documents\OPOF_reanalyze\Results\F_epoched\newEventsTrialCount.mat','newEventsTrialCount','colNames');

% 4_Fin du script
disp(' ')
disp('FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');
waitbar(1,'FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');