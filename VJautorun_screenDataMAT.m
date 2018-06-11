% function VJautorun_screenDataMAT(chinID)

MATdataDIR='/media/parida/DATAPART1/temp/MATdataFromSP/';

allChinIDs=dir(MATdataDIR);

for dirVar=7:length(allChinIDs)
    
    if ~contains(allChinIDs(dirVar).name, '.')
        chinID=cell2mat(cellfun(@(x) sscanf(char(x{1}), '-Q%d*'), regexp(allChinIDs(dirVar).name,'(-Q\d+_)','tokens'), 'UniformOutput', 0));
        VJscreenDataMAT(chinID);
        
        stop_flag=0;
        
        while ~stop_flag
            stop_flag=VJscreenDataMAT('NextPic_PBcallback');
        end
    end
end