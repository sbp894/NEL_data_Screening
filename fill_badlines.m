function han=fill_badlines(axhan, tempVals, fillColor)

if ~exist('fillColor', 'var')
    fillColor=[.7 .7 .7];
end

xMinMax=axhan.XLim;
yMinMax=axhan.YLim;
hold(axhan, 'on');

han=repmat(struct([]), length(tempVals),1);
for blineVar=1:length(tempVals)
    xFill=[xMinMax(1) xMinMax(1) xMinMax(2) xMinMax(2)];
    yFill=[(tempVals(blineVar))-.5 (tempVals(blineVar))+.5 (tempVals(blineVar))+.5 (tempVals(blineVar))-.5];
    yFill(yFill<yMinMax(1))=yMinMax(1);
    yFill(yFill>yMinMax(2))=yMinMax(2);
    
    han(blineVar).lineHan=fill(axhan, xFill, yFill, 'c', 'facealpha',.75,'LineStyle','none');
    han(blineVar).lineHan.FaceColor=fillColor;
end