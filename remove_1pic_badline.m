% 
% 
% 
function badlines=remove_1pic_badline( chinID, PICnum, badlines, CodesDir, MATDataDir)

checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,chinID));

DataDir=[MATDataDir checkDIR.name];
cd(DataDir);

if ~isfield(badlines,'Done')
    
    if ~isempty(badlines(PICnum).vals)
        curFile=dir(sprintf('p%04d*',PICnum));
        data=load(curFile.name);
        data=data.data;
        curBadLines=sort(badlines(PICnum).vals, 'descend');
        data.Stimuli.bad_lines=badlines(PICnum).vals;
        data.Stimuli.nlines=data.Stimuli.nlines-length(badlines(PICnum).vals);
        data.Stimuli.fully_presented_stimuli=data.Stimuli.fully_presented_stimuli-length(badlines(PICnum).vals);
        data.Stimuli.fully_presented_lines=data.Stimuli.fully_presented_lines-length(badlines(PICnum).vals);
        
        for lineVar=1:length(curBadLines)
            lineNum=curBadLines(lineVar);
            
            fldNames=fieldnames(data.Line.attens);
            for fldVar=1:length(fldNames)
                data.Line.attens.(fldNames{fldVar})(lineNum,:)=nan;
            end
            
            if isfield(data.Line, 'file')
                data.Line.file(lineNum)=nan;
            end
            if isfield(data.Line, 'playback_sampling_rate')
                data.Line.playback_sampling_rate(lineNum)=nan;
            end
            inds=data.spikes{1}(:,1)==lineNum;
            if sum(inds)
                data.spikes{1}(inds,:)=[];
            end
        end
        fprintf('Updated file named %s\n', curFile.name);
        save(curFile.name, 'data')
    end
    
    badlines(PICnum).Done=1;
    
else
    fprintf('badlines have been already removed!\n');
end


cd(CodesDir);