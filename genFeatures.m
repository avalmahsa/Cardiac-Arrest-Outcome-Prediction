function eeg_features = genFeatures(eeg_workspace)

eeg_features = struct('org_set', []);
num_files = numel(eeg_workspace); 

%entropy params
bin_min = -200;
bin_max = 200;
binWidth = 2;
%medfreq
leftcutoff = 1;
rightcutoff = 20;
    
% loop through EEG
for k=1:num_files
    tmp_EEG = eeg_workspace(k);
    if contains(tmp_EEG.setname, '_finalpreprocessed')
        disp(['Generating features for file (' num2str(k) '/' num2str(num_files) '): ' tmp_EEG.setname]);
        
        Fs = tmp_EEG.srate;
        eeg_features(k).org_set = tmp_EEG.setname;
        
        % shannon
        eeg_features(k).Shannon = qEEGShannonEntropy(tmp_EEG, bin_min, bin_max, binWidth);
        
        % shannon
        eeg_features(k).SIQ = qEEGSIQ(tmp_EEG, bin_min, bin_max, binWidth);
        eeg_features(k).SIQ_delta = qEEGSIQ(tmp_EEG, bin_min, bin_max, binWidth, 'delta');
        eeg_features(k).SIQ_theta = qEEGSIQ(tmp_EEG, bin_min, bin_max, binWidth, 'theta');
        eeg_features(k).SIQ_alpha = qEEGSIQ(tmp_EEG, bin_min, bin_max, binWidth, 'alpha');
        eeg_features(k).SIQ_beta = qEEGSIQ(tmp_EEG, bin_min, bin_max, binWidth, 'beta');
        
        % standard deviation of signal
        eeg_features(k).SignalSD = qEEGstd(tmp_EEG);
        
        %med freq
        eeg_features(k).medFreq = qEEGMedianFrequency(tmp_EEG, leftcutoff, rightcutoff);
        
        
        % low voltage 5, 10, 20
        eeg_features(k).lv_l5 = qEEGvoltage(tmp_EEG,5);
        eeg_features(k).lv_l10 = qEEGvoltage(tmp_EEG,10);
        eeg_features(k).lv_l20 = qEEGvoltage(tmp_EEG,20);
        
%         % band power
%         eeg_features(k).delta = qEEGBandPower(tmp_EEG,Fs,[1,4]);
%         eeg_features(k).theta = qEEGBandPower(tmp_EEG,Fs,[4,8]);
%         eeg_features(k).alpha = qEEGBandPower(tmp_EEG,Fs,[8,13]);
%         eeg_features(k).beta = qEEGBandPower(tmp_EEG,Fs,[13,20]);
%         
%         % total band power
%         eeg_features(k).totalpower = qEEGBandPower(tmp_EEG,Fs,[1 ,20]);
%         
%         % relative band power
%         eeg_features(k).deltarelative =  eeg_features(k).delta/eeg_features(k).totalpower;
%         eeg_features(k).thetarelative = eeg_features(k).theta/eeg_features(k).totalpower;
%         eeg_features(k).alpharelative = eeg_features(k).alpha/eeg_features(k).totalpower;
%         eeg_features(k).betarelative = eeg_features(k).beta/eeg_features(k).totalpower;
%         

        % band power using PSD / Welch 
        eeg_features(k).deltaWelch = qEEGBandPowerWELCH(tmp_EEG, Fs, [1,4]);
        eeg_features(k).thetaWelch = qEEGBandPowerWELCH(tmp_EEG, Fs, [4,8]);
        eeg_features(k).alphaWelch = qEEGBandPowerWELCH(tmp_EEG, Fs, [8,13]);
        eeg_features(k).betaWelch = qEEGBandPowerWELCH(tmp_EEG, Fs, [13,20]);
        
        % total band power
        eeg_features(k).totalpowerWelch = qEEGBandPowerWELCH(tmp_EEG, Fs, [1 ,20]);
        
        % relative band power
        eeg_features(k).deltarelativeWelch =  eeg_features(k).deltaWelch/eeg_features(k).totalpowerWelch;
        eeg_features(k).thetarelativeWelch = eeg_features(k).thetaWelch/eeg_features(k).totalpowerWelch;
        eeg_features(k).alpharelativeWelch = eeg_features(k).alphaWelch/eeg_features(k).totalpowerWelch;
        eeg_features(k).betarelativeWelch = eeg_features(k).betaWelch/eeg_features(k).totalpowerWelch;
        
        %delta:alpha
        eeg_features(k).DeltaAlphaRatio = eeg_features(k).deltaWelch/eeg_features(k).alphaWelch;
        
        % BCI
        eeg_features(k).BCI = qEEGBCI(tmp_EEG, Fs);
        
        % Burst Suppression Amplitude ratio
        eeg_features(k).BSAR = qEEGBSAR(tmp_EEG, Fs);
        
        
        
        
        % BS number and BS band powers
        [num_bursts, len_bursts, bursts] = qEEGBurst_supression(tmp_EEG,Fs);
        eeg_features(k).num_bursts = num_bursts;
        eeg_features(k).len_bursts_s = len_bursts;
        eeg_features(k).bursts_del = bursts.delta;
        eeg_features(k).bursts_the = bursts.theta;
        eeg_features(k).bursts_alp = bursts.alpha;
        eeg_features(k).bursts_bet = bursts.beta;
        eeg_features(k).bursts_tot = bursts.total;
        
        % BS relative band power
        eeg_features(k).BSDeltaR =  eeg_features(k).bursts_del/eeg_features(k).bursts_tot;
        eeg_features(k).BSThetaR =  eeg_features(k).bursts_the/eeg_features(k).bursts_tot;
        eeg_features(k).BSAlphaR =  eeg_features(k).bursts_alp/eeg_features(k).bursts_tot;
        eeg_features(k).BSBetaR =  eeg_features(k).bursts_bet/eeg_features(k).bursts_tot;
    end
end

end