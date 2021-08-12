function eeg_workspace = finalpreprocessEEG(eeg_workspace)

    for k=1:numel(eeg_workspace)
        tmp_EEG = eeg_workspace(k);

        split_idx = epochEEG(tmp_EEG,150000,10); % finds longest uninterrupted epoch
        
        if any(split_idx ~= -1) && contains(tmp_EEG.setname,'preproc')
            tmp_EEG = pop_select(tmp_EEG, 'point', split_idx);
        else
            % not a big deal, add bp here to find files that dont meet
            % criteria above
            warning('add breakpoint here to find files');
        end
        
        eeg_workspace(k) = tmp_EEG;
    end
    files_to_modify = contains({eeg_workspace.setname},'preproc');
    shortest_len = min([eeg_workspace(files_to_modify).pnts]);

    for k=1:numel(eeg_workspace)
        tmp_EEG = eeg_workspace(k);
        if contains(tmp_EEG.setname,'preproc')
            tmp_EEG = pop_select(tmp_EEG, 'point', [1 shortest_len]);
            eeg_workspace(k) = tmp_EEG;
        end
    end
end