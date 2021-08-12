function voltage = qEEGvoltage(tmp_EEG, less_than_voltage)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

eeg_chan = struct('channel',[], 'feat', [],'org_set', []);

%loop through channels
for j=1:tmp_EEG.nbchan
    x = tmp_EEG.data(j,:);
    
    v = mean(abs(x) < less_than_voltage);
   
    
    eeg_chan(j).feat = v;
    eeg_chan(j).channel = j;
    eeg_chan(j).org_set = tmp_EEG.setname;
    
end    
voltage = mean([eeg_chan.feat]);



    