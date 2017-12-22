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
x=load(fileCur.name);
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
    if ~strcmp('tc',getTAG(getFileName(FIG.PICnum)))
        FIG=PICviewMAT(FIG, FIG.PICnum,'', FIG.num);
        [SR_sps,~,~,~] = PIC_calcSR(FIG.PICnum);
        nComLines=nComLines+1;
        FIG.ComStr=strcat(FIG.ComStr, sprintf('\nMEAN SPONT RATE = %.1f sp/sec\n',SR_sps));
        beep
    else
        guidata(FIG.num, FIG);
        screenDataMAT('NextPic_PBcallback');
        FIG=guidata(FIG.num);
    end
end


set(FIG.handles.Comments, 'MAX', nComLines);
set(FIG.handles.Comments, 'string', FIG.ComStr);
return;