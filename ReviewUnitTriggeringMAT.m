function FIG=ReviewUnitTriggeringMAT(FIG)
% FIG=ReviewUnitTriggeringMAT(FIG)
% Created: SP (Aug 2017)
% Called from screenDataMAT
% Original function: ReviewUnitTriggering(Track,Unit)
% Created: M. Heinz 30Dec2005
%
% Goes through all pictures for a unit and reviews: Triggering, Errors, and
% comments

checkRASTER=FIG.checkRASTER;

fileCur=dir(sprintf('p%04d*',FIG.PICnum));

if ~isempty(fileCur)
    FIG.discardedTag= false;
    data=load(fileCur.name);

elseif ~isempty(dir(sprintf('%sp%04d*',FIG.NotUsedDIR , FIG.PICnum)))
    FIG.discardedTag= true;
    fileCur=dir(sprintf('%sp%04d*',FIG.NotUsedDIR , FIG.PICnum));
    data=load([FIG.NotUsedDIR  fileCur.name]);

else
    set(FIG.handles.UndoDiscard, 'Enable', 'off');
    set(FIG.handles.discard, 'Enable', 'off');
    error('not found (and need to update logic here)'); 
end

data=data.data;

if isfield(data.Stimuli, 'bad_lines')
    FIG.badlines(FIG.PICnum).vals=data.Stimuli.bad_lines;
end

if ~isfield(data, 'screening')
    data.screening.refract_check_tag= false;
    data.screening.refract_violate_percent= nan;
    if ~FIG.discardedTag % not discarded 
        save(fileCur.name, 'data'); 
    else 
        save([FIG.NotUsedDIR fileCur.name], 'data'); 
    end
end

%% uncomment this.
% Should add badlines when data collection was stopped in the middle of
% stim ON duration and some spikes were recorded for that line number. 
% org_bad_inds= unique(x.spikes{1}(((x.spikes{1}(:,1))>x.Stimuli.fully_presented_stimuli), 1));
% if ~isempty(org_bad_inds)
%     FIG.badlines(FIG.PICnum).vals= [FIG.badlines(FIG.PICnum).vals, org_bad_inds];
% end

%%
nComLines=1;
FIG.ComStr=sprintf('Picture #: %d, filename: %s',FIG.PICnum,fileCur.name);

if isfield(data.General,'trigger')
    FIG.trigger=upper(data.General.trigger);
    nComLines=nComLines+1;
    FIG.ComStr=strcat(FIG.ComStr,  sprintf('\nTrigger: %s',upper(data.General.trigger)));
    if sum(strcmp(deblank(data.General.trigger),{'Poor','Fair'}))
        beep
    end
else
    FIG.trigger='---';
end

if isfield(data.General,'comment')
    nComLines=nComLines+1;
    FIG.ComStr=strcat(FIG.ComStr, sprintf('\nComment: %s\n',upper(data.General.comment)));
    FIG.comment_in_pic=data.General.comment;
else
    FIG.comment_in_pic='';
end

if isfield(data.General,'run_errors')
    if numel(data.General.run_errors)<=2
        for i=1:length(data.General.run_errors)
            if ~sum(strcmp(data.General.run_errors{i}, ...
                    {'In function ''DALinloop_NI_wavfiles'': Input waveform ', ...
                    'has been truncated to fit requested duration. ', ...
                    'has been repeated to fill requested duration. '}))
                nComLines=nComLines+1;
                FIG.ComStr=strcat(FIG.ComStr, sprintf('\nRun_errors: %s\n',data.General.run_errors{i}));
            end
        end
    else
        nComLines=nComLines+1;
        FIG.ComStr=strcat(FIG.ComStr, sprintf('\nToo many lines in run_error. See command window.\n'));
        fprintf('Run-Errors for fine %s \n ----------------------------------------\n ', fileCur.name);
        cellfun(@(x) fprintf('%s\n', x), data.General.run_errors, 'UniformOutput', false)
    end
end

if checkRASTER
    if ~strcmp('tc',getTAG(getFileName_inDir(FIG)))
        % Should exclude if risky-do-nan has been pushed. Otherwise (i.e.
        % if just labelled), htne should not exclude plotting. 

        FIG=PICviewMAT(FIG, FIG.PICnum, FIG.num);
        if FIG.discardedTag % means discarded
            set(FIG.handles.UndoDiscard, 'Enable', 'on');
            set(FIG.handles.discard, 'Enable', 'off');
        else % means exists in main data dir
            set(FIG.handles.UndoDiscard, 'Enable', 'off');
            set(FIG.handles.discard, 'Enable', 'on');
        end
        
        [SR_sps,~,~,~] = PIC_calcSR(FIG.PICnum);
        nComLines=nComLines+1;
        FIG.ComStr=strcat(FIG.ComStr, sprintf('\nMEAN SPONT RATE = %.1f sp/sec\nCF=%.1f kHz : %c=%.1f dB SPL : Q10=%.1f',SR_sps, FIG.TCdata.BF_kHz, char(920), FIG.TCdata.Thresh_dBSPL, FIG.TCdata.Q10));
        beep
    else
        guidata(FIG.num, FIG);
        screenDataMAT('NextPic_PBcallback');
        FIG=guidata(FIG.num);
    end
end
if isfield(data.Line, 'file')
    filesPlayed=cell2mat(cellfun(@(x) ischar(x), data.Line.file', 'uniformoutput', false));
    cleanSpeechInds= find(cell2mat(cellfun(@(x) contains(x, {'_S_P', 'RAW_pos'}), data.Line.file(filesPlayed)', 'uniformoutput', false)), 1);
    if ~isempty(cleanSpeechInds) % works only for speech stims that SP played 
        audio_fName= data.Line.file{cleanSpeechInds};
        audio_fName=strrep(audio_fName, 'C:\NEL\', '');
        audio_fName=strrep(audio_fName, '\', filesep);
        audio_fName=strrep(audio_fName, ' ', ''); %remove blankspace at the end
        if exist(audio_fName, 'file')
            calib_fName=getFileName(FIG.calib_PicNum);
            plotYes=0;
            verbose=0;
            [filteredSPL, ~]=CalibFilter_outSPL(audio_fName, calib_fName, plotYes, verbose);
            FIG.dB_SPL= filteredSPL-data.Line.attens.list(find(cleanSpeechInds, 1 ), 2);
            FIG.ComStr=strcat(FIG.ComStr, sprintf('\nIntensity= %.1f dB SPL', FIG.dB_SPL));
        end
    end
end
set(FIG.handles.Comments, 'MAX', nComLines);
set(FIG.handles.Comments, 'string', FIG.ComStr);
return;