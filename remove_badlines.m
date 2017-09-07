function remove_badlines(chinID)

CodesDir='/media/parida/DATAPART1/Matlab/Screening/';
MATDataDir='/media/parida/DATAPART1/Matlab/SNRenv/n_sEPSM/Codes/MATData/';

checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,chinID));

DataDir=[MATDataDir checkDIR.name];
cd(DataDir);

if exist('reviewOUTPUT.mat', 'file')
    load('reviewOUTPUT.mat');
    if ~isfield(badLines,'Done') %#ok<NODEF>
        for PICnum=1:length(badLines)
            if ~isempty(badLines(PICnum).vals)
                curFile=dir(sprintf('p%04d*',PICnum));
                data=load(curFile.name);
                data=data.data;
                curBadLines=sort(badLines(PICnum).vals, 'descend');
                for lineNum=curBadLines'
                    
                    data.Stimuli.bad_lines=badLines(PICnum).vals;
                    data.Stimuli.nlines=data.Stimuli.nlines-length(badLines(PICnum).vals);
                    data.Stimuli.fully_presented_stimuli=data.Stimuli.fully_presented_stimuli-length(badLines(PICnum).vals);
                    data.Stimuli.fully_presented_lines=data.Stimuli.fully_presented_lines-length(badLines(PICnum).vals);
                    
                    fldNames=fieldnames(data.Line.attens);
                    for fldVar=1:length(fldNames)
                        data.Line.attens.(fldNames{fldVar})(lineNum,:)=[];
                    end
                    
                    if isfield(data.Line, 'file')
                        data.Line.file(lineNum)=[];
                    end
                    if isfield(data.Line, 'playback_sampling_rate')
                        data.Line.playback_sampling_rate(lineNum)=[];
                    end
                    inds=data.spikes{1}(:,1)==lineNum;
                    if sum(inds)
                        data.spikes{1}(inds,:)=[];
                    end
                end
                fprintf('Updated file named %s\n', curFile.name);
                %                 save(curFile.name, 'data')
            end
            
        end
        
        badLines(end).Done=1;
        [badLines.Done]=deal(1);
        save('reviewOUTPUT.mat', 'badLines');
        
    else
        fprintf('badlines have been already removed!\n');
    end
else
    fprintf('This animal has not been screened. Use the function screenDataMAT. \n');
end

cd(CodesDir);