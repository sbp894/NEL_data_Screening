%
%
%
function badlines=remove_1pic_badline(chinID, PICnum, badlines, CodesDir, MATDataDir)

checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,chinID));

DataDir=[MATDataDir checkDIR.name];
cd(DataDir);

if ~isempty(badlines(PICnum).vals)
    curFile=dir(sprintf('p%04d*',PICnum));
    data=load(curFile.name);
    data=data.data;
    curBadLines=sort(badlines(PICnum).vals, 'descend');
    
    %% Different files have different structure format
    
    for lineVar=1:length(curBadLines)
        lineNum=curBadLines(lineVar);
        
        if contains(curFile.name, '_SR')
            % SR
            data.Line.attens.None(lineNum,:)=nan;
            badline_spike_inds= data.spikes{1}(:,1)==lineNum;
            if sum(badline_spike_inds)
                data.spikes{1}(badline_spike_inds,:)=nan;
            end
        elseif contains(curFile.name, '_RLV') % RLF
            if lineVar==1 % Need to do it once, so the first time
                data.Stimuli.fully_presented_stimuli=data.Stimuli.fully_presented_stimuli-length(badlines(PICnum).vals);
                data.Stimuli.fully_presented_lines=data.Stimuli.fully_presented_lines-length(badlines(PICnum).vals);
            end
            data.Line.attens.Tone(lineNum,:)=nan;
            badline_spike_inds= data.spikes{1}(:,1)==lineNum;
            if sum(badline_spike_inds)
                data.spikes{1}(badline_spike_inds,:)=nan;
            end
            
        elseif contains(curFile.name, '_SNRenv') % RLF
            if lineVar==1 % Need to do it once, so the first time
                data.Stimuli.fully_presented_stimuli=data.Stimuli.fully_presented_stimuli-length(badlines(PICnum).vals);
                data.Stimuli.fully_presented_lines=data.Stimuli.fully_presented_lines-length(badlines(PICnum).vals);
            end
            data.Line.attens.list(lineNum,:)=nan;
            data.Line.file{lineNum}=nan;
            data.Line.playback_sampling_rate(lineNum)=nan;
            
            badline_spike_inds= data.spikes{1}(:,1)==lineNum;
            if sum(badline_spike_inds)
                data.spikes{1}(badline_spike_inds,:)=nan;
            end
            
        else
            % Do nothing.
            warning('Haven''t figured out how to remove badlines for this pic-file type\n');
        end
        
    end
    
    
    
    %% SNRenv
    fprintf('Updated (NAN for badlines) file named %s\n', curFile.name);
    save(curFile.name, 'data');
end

cd(CodesDir);