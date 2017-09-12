function screenDataMAT(varIN)

ControlParams.FigureNum=1001;
ControlParams.rateColor=[.7 .7 .7];
ControlParams.rasterColor=[.8 .6 .6];


FIG.num=ControlParams.FigureNum;
figure(FIG.num);
FIG=guidata(FIG.num);
if ~isfield(FIG, 'num')
    FIG.num=ControlParams.FigureNum;
end

CodesDir='/media/parida/DATAPART1/Matlab/Screening/';
MATDataDir='/media/parida/DATAPART1/Matlab/SNRenv/n_sEPSM/Codes/MATData/';

if isnumeric(varIN)
    % function that runs when screendataMAT is called the very first time
    ChinID=varIN;
    
    
    addpath(CodesDir);
    
    checkDIR=dir(sprintf('%s*Q%d*',MATDataDir,ChinID));
    if isempty(checkDIR)
        error('No such directory for animal number %d',ChinID);
    elseif length(checkDIR)~=1
        error('Multiple directories. Change!');
    else
        FIG.DataDir=[MATDataDir checkDIR.name];
    end
    
    cd(FIG.DataDir);
    
    %
    FIG.TrackNum=1;
    FIG.UnitNum=1;
    FIG.StopFlag=0;
    FIG.checkRASTER=1;
    FIG.ChinID=ChinID;
    FIG.CheckStop=0;
    
    
    if ~FIG.StopFlag
        FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
        if isempty(FIG.picList)
            if FIG.CheckStop
                FIG.StopFlag=1;
            end
            FIG.TrackNum=FIG.TrackNum+1;
            FIG.UnitNum=1;
            FIG.CheckStop=1;
        else
            FIG.PICnum=FIG.picList(1);
            FIG.numPICsdone=1;
            FIG=ReviewUnitTriggeringMAT(FIG);
        end
    end
    datacursormode(FIG.num);
    
    
elseif ischar(varIN)
    subfunName=varIN;
    if strcmp(subfunName, 'PrevPic_PBcallback')
        
    elseif strcmp(subfunName, 'NextPic_PBcallback')
        cd(FIG.DataDir);
        if ~FIG.StopFlag
            FIG.picList=findPics('*',[FIG.TrackNum,FIG.UnitNum]);
            if isempty(FIG.picList)
                if FIG.CheckStop
                    FIG.StopFlag=1;
                else
                    FIG.TrackNum=FIG.TrackNum+1;
                    FIG.UnitNum=1;
                    FIG.CheckStop=1;
                    
                    guidata(FIG.num, FIG);
                    screenDataMAT('NextPic_PBcallback');
                    FIG=guidata(FIG.num);
                    
                end
                
                
            else
                if FIG.numPICsdone<length(FIG.picList)
                    FIG.numPICsdone=FIG.numPICsdone+1;
                    FIG.PICnum=FIG.picList(FIG.numPICsdone);
                    FIG=ReviewUnitTriggeringMAT(FIG);
                    
                else % Start of a new file
                    FIG.numPICsdone=1; % No need to include TC (assumed that TC is the first file)
                    FIG.UnitNum=FIG.UnitNum+1;
                    FIG.CheckStop=0;
                    
                    guidata(FIG.num, FIG);
                    screenDataMAT('NextPic_PBcallback');
                    FIG=guidata(FIG.num);
                    
                end
            end
            datacursormode(FIG.num);
        else
            fprintf('all units are screened for this unit\n');
            close(FIG.num);
        end
        
    elseif strcmp(subfunName, 'Badlines_Editcallback')
        picStr=get(FIG.handles.BadLineEdit, 'string');
        if sum(isstrprop(picStr,'digit'))
            tempVals=ParseInputString2Num(picStr);
            FIG.badlines(FIG.PICnum).vals=tempVals;
            
            guidata(FIG.num, FIG);
            screenDataMAT('badLinesRemoveReset');
            FIG=guidata(FIG.num);
            
            FIG.badlines(FIG.PICnum).han1=fill_badlines(FIG.handles.rate, tempVals, ControlParams.rateColor);
            FIG.badlines(FIG.PICnum).han2=fill_badlines(FIG.handles.raster, tempVals, ControlParams.rasterColor);
            
        else
            FIG.badlines(FIG.PICnum).vals=nan;
        end
        datacursormode(FIG.num);
        
    elseif strcmp(subfunName, 'badLinesRemoveAccept')
        if ~isfield(FIG.badlines,'Done')
            FIG.badlines=remove_1pic_badline(FIG.ChinID, FIG.PICnum, FIG.badlines, CodesDir, MATDataDir);
        end
        
        
    elseif strcmp(subfunName, 'badLinesRemoveReset')
        if isfield(FIG.badlines(FIG.PICnum),'han1')
            for lNum=1:length(FIG.badlines(FIG.PICnum).han1)
                set(FIG.badlines(FIG.PICnum).han1(lNum).lineHan, 'Visible','off');
            end
            FIG.badlines(FIG.PICnum).han1=[];
        end
        if isfield(FIG.badlines(FIG.PICnum),'han2')
            for lNum=1:length(FIG.badlines(FIG.PICnum).han2)
                set(FIG.badlines(FIG.PICnum).han2(lNum).lineHan, 'Visible','off');
            end
            FIG.badlines(FIG.PICnum).han2=[];
        end
    end
end

if ~ishandle(FIG.num)
    if isfield(FIG,'badlines')
%         badLines=FIG.badlines; %#ok<NASGU>
%         save('reviewOUTPUT.mat', 'badLines');
    end
else
    guidata(FIG.num, FIG);
    figure(FIG.num);
    datacursormode(FIG.num);
end

cd(CodesDir);
