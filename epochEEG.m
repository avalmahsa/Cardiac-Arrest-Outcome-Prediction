function out = epochEEG(EEG,varargin) 
%uses boundary events (added in processing) to find continuous segment
%and returns longest interval 

    

    if size(EEG,2) > 1
        out = [];
        for n=1:size(EEG,2)
            out(n,1:2) = epochEEG(EEG(n),varargin{:});
        end
        return
    end
    
    if nargin > 2
        min_points = varargin{1};
        MAX_BOUNDARY = varargin{2};
    elseif nargin > 1
        min_points = varargin{1};
        MAX_BOUNDARY = 0;
    else
        MAX_BOUNDARY = 0;
    end
    
    
    events = EEG.event;
    events = events(strcmp({events.type}, 'boundary'));
    num_epochs = numel(events) + 1;
    
    epochs = struct();
    insert_idx = 1;
    for i=1:num_epochs
        %% updates to account for "MAX_BOUNDARY"
        % while no epoch found of min length
        % add one to end inex and check again
        % when indexs == MAX_BOUNDARY break loop anbd go to next for loop
        % (new start index)
        
        % current number of boundaries to include, resets to 0 for new
        % epoch and increments until a boundary of len min_points is found
        boundaries = 0;
        
        while boundaries <= MAX_BOUNDARY
        
            if i == 1
               start_range = 1;
            else
                start_range = events(i-1).latency;
            end

            if (i+boundaries)>=num_epochs
                end_range = EEG.pnts;
            else
                end_range = events(i+boundaries).latency;
            end

            range_length = end_range-start_range;

            if (~exist('min_points','var')) || (range_length > min_points)
                % if epoch found, save, break while
                % add boundary counter
                epochs(insert_idx).Epoch = i;
                epochs(insert_idx).range = [start_range end_range];
                epochs(insert_idx).latency_len = range_length;
                epochs(insert_idx).seconds_len = range_length/EEG.srate;
                epochs(insert_idx).BoundariesInRange = boundaries;
                insert_idx = insert_idx+1;
            end
            boundaries = boundaries + 1;
        end
    end
    
    out=-1;
    if contains(EEG.setname,'preprocessed')
        % update printout for max boundary, points
        if length( fieldnames(epochs)) < 2
            
            warning(['file ' EEG.setname ' no epochs of min length: ' num2str(min_points) ', total file is: ' num2str(EEG.pnts/EEG.srate)]);
            out=-1;
        else
%             [~,sort_idx] = sort([epochs.latency_len],'descend');
%             epochs = epochs(sort_idx);
            epochs = struct2table(epochs);
            epochs = sortrows(epochs, [5 -3]); % sorts boundaries ascending, len descending
            
            fprintf('file %s largest epoch is #%d, %.2f sec long, with %d boundaries',EEG.setname,epochs{1,'Epoch'},epochs{1,'seconds_len'},epochs{1,'BoundariesInRange'});
        %disp([num2str(epochs(1).range(1)) ' to ' num2str(epochs(1).range(2)) newline])
        %% update to return longest with least boundary events!!
        
            out = epochs{1,'range'};
        end
        if isfield(EEG.etc,'processing_parms')
            disp(['    >> ' EEG.etc.processing_parms]);
        else
            disp('    >> Unprocessed File');
        end
    end
end


