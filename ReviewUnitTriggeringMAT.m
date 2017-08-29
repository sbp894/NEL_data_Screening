function ReviewUnitTriggeringMAT(TrackNum,UnitNum,checkRASTER)
% function ReviewUnitTriggering(Track,Unit)
% Created: M. Heinz 30Dec2005
% For: R03
%
% Goes through all pictures for a unit and reviews: Triggering, Errors, and
% comments

if ~exist('checkRASTER','var')
    checkRASTER=1;
end

picList=findPics('*',[TrackNum,UnitNum]);

for PICnum=picList
    fileCur=dir(sprintf('p%04d_u*',PICnum));
    x=load(fileCur.name);
    x=x.data;
    fprintf('Picture #: %d, filename: %s',PICnum,fileCur.name);
    
    if isfield(x.General,'trigger')
        fprintf('   Trigger: %s',upper(x.General.trigger));
        if sum(strcmp(deblank(x.General.trigger),{'Poor','Fair'}))
            beep
        end
    end
    
    if isfield(x.General,'comment')
        fprintf('   Comment: %s',upper(x.General.comment));
    end
    
    if isfield(x.General,'run_errors')
        for i=1:length(x.General.run_errors)
            if ~sum(strcmp(x.General.run_errors{i}, ...
                    {'In function ''DALinloop_NI_wavfiles'': Input waveform ', ...
                    'has been truncated to fit requested duration. ', ...
                    'has been repeated to fill requested duration. '}))
                fprintf('   Run_errors: %s',x.General.run_errors{i});
            end
        end
    end
    
    if checkRASTER
        if ~strcmp('tc',getTAG(getFileName(PICnum)))
            PICview(PICnum,'')
            [SR_sps,~,~,~] = PIC_calcSR(PICnum);
            fprintf('MEAN SPONT RATE = %.1f sp/sec',SR_sps);
            beep
        end
    end
    

end
return;