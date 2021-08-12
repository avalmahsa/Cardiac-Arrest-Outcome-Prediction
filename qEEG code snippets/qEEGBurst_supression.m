function [ num_bursts len_bursts bursts ] = qEEGBurst_supression(tmp_EEG, Fs)

    eeg_chan = struct('channel',[], 'feat', [],'org_set', []);


    for j=1:tmp_EEG.nbchan
        x = tmp_EEG.data(j,:);
        x = double(x);
        
        supression_threshold = 10;

        % DETECT EMG ARTIFACTS.
        [be ae] = butter(6, [30 49]./(Fs/2)); % bandpass filter
        demg=filtfilt(be,ae,x);
        i0=1; i1=1; ct=0; dn=0;
        Nt = size(x,2);
        chunkSize = 5; % 5 second chunks
        a = zeros(1,Nt);
        while ~dn
            %% get next data chunk
            i0=i1;
            if i1 == Nt
                dn=1;
            end

            i1=i0+round(Fs*chunkSize);
            i1=min(i1,Nt);
            i01=i0:i1;
            ct=ct+1; % get next data chunk

            A(ct)=0; % set to 1 if artifact is detected
            de=demg(:,i01);

            %% check for emg artifact
            v=std(de);
            if v > 5
                A(ct)=1;
            end
            a(i01)=A(ct);
        end

        % CALCULATE ENVELOPE
        e = abs(hilbert(x));
        ME = smooth(e,Fs/4); % apply 1/2 second smoothing
        e = ME;

        % DETECT SUPRESSIONS
        % apply threshold -- 10uv
        z = (ME<supression_threshold);
        % remove too-short suppression segments
        z = fcnRemoveShortEvents(z,Fs/2);
        % remove too-short burst segments
        b = fcnRemoveShortEvents(1-z,Fs/2);
        z = 1-b;
        z = z';

        %% RUN 'BS' ALGORITHM
        went_low  = find((z(1:end-1) == 0) & (z(2:end) == 1));
        went_high  = find((z(1:end-1) == 1) & (z(2:end) == 0));
        if isempty(went_low) || isempty(went_high)
            bur = [];
            sup = [];
        else
            starting = went_high(1) < went_low(1);

            if(starting == 0)
                bur =  [[1, went_high(1:length(went_low)-1)]; went_low]';
                sup = [went_low(1:length(went_high)); went_high]';
            end

            if(starting == 1)
                sup =  [[1, went_low(1:length(went_high)-1)]; went_high]';
                bur = [went_high(1:length(went_low)); went_low]';
            end
            
            
        end
        
        
        
        %further feature generation using bur and sup
        if isempty(bur) || isempty(sup) || size(bur,2) < 2
            %deal witrh setting n/a / missing values for returned vars
            eeg_chan(j).delta = 0;
            eeg_chan(j).theta = 0;
            eeg_chan(j).alpha = 0;
            eeg_chan(j).beta = 0;
            eeg_chan(j).total = 0;
            eeg_chan(j).len_bursts = [];
        else
            % band power for bursts, loop through bursts
            for i = 1:size(bur,1)
                this_burst = x(bur(i,1):bur(i,2));
                del(i) = bandpower(this_burst,Fs,[1,4]);
                the(i) = bandpower(this_burst,Fs,[4,7]);
                alp(i) = bandpower(this_burst,Fs,[8,15]);
                bet(i) = bandpower(this_burst,Fs,[16,31]);
                tot(i) = bandpower(this_burst,Fs,[1,20]);

            end
            % avg all bursts to 1 val per chan
            eeg_chan(j).delta = mean(del);
            eeg_chan(j).theta = mean(the);
            eeg_chan(j).alpha = mean(alp);
            eeg_chan(j).beta = mean(bet);
            eeg_chan(j).total = mean(tot);
            
            eeg_chan(j).len_bursts = mean(bur(:,2)-bur(:,1))/Fs;
        end
        
        eeg_chan(j).num_bursts = size(bur,1);
        eeg_chan(j).channel = j;
        eeg_chan(j).org_set = tmp_EEG.setname;
    end

    % avg all feats across all chans  
    num_bursts = mean([eeg_chan.num_bursts]);
    len_bursts = mean([eeg_chan.len_bursts]);
    bursts.delta = mean([eeg_chan.delta]);
    bursts.theta = mean([eeg_chan.theta]);
    bursts.alpha = mean([eeg_chan.alpha]);
    bursts.beta = mean([eeg_chan.beta]);
    bursts.total = mean([eeg_chan.total]);
    
end

