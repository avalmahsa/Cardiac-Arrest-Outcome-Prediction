function pwellyband = qEEGBandPowerWELCH(tmp_EEG, Fs, FREQRANGE)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

eeg_chan = struct('channel',[], 'feat', [],'org_set', []);

%loop through channels
for j=1:tmp_EEG.nbchan
    x = tmp_EEG.data(j,:);

    [eeg_chan(j).pwellyPxx, eeg_chan(j).pwellyF] = pwelch(x, [], [], [], Fs);
    eeg_chan(j).pwellyband = bandpower(eeg_chan(j).pwellyPxx, eeg_chan(j).pwellyF, FREQRANGE,'psd');
    
    eeg_chan(j).channel = j;
    eeg_chan(j).org_set = tmp_EEG.setname;
    

end

pwellyband = mean([eeg_chan.pwellyband]);
end