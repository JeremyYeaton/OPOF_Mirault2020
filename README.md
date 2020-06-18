# OPOF_Mirault2020
Matlab code used for the EEG analyses presented in Mirault et al (2020) "Parafoveal‐on‐foveal repetition effects in sentence reading: A co‐registered eye‐tracking and electroencephalogram study." [[full text](https://onlinelibrary.wiley.com/doi/epdf/10.1111/psyp.13553)]

# Requirements
This is all Matlab code and requires the following open-source toolboxes to run:
[EEGLAB](https://sccn.ucsd.edu/eeglab/index.php)
[EYE-EEG Toolbox](http://www2.hu-berlin.de/eyetracking-eeg/)
[Mass-Univariate ERP Toolbox](https://openwetware.org/wiki/Mass_Univariate_ERP_Toolbox)

You will also need to make sure that you have Matlab configured for parallelization, as it is used to speed up the ICA training process.

If you have any questions about this code feel free to e-mail the second author at jyeaton@uci.edu. If you use this code in a future project, please cite the publication above as well as the required toolboxes.

# Pipeline
The annotation needs some work, but all of the code is there. The scripts are to be run alphabetically:
- A_PreProcessingOPOF_trainingSet.m: Preprocesses raw EEG data for ICA training
- B_PreProcessingOPOF_ICA.m: Runs ICA decomposition on overweighted training data
- C_PreProcessingOPOF_analysisSet.m: Preproceeses raw EEG data with different parameters for analysis
- D_apply_ICA_weights.m: Applies ICA weights from training set to analysis set
- E_remove_ICA_components.m: Removes eye-movement based ICA components from data 
- F_new_events_fixation.m: Creates new events by condition according to onset of fixation instead of boundary crossing
- G_automatic_reject_bad_trials.m: Removes trials containing values that fall outside of acceptable thresholds
- H_Bins_211_311_fixation.m: Creates bins by condition for each participant
- I_topoplot_script_new_events.m: Aggregates data by condition and excludes participants not reaching the minimum number of trials to be included in analysis
- J_Cluster_based_permutation_test.m: The code to run the cluster based permutation test presented in the paper, as well as for both panels of figure 4
- K_plottingFRPs.m: The code to reproduce figure 3 from the paper above
- L_Trial_accounting.m: A transparency script to count how many trials were lost at the various stages of rejection

The respository also contains two functions to facilitate parallelization of the ICA training:
- parsave.m: Saves data structure from within parallel loop
- mat2set.m: Converts .mat file saved during parallel loop back to EEGLAB .set file
