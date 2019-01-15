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
    x=load(fileCur.name);

elseif ~isempty(dir(sprintf('%sp%04d*',FIG.NotUsedDIR , FIG.PICnum)))
    FIG.discardedTag= true;
    fileCur=dir(sprintf('%sp%04d*',FIG.NotUsedDIR , FIG.PICnum));
    x=load([FIG.NotUsedDIR  fileCur.name]);

else
    set(FIG.handles.UndoDiscard, 'Enable', 'off');
    set(FIG.handles.discard, 'Enable', 'off');
    error('not found (and need to update logic here)'); 
end

x=x.data;
if isfield(x.Stimuli, 'bad_lines')
    FIG.badlines(FIG.PICnum).vals=x.Stimuli.bad_lines;
end
nComLines=1;
FIG.ComStr=sprintf('Picture #: %d, filename: %s',FIG.PICnum,fileCur.name);

if isfield(x.General,'trigger')
    FIG.trigger=upper(x.General.trigger);
    nComLines=nComLines+1;
    FIG.ComStr=strcat(FIG.ComStr,  sprintf('\nTrigger: %s',upper(x.General.trigger)));
    if sum(strcmp(deblank(x.General.trigger),{'Poor','Fair'}))
        beep
    end
else
    FIG.trigger='---';
end

if isfield(x.General,'comment')
    nComLines=nComLines+1;
    FIG.ComStr=strcat(FIG.ComStr, sprintf('\nComment: %s\n',upper(x.General.comment)));
    FIG.comment_in_pic=x.General.comment;
else
    FIG.comment_in_pic='';
end

if isfield(x.General,'run_errors')
    for i=1:length(x.General.run_errors)
        if ~sum(strcmp(x.General.run_errors{i}, ...
                {'In function ''DALinloop_NI_wavfiles'': Input waveform ', ...
                'has been truncated to fit requested duration. ', ...
                'has been repeated to fill requested duration. '}))
            nComLines=nComLines+1;
            FIG.ComStr=strcat(FIG.ComStr, sprintf('\nRun_errors: %s\n',x.General.run_errors{i}));
        end
    end
end

if checkRASTER
    if ~strcmp('tc',getTAG(getFileName_inDir(FIG)))
        FIG=PICviewMAT(FIG, FIG.PICnum,'', FIG.num);
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
if isfield(x.Line, 'file')
    filesPlayed=cell2mat(cellfun(@(x) ischar(x), x.Line.file', 'uniformoutput', false));
    cleanSpeechInds= find(cell2mat(cellfun(@(x) contains(x, '_S_P'), x.Line.file(filesPlayed)', 'uniformoutput', false)), 1);
    audio_fName= x.Line.file{cleanSpeechInds};
    audio_fName=strrep(audio_fName, 'C:\NEL\', '');
    audio_fName=strrep(audio_fName, '\', filesep);
    audio_fName=strrep(audio_fName, ' ', ''); %remove blankspace at the end
    if exist(audio_fName, 'file')
        calib_fName=getFileName(FIG.calib_PicNum);
        plotYes=0;
        verbose=0;
        [filteredSPL, ~]=CalibFilter_outSPL(audio_fName, calib_fName, plotYes, verbose);
        FIG.dB_SPL= filteredSPL-x.Line.attens.list(find(cleanSpeechInds, 1 ), 2);
        FIG.ComStr=strcat(FIG.ComStr, sprintf('\nIntensity= %.1f dB SPL', FIG.dB_SPL));
    end
end
set(FIG.handles.Comments, 'MAX', nComLines);
set(FIG.handles.Comments, 'string', FIG.ComStr);
return;