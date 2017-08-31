function ReviewUnitTriggeringMAT
% function ReviewUnitTriggering(Track,Unit)
% Created: M. Heinz 30Dec2005
% For: R03
%
% Goes through all pictures for a unit and reviews: Triggering, Errors, and
% comments
global FIG;
checkRASTER=FIG.checkRASTER;

fileCur=dir(sprintf('p%04d*',FIG.PICnum));
x=load(fileCur.name);
x=x.data;
nComLines=1;
FIG.ComStr=sprintf('Picture #: %d, filename: %s',FIG.PICnum,fileCur.name);

if isfield(x.General,'trigger')
    nComLines=nComLines+1;
    FIG.ComStr=strcat(FIG.ComStr,  sprintf('\nTrigger: %s',upper(x.General.trigger)));
    if sum(strcmp(deblank(x.General.trigger),{'Poor','Fair'}))
        beep
    end
end

if isfield(x.General,'comment')
    nComLines=nComLines+1;
    FIG.ComStr=strcat(FIG.ComStr, sprintf('\nComment: %s\n',upper(x.General.comment)));
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
        FIG=PICviewMAT(FIG, FIG.PICnum,'');
        [SR_sps,~,~,~] = PIC_calcSR(FIG.PICnum);
        nComLines=nComLines+1;
        FIG.ComStr=strcat(FIG.ComStr, sprintf('\nMEAN SPONT RATE = %.1f sp/sec\n',SR_sps));
        beep
    else
        screenDataMAT('NextPic_PBcallback');
    end
end

%     input('Press Enter to move to next PICTURE');


%         badlines=inputdlg('Enter space-separated bad lines','Data Screening');
%         badlines=str2double(badlines{:});
%         if isempty(badlines)
%
%         else
%             BadLinesMat(picList==PICnum).PICnum=PICnum;
%             BadLinesMat(picList==PICnum).badlines=badlines;
%         end

set(FIG.handles.Comments, 'MAX', nComLines);
set(FIG.handles.Comments, 'string', FIG.ComStr);
return;