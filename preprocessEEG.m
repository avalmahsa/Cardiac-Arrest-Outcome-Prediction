function EEG_out = preprocessEEG(EEG,options)

%% insert channel locations
EEG = pop_chanedit(EEG,'lookup','standard-10-5-cap385.elp');

%% keep only the desired channels
keep_channels = {
    'EEG Fp1-REF'
    'EEG Fp2-REF'
    'EEG F3-REF' 
    'EEG F4-REF' 
    'EEG C3-REF'
    'EEG C4-REF'
    'EEG P3-REF'
    'EEG P4-REF'
    'EEG O1-REF'
    'EEG O2-REF'
    'EEG F7-REF'
    'EEG F8-REF'
    'EEG T3-REF'
    'EEG T4-REF'
    'EEG T5-REF'
    'EEG T6-REF'
    'EEG Fz-REF'
    'EEG Cz-REF'
    'EEG Pz-REF'};
EEG = pop_select(EEG,'channel',keep_channels);

%% filtering
EEG = pop_eegfiltnew(EEG, 0.5, [], [], false, [], 0); %high pass filter
EEG = pop_eegfiltnew(EEG, [], 70, [], false, [], 0); %low pass filter

%% remove line noise (60 Hz)
EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:EEG.nbchan],...
    'computepower',1,'legacy',0,'linefreqs',60,'normSpectrum',0,'p',0.01,...
    'pad',2,'plotfigures',0,'scanforlines',0,'sigtype','Channels',...
    'taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);

%% Artefact removal
originalEEG = EEG;
if ~isfield(options,'ref_wndlen'), options.ref_wndlen=[]; end
EEG = clean_artifacts(EEG, 'FlatlineCriterion',5,'ChannelCriterion',options.cc,...
    'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',options.bc,...
    'BurstRejection',options.br,'WindowCriterion',options.wc,...
    'RefWindowCriterion',options.ref_wndlen);
% compare before and after
%vis_artifacts(EEG,originalEEG);

%% interpolate channels
EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');

%% average reference
% add zero line for FCz
EEG.nbchan = EEG.nbchan+1;
EEG.data(end+1,:) = zeros(1, EEG.pnts);
EEG.chanlocs(1,EEG.nbchan).labels = 'FCz';
%avg ref
EEG = pop_reref(EEG, [], 'exclude',[1 2]);
%delete old ref
EEG = pop_select( EEG,'nochannel',{'FCz'});

%return file
EEG_out = EEG;
end
