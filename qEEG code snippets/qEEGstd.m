function signalstd = qEEGstd (tmp_EEG);
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

eeg_chan = struct('channel',[], 'feat', [],'org_set', []);

%loop through channels
for j=1:tmp_EEG.nbchan
    x = tmp_EEG.data(j,:);
    
    sstd = std(x);

    
    eeg_chan(j).feat = sstd;
    eeg_chan(j).channel = j;
    eeg_chan(j).org_set = tmp_EEG.setname;

end

%
signalstd = mean([eeg_chan.feat]);
end