function screenDataMAT(varIN)
global FIG;
CodesDir='/media/parida/DATAPART1/Matlab/Screening/';
MATDataDir='/media/parida/DATAPART1/Matlab/SNRenv/n_sEPSM/Codes/MATData/';

if isnumeric(varIN)
    FIG=[];
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
            ReviewUnitTriggeringMAT();
        end
    end
    
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
                    screenDataMAT('NextPic_PBcallback');
                end
                
                
            else
                if FIG.numPICsdone<length(FIG.picList)
                    FIG.numPICsdone=FIG.numPICsdone+1;
                    FIG.PICnum=FIG.picList(FIG.numPICsdone);
                    ReviewUnitTriggeringMAT();
                    
                else % Start of a new file
                    FIG.numPICsdone=1; % No need to include TC (assumed that TC is the first file)
                    FIG.UnitNum=FIG.UnitNum+1;
                    FIG.CheckStop=0;
                    screenDataMAT('NextPic_PBcallback');
                end
            end
        else
            fprintf('all units are screened for this unit\n');
            close(FIG.num);
        end
        
    elseif strcmp(subfunName, 'Badlines_Editcallback')
        
    end
end

cd(CodesDir);
