%% eeglab setup
cd '~/EEG'
eeglab_setup

%% load workspace files
% workspace locations
eeg_files_root = '~/EEG/file_processing/';
eeg_filenames = {
    '01-10_preprocessed_eeg.mat'
    '01-30_preprocessed_eeg.mat'
    '31-40_preprocessed_eeg.mat'
    '41-50_preprocessed_eeg.mat'
    '01-50_preprocessed_eeg.mat'
    '01-60_preprocessed_eeg.mat'
    '01-60_preprocessed_eeg_special.mat'
    '01-53_preprocessed_eeg.mat'
    '54-113_preprocessed_eeg.mat'
    '01-113_preprocessed_eeg.mat'
    '01-113_preprocessed_eeg_inprogress2.mat'
    'Jan31_01-113_preprocessed_eeg1'
    'final_01-53_preprocessed_eeg'
    'final_batch2_preprocessed_eeg'
    'final_01-93_preprocessed_eeg'
    'final_01-96_preprocessed_eeg'
    'final_files_march_2_final.mat'
    '105_final.mat'
    '100_final.mat'
    };

eeg_workspace = [];
%loads eeg files in eeglab data format into eeg_workspace variable
load([eeg_files_root eeg_filenames{end}]); 
num_files = numel(eeg_workspace);

for k=1:num_files
    tmp_EEG = eeg_workspace(k);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, tmp_EEG);
end
eeglab redraw



%% can continue directly from loadWorspaces here
eeg_workspace_precut = eeg_workspace;
eeg_workspace = finalpreprocessEEG(eeg_workspace);% cuts data to equal length


for k=1:num_files
    tmp_EEG = eeg_workspace(k);
    setname = tmp_EEG.setname;
    idx = strfind(setname,'_prep');
    if ~isempty(idx)
        setname = [tmp_EEG.setname(1:idx) 'finalpreprocessed'];
    end
    tmp_EEG.setname = setname;
    eeg_workspace(k).setname = setname;
    %[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, tmp_EEG);
end
eeglab redraw

%SNR=40;
%eeg_workspace = genAugmentedData(eeg_workspace,SNR);

VAR=50;
DOWNSAMPLE=true;
%eeg_workspace = genAugmentedData2(eeg_workspace,VAR,DOWNSAMPLE);
eeg_workspace = genAugmentedDataSTFT(eeg_workspace,VAR);

%% QEEG and Clinical Feature Generation
eeg_features=genFeatures(eeg_workspace);
eeg_features_clinical=genFeaturesClinical();


eeg_features_table = struct2table(eeg_features);
% extract only patient id to match keys when joining
eeg_features_table.org_set = cellfun(@(x)str2double(regexp(x,'\d*','match','once')),eeg_features_table.org_set);
%eeg_features_clinical.EEG_ = cellfun(@(x)str2double(regexp(x,'\d*','match','once')),eeg_features_clinical.EEG_);
eeg_features_table.org_set = cellfun(@(x)str2double(regexp(x,'\d*','match','once')),eeg_features_table.org_set);
final_feats.DaysFromInjury = cellfun(@(x)str2double(regexp(x,'\d*','match','once')),final_feats.DaysFromInjury);

[final_feats, left_idxs] = outerjoin(eeg_features_table,eeg_features_clinical,'MergeKeys', true, 'LeftKeys',1,'RightKeys',1);
final_feats = final_feats(find(left_idxs~=0),:);
disp('Click or press key to write dataset')
waitforbuttonpress;

% %loop to update filenames to just numbers
% for k=1:size(eeg_features,2)
%     name = eeg_features(k).org_set;
%     name = strsplit(name,'_');
%     eeg_features(k).org_set = name{1,1};
% end


writetable(eeg_features_clinical, '~/EEG/datasets/march26_clinical.csv');
writetable(final_feats, '~/EEG/datasets/march8_final105.csv');

clear eeg_workspace