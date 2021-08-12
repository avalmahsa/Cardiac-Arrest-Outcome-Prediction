%% eeglab setup
cd '~/EEG'
eeglab_setup

%% Generate object containing processing options of dataset
% full list of files **STATIC

file_list = {
    '83202' '83287' '83312' '83318' '83389' '83609'...
    '83716' '84248' '84402' '84933' '84956' '84981'...
    '84988' '85020' '85178' '85433' '85479' '85777'...
    '85825' '85830' '85896' '86092' '86207' '86232'...
    '86245' '86307' '86476' '86510' '86759' '86936'...
    '87065' '87292' '87490' '87554' '87776' '87879'...
    '88079' '88300' '88312' '88317' '88515' '88636'...
    '88650' '88659' '88699' '88775' '88782' '89015'...
    '89018' '89188' '89312' '89336' '89372' '89381'...
    '89423' '89442' '89691' '89769' '89979' '384'...
    '90159' '90185' '90368' '90450' '90587' '90806'...
    '90811' '91134' '91213' '91345' '91381' '91464'...
    '91470' '91538' '91548' '91592' '91631' '91659'...
    '91775' '91869' '92102' '92135' '92221' '92326'...
    '92528' '92552' '92638' '92860' '92878' '93068'...
    '93103' '93116' '93119' '93283' '93465' '93498'...
    '93502' '93526' '93667' '93696' '93736' '93739'...
    '93884' '93895' '94124' '94126' '94182' '94449'...
    '94517'}';

exclude_bool=true;
preprocessOptions = genPreprocessOptions(file_list, exclude_bool);
artifactOption_def = struct('bc',45,'cc',0.8,'br','on','wc','off','ref_wndlen',1.5);

%% load workspace
% workspace locations
eeg_files_root = '~/EEG/file_processing/';
eeg_filenames = {
    '01-10_only_eeg.mat'
    '11-20_only_eeg.mat'
    '21-30_only_eeg.mat'
    '31-40_only_eeg.mat'
    '41-50_only_eeg.mat'
    '51-60_only_eeg.mat'
    '01-20_only_eeg.mat'
    '01-30_only_eeg.mat'
    '01-50_only_eeg.mat'
    'B2_01-20_only_eeg.mat'
    'B2_21-40_only_eeg.mat'
    'B2_41-60_only_eeg.mat'
    '01-113_only_eeg.mat'
    '01-53_only_eeg.mat'
    '54-113_only_eeg.mat'
    '01-113_only_eeg_split_no_response.mat'
    'Batch1_only_eeg.mat'
    'both_batches_only_eeg.mat'
    'final_files_march_1.mat'
    'final_files_march_1_split.mat'
    'final_files_march_2_split.mat'
    'final_files_march_2_split_finalp.mat'
    '105_preprocessed.mat'
    };

%eeg_workspace = [];
%loads eeg files in eeglab data format into eeg_workspace variable
load([eeg_files_root eeg_filenames{end}]); 
num_files = [1:numel(eeg_workspace)];

for k=num_files
    tmp_EEG = eeg_workspace(k);
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, tmp_EEG);
end
%eeglab redraw

%uncomment only to process specifc files
%num_files = [93 120 126];


%% preprocess eeg
for k=num_files
    
    tmp_EEG = eeg_workspace(k);
   
    %feb 8/2021, updated to get eeg from alleeg struct 
    tmp_EEG = ALLEEG(k);
    
    disp(' ')
    disp(['processing file: ' int2str(k) ' - ' tmp_EEG.setname])
    disp(' ')
    pause(1)
    
    % check for processing options
    tmp_name = strsplit(tmp_EEG.setname,'_');
    tmp_name = tmp_name(1);
    optionMatch = strcmp({preprocessOptions.file},tmp_name);
    
    % if no options and exclude ==true, skip file else process using
    % default criteria or options generated above
    if isempty(preprocessOptions(optionMatch).option)
        if exclude_bool==true
            disp(' processing is set to exclude files')
            disp(['skipping: ' tmp_EEG.setname])
            continue
        end
        
        disp('option not found, using default params');
        pause(2);
        
        preprocessed_EEG = preprocessEEG(tmp_EEG, artifactOption_def);
        
        parm_string = ['BurstCriterion: ' num2str(artifactOption_def.bc)...
            ', ChannelCriterion: ' num2str(artifactOption_def.cc)...
            ', WindowCriterion: ' num2str(artifactOption_def.wc)...
            ', BurstRejection: ' artifactOption_def.br];
        preprocessed_EEG.etc.processing_parms = ['Processed with default options - ' parm_string];
    else
        option =preprocessOptions(optionMatch).option;
        preprocessed_EEG = preprocessEEG(tmp_EEG,option);
        
        parm_string = ['BurstCriterion: ' num2str(option.bc)...
            ', ChannelCriterion: ' num2str(option.cc)...
            ', WindowCriterion: ' num2str(option.wc)...
            ', BurstRejection: ' option.br...
            ', RefWndLen: ' num2str(option.ref_wndlen)];
        preprocessed_EEG.etc.processing_parms = ['Processed with options - ' parm_string];
    end
    
    if isfield(preprocessed_EEG.etc,'len_s') && ~isempty(preprocessed_EEG.etc.len_s)
            preprocessed_EEG.etc.org_len_s = preprocessed_EEG.etc.len_s;
    end
    preprocessed_EEG.etc.len_s = preprocessed_EEG.pnts/preprocessed_EEG.srate;
        
    % update file name for eeglab and store
    preprocessed_EEG.setname = [preprocessed_EEG.setname '_preprocessed'];
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, preprocessed_EEG);
    eeg_workspace(k) = preprocessed_EEG;
    %eeglab redraw
end

%clear eeg_workspace
