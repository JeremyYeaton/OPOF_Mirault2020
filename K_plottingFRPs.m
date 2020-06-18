% Pipeline of processing for EEG data from POP-R ERC project
% Experiment : OPOF (Orthographic Parafoveal-On-Foveal effect)
% (c) Stephane DUFAU; Jonathan MIRAULT; Fanny BROQUA; Jeremy YEATON
% Date de creation : 18 Juin 2018
% Mise a jour : January 2020
%%
cd('C:\Users\LPC\Documents\OPOF_reanalyze')
clear all;close all;clc;home
%%
% Load files
load('EEG_times_900ms.mat');
load('chanlocs.mat');
% load('all_data_unprocessed.mat');
load('all_data_the_end.mat');
load('chan_labels.mat');

all_data.c21 = all_data.c21(:,:,mask);
all_data.c31 = all_data.c31(:,:,mask);

nSubs = sum(mask);
disp(['Number of subs: ' num2str(nSubs)])
%% Mirault et al 2020 Figure 3
% Select electrode
channels = {'Fz','Cz','Pz'};

% Define time window
tMin = -100;
tMax = 550;
time_window = find(EEG_times>= tMin & EEG_times <= tMax);

% Set range
yMin = -7;
yMax = 3;

lineWidth = 2;

figure('Renderer', 'painters', 'Position', [100 100 500 750]);

clustShade{1} = [320,390;432,550];
clustShade{2} = [298,308;348,382;438,550];
clustShade{3} = [296,318;348,396;430,550];

for chanIdx = 1:length(channels)
    subplot(3,1,chanIdx)
    chanName = channels{chanIdx};
    chan = find(strcmp(chan_labels, chanName)); %trouver l'index de l'électrode d'intérêt
    % Generate mean curve for electrode by condition
    condSame = mean(all_data.c21(chan,:,:),3);
    condDiff = mean(all_data.c31(chan,:,:),3);
    CS = clustShade{chanIdx};
    for clust = 1:length(CS)
        patch([CS(clust,1) CS(clust,1), CS(clust,2) CS(clust,2)],[-7 3 3 -7],[0.8 0.8 0.8],'LineStyle','none')
        hold on
    end
    FRP_21 = plot(EEG_times(time_window),condSame(time_window),'LineWidth',lineWidth);%-mean(A(time_window)));
    FRP_31= plot(EEG_times(time_window),condDiff(time_window),'LineWidth',lineWidth);%-mean(B(time_window)));
    
    hold off
    if chanIdx == 1
        legend([FRP_21, FRP_31], 'Same', 'Different');
    end
    set(gca, 'ydir', 'reverse', 'xaxislocation', 'origin', 'yaxislocation','origin','ylim',[yMin yMax]);
    xticklabels({'-100', '0', '100', '200', '300', '400', '500', '600', '700'});%, '800'});
    xlim([-100 550])
    yticks([-6 2])
    yticklabels({'-6 \muV','2 \muV'})
    title(chanName);
    set(gca, 'Layer', 'top')
    ax = gca;
    box on
    ax.BoxStyle = 'full';
end