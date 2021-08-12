function SMF = qEEGMedianFrequency(tmp_EEG,leftcutoff,rightcutoff)

eeg_chan = struct('channel',[], 'feat', [],'org_set', []);

%loop through channels
for j=1:tmp_EEG.nbchan
    x = tmp_EEG.data(j,:);
    
    eeg_chan(j).feat = MedianFrequency(x,leftcutoff,rightcutoff);
    eeg_chan(j).channel = j;
    eeg_chan(j).org_set = tmp_EEG.setname;

end

%
SMF = mean([eeg_chan.feat]);
end
