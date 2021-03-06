function TrackUnitNum=getTrackUnit(filename)
% function TrackUnitNum=getTrackUnit(filename)
% Created: M. Heinz 18Mar2004
% For: CNexps (GE/MH)
%
% Returns Track and Unit number (TrackUnitNum=[Track,Unit]) from NEL filename 

TrackUnitNum=NaN*ones(1,2);
if ~isempty(filename)
   if strcmp(filename(1),'p')
      Uind=min(strfind(filename,'u'));
      if ~isempty(Uind)
         ULINEinds=strfind(filename,'_');
         TrackUnitNum(1)=str2double(filename(Uind+1:ULINEinds(2)-1));
         TrackUnitNum(2)=str2double(filename(ULINEinds(2)+1:ULINEinds(3)-1));
         return;
      end
   end
end

return;