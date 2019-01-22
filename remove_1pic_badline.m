%
%
%
function badlines=remove_1pic_badline(FIG)

PICnum= FIG.PICnum;
badlines= FIG.badlines;

% checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,chinID));

% if ~isempty(badlines(PICnum).vals)
curFile=dir(sprintf('p%04d*',PICnum));
data=load(curFile.name);
data=data.data;
new_BadLines=sort(badlines(PICnum).vals);

if isfield(data, 'bad_data')
    old_bad_data= data.bad_data;
end
if ~exist('old_bad_data', 'var')
    old_bad_data= [];
end
do_save =1;
%% Different files have different structure format

if contains(curFile.name, '_SR')
    % reset all old_badlines
    if ~isempty(old_bad_data)
        old_BadLines= old_bad_data.BadLines;
        old_badInds= old_bad_data.badInds;
        
        data.Line.attens.None(old_BadLines,:)=old_bad_data.Line.attens.None;
        data.spikes{1}(old_badInds,:)=old_bad_data.spikes;
    end
    
    % then update new bad_inds
    badInds= ismember(data.spikes{1}(:,1), new_BadLines);
    
    data.bad_data.BadLines= new_BadLines;
    data.bad_data.badInds= badInds;
    
    data.bad_data.Line.attens.None= data.Line.attens.None(new_BadLines,:);
    data.Line.attens.None(new_BadLines,:)=nan;
    
    data.bad_data.spikes= data.spikes{1}(badInds,:);
    data.spikes{1}(badInds,:)=nan;
    
    %     data.Stimuli.fully_presented_stimuli= length(unique(data.spikes{1}(~isnan(data.spikes{1}(:,1)),1)));
    %     data.Stimuli.fully_presented_lines= data.Stimuli.fully_presented_stimuli;
    data.bad_data.fully_presented_stimuli= length(unique(data.spikes{1}(~isnan(data.spikes{1}(:,1)),1)));
    
elseif contains(curFile.name, '_RLV')
    % reset all old_badlines
    if ~isempty(old_bad_data)
        old_BadLines= old_bad_data.BadLines;
        old_badInds= old_bad_data.badInds;
        
        data.Line.attens.Tone(old_BadLines,:)=old_bad_data.Line.attens.Tone;
        data.spikes{1}(old_badInds,:)=old_bad_data.spikes;
    end
    
    % then update new bad_inds
    badInds= ismember(data.spikes{1}(:,1), new_BadLines);
    
    data.bad_data.BadLines= new_BadLines;
    data.bad_data.badInds= badInds;
    
    data.bad_data.Line.attens.Tone= data.Line.attens.Tone(new_BadLines,:);
    data.Line.attens.Tone(new_BadLines,:)=nan;
    
    data.bad_data.spikes= data.spikes{1}(badInds,:);
    data.spikes{1}(badInds,:)=nan;
    
    %     data.Stimuli.fully_presented_stimuli= length(unique(data.spikes{1}(~isnan(data.spikes{1}(:,1)),1)));
    %     data.Stimuli.fully_presented_lines= data.Stimuli.fully_presented_stimuli;
    data.bad_data.fully_presented_stimuli= length(unique(data.spikes{1}(~isnan(data.spikes{1}(:,1)),1)));
    
elseif contains(curFile.name, '_SNRenv')
    % reset all old_badlines
    if ~isempty(old_bad_data)
        old_BadLines= old_bad_data.BadLines;
        old_badInds= old_bad_data.badInds;
        
        data.Line.attens.list(old_BadLines,:)=old_bad_data.Line.attens.list;
        data.spikes{1}(old_badInds,:)=old_bad_data.spikes;
        
        % two additional subfields for SNRenv
        data.Line.file(old_BadLines)= data.bad_data.Line.file;
        data.Line.playback_sampling_rate(old_BadLines)= data.bad_data.Line.playback_sampling_rate;
    end
    
    % then update new bad_inds
    badInds= ismember(data.spikes{1}(:,1), new_BadLines);
    
    data.bad_data.BadLines= new_BadLines;
    data.bad_data.badInds= badInds;
    
    data.bad_data.Line.attens.list= data.Line.attens.list(new_BadLines,:);
    data.Line.attens.list(new_BadLines,:)=nan;
    
    data.bad_data.spikes= data.spikes{1}(badInds,:);
    data.spikes{1}(badInds,:)=nan;
    
    %     data.Stimuli.fully_presented_stimuli= length(unique(data.spikes{1}(~isnan(data.spikes{1}(:,1)),1)));
    %     data.Stimuli.fully_presented_lines= data.Stimuli.fully_presented_stimuli;
    data.bad_data.fully_presented_stimuli= length(unique(data.spikes{1}(~isnan(data.spikes{1}(:,1)),1)));
    
    % two additional subfields for SNRenv
    data.bad_data.Line.file= data.Line.file(new_BadLines);
    data.Line.file(new_BadLines)={''};
    
    data.bad_data.Line.playback_sampling_rate= data.Line.playback_sampling_rate(new_BadLines);
    data.Line.playback_sampling_rate(new_BadLines)=nan;
else
    do_save= 0;
    warning('Haven''t figured out how to remove badlines for this pic-file type\n');
end

if false
    for lineVar=1:length(new_BadLines)
        lineNum=new_BadLines(lineVar);
        
        if contains(curFile.name, '_SR')
            % SR
            %         data.Line.attens.None(lineNum,:)=nan;
            %         badline_spike_inds= data.spikes{1}(:,1)==lineNum;
            %         if sum(badline_spike_inds)
            %             data.spikes{1}(badline_spike_inds,:)=nan;
            %         end
        elseif contains(curFile.name, '_RLV') % RLF
            %         if lineVar==1 % Need to do it once, so the first time
            %             data.Stimuli.fully_presented_stimuli=data.Stimuli.fully_presented_stimuli-length(badlines(PICnum).vals);
            %             data.Stimuli.fully_presented_lines=data.Stimuli.fully_presented_lines-length(badlines(PICnum).vals);
            %         end
            %         data.Line.attens.Tone(lineNum,:)=nan;
            %         badline_spike_inds= data.spikes{1}(:,1)==lineNum;
            %         if sum(badline_spike_inds)
            %             data.spikes{1}(badline_spike_inds,:)=nan;
            %         end
            
        elseif contains(curFile.name, '_SNRenv') % RLF
            %         if lineVar==1 % Need to do it once, so the first time
            %             data.Stimuli.fully_presented_stimuli=data.Stimuli.fully_presented_stimuli-length(badlines(PICnum).vals);
            %             data.Stimuli.fully_presented_lines=data.Stimuli.fully_presented_lines-length(badlines(PICnum).vals);
            %         end
            %         data.Line.attens.list(lineNum,:)=nan;
            data.Line.file{lineNum}=nan;
            data.Line.playback_sampling_rate(lineNum)=nan;
            
            %         badline_spike_inds= data.spikes{1}(:,1)==lineNum;
            %         if sum(badline_spike_inds)
            %             data.spikes{1}(badline_spike_inds,:)=nan;
            %         end
            
        else
            % Do nothing.
            do_save= 0;
            warning('Haven''t figured out how to remove badlines for this pic-file type\n');
        end
        
    end
end


%% SNRenv
if do_save
    fprintf('Updated (NAN for badlines) file named %s\n', curFile.name);
    save(curFile.name, 'data');
end