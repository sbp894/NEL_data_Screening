function screenData(ChinID)

CodesDir=pwd;
addpath(CodesDir);
NELDataDir='/media/parida/DATAPART1/Matlab/ExpData/NelData/';

checkDIR=dir(sprintf('%s*Q%d*',NELDataDir,ChinID));
if isempty(checkDIR)
    error('No such directory for animal number %d',ChinID);
elseif length(checkDIR)~=1
    error('Multiple directories. Change!');
else
    DataDir=[NELDataDir checkDIR.name];
end

cd(DataDir);

%%
TrackNum=1;
UnitNum=1;
StopFlag=0;
checkRASTER=1;
CheckStop=0; 

%%
while ~StopFlag
    picList=findPics('*',[TrackNum,UnitNum]);
    if isempty(picList)
        if CheckStop
            StopFlag=1;
        end
        TrackNum=TrackNum+1;
        UnitNum=1;
        CheckStop=1;
    else
        ReviewUnitTriggering(TrackNum,UnitNum,checkRASTER);
                
        CheckStop=0;
        UnitNum=UnitNum+1;
    end
end

cd(CodesDir);