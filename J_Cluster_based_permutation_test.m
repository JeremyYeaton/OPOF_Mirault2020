% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : OPOF (Orthographic Parafoveal-On-Foveal effect)
% (c) Stephane DUFAU; Jonathan MIRAULT; Fanny BROQUA; Jeremy YEATON
% Date de creation : 18 Juin 2018
% Mise a jour : January 2020
%% 0_Effacer les anciennes donnees
cd('C:\Users\LPC\Documents\OPOF_reanalyze')
clear all
close all
load('all_data_the_end.mat','mask');
home
disp(' ')
disp('PRE-PROCESSING DES DONNEES OPOF : Cluster based permutation test');

% 1_Nombre de sujet
path_to_data = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\F_epoched';
file_struct = dir([path_to_data '/*.set']);
file_struct = file_struct(mask);
NumberOfset = dir([path_to_data '/*.set']);
S_vect = 1:length(file_struct);

disp(' ')
disp(['NOMBRE DE PARTICIPANTS: ', num2str(S_vect)]);

%% 3_Boucle pour chaque sujet
path_to_save = 'C:\Users\LPC\Documents\OPOF_reanalyze\Results\J_events2string';
for ind_file = 1:length(file_struct)
    % 3_1_Effacer les anciennes donnees et lancer eeglab
    clearvars -except S_vect  path_to_data ind_S fid ind_file file_struct path_to_save
    
    filename_tmp = file_struct(ind_file).name;
    
    % 3_2_Lecture des donnees
    idx = isstrprop(filename_tmp,'digit');
    S_tmp = str2num(filename_tmp(idx));

    EEG = pop_loadset('filename', [path_to_data '\' filename_tmp]);
    EEG = eeg_checkset( EEG );
    
    EEG = pop_resample( EEG, 500);
    EEG = eeg_checkset( EEG );
    
    %3_3_Convert to string and add subject codename
    for i = 1:length(EEG.epoch)
        for b = 1:length(EEG.epoch(i).eventtype)
            EEG.epoch(i).eventtype{b} = num2str(EEG.epoch(i).eventtype{b});
        end
    end
    EEG.subject = ['S_' num2str(S_tmp)];
    
    blf = [path_to_save filesep 'binNames.txt'];
    EEG = bin_info2EEG(EEG, blf);
    EEG = eeg_checkset( EEG );
    
    %3_4_Sauvegarder les donnees
    EEG.setname = ['S' num2str(S_tmp) '_ICA_epochs_rejtrials'];
    EEG = pop_saveset( EEG,[path_to_save '\sub_' num2str(S_tmp) '_ICA_epochs_rejtrials.set']);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp('SAUVEGARDE DES DONNEES: OK');
    disp(' ')
    disp(['\n FIN DU TRAITEMENT DU PARTICIPANT N°',num2str(S_tmp),'\n']);  
end
% 4_Fin du script
disp(' ')
disp('FIN DU TRAITEMENTS DE TOUS LES PARTICIPANTS');
%% Create a GND variable from set files 
chans2exclude = {'HEOGD_EXG2';'VEOGD_EXG3';'VEOGG_EXG4';'HEOGG_EXG5';'TIME';'R-GAZE-X';'R-GAZE-Y';'R-AREA'};
GND = sets2GND('gui', 'bsln', [-100 0], 'exclude_chans', chans2exclude,'exp_name','OPOF'); 

%% Within-subject t-tests
load('chanlocs.mat');
load  C:\Users\LPC\Documents\OPOF_reanalyze\Results\J_events2string\granAvgAllCond500_40_comRef.GND -MAT
chan_hood = spatial_neighbors(chanlocs(1:64),40);

% Creating a difference wave between the 2 conditions
GND = bin_dif(GND, 2, 1, 'Different - Same');

tWin = [0 550]; 
[GND, prm_pval, data_t]  = clustGND(GND, 5, 'time_wind', tWin, 'chan_hood', chan_hood, 'alpha',0.05,'tail', -1, 'thresh_p', 0.05, 'n_perm', 2500);
%% Mirault et al 2020 Figure 4, top
load  C:\Users\LPC\Documents\OPOF_reanalyze\Results\J_events2string\granAvgAllCond500_40.GND -MAT
t_test = GND.t_tests(3);
mask = t_test.adj_pval < 0.05;
t_test.adj_pval(~mask) = 1;
figure('Renderer', 'painters', 'Position', [100 100 500 800]);
tIdxs = t_test.used_tpt_ids;
tvals = GND.grands_t(:,tIdxs,5);
tvals(~mask) = 0;

imagesc(tvals)
yticks(1:64);
yticklabels(chan_labels(1:64))
xticks(0:50:275)
xticklabels([0 100 200 300 400 500])
xlabel(['Time (ms)'])
ylabel(['Electrode'])
caxis([-5 5])
colormap(jet)
hcb = colorbar;
title(hcb,'t-val')

%% Mirault et al 2020 Figure 4, bottom
clust1 = [260 410];
clust2 = [416 500];

cax = [-1.5 1.5];
side = 250;
figure('Renderer', 'painters', 'Position', [100 100 side side]);
tWin = find(EEG_times>= clust1(1) & EEG_times <= clust1(2));
cond21 = mean(all_data.c21(1:64,tWin,:),[2 3]);
cond31 = mean(all_data.c31(1:64,tWin,:),[2 3]);
condDiff = cond31 - cond21;
topoplot(condDiff,chanlocs(1:64))
caxis(cax)
title([num2str(clust1(1)) '-' num2str(clust1(2)) ' ms'])

figure('Renderer', 'painters', 'Position', [100 100 side side]);
tWin = find(EEG_times>= clust2(1) & EEG_times <= clust2(2));
cond21 = mean(all_data.c21(1:64,tWin,:),[2 3]);
cond31 = mean(all_data.c31(1:64,tWin,:),[2 3]);
condDiff = cond31 - cond21;
topoplot(condDiff,chanlocs(1:64))
caxis(cax)
title([num2str(clust2(1)) '-' num2str(clust2(2)) ' ms'])

cb = colorbar;
x0 = cb.Position(1) + .15;
y0 = cb.Position(2) - .075;
width = .02;
height = cb.Position(4) + .15;
cb.Position = [x0 y0 width height];
title(cb,'\muV')