% Convert .mat files created from parsave back to EEGLAB .set files
function mat2set(path_to_data,filename_tmp)
    % 3_2_Lecture des donnees .mat
    idx = isstrprop(filename_tmp,'digit'); 
    S_tmp = str2num(filename_tmp(idx));
    
    load([path_to_data '\' filename_tmp]);

    % 3_4_Sauvegarder les donnees .set
    path_to_save = path_to_data;
    EEG.setname = ['S' num2str(S_tmp) '_ICAweighted'];
    EEG = pop_saveset( x,[path_to_save '/' filename_tmp(1:end-4) '.set']);
    EEG = eeg_checkset( EEG );
    disp(' ')
    disp('SAUVEGARDE DES DONNEES: OK');
    disp(' ')
    disp(['\n FIN DU TRAITEMENT DU PARTICIPANT ',num2str(S_tmp),'\n']);
end