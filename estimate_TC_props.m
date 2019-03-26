function [bf_freq, bf_thresh]= estimate_TC_props(tc_data, freq, plotYes)

if ~exist('plotYes', 'var')
    plotYes= true;
end

txtSize= 16;

[~, inds]= sort(freq);
freq= freq(inds);
tc_data= tc_data(inds);

tx.x=min(freq);
tx.y=max(tc_data);

maxMisMatch= 20; % in dB
nearMismatchThresh=10;
% Ident_Slope=3;
Ident_Mismatch=3; % consider a point X as candidate if thresh_P within <Ident_Mismatch> of the lowest thresh (theta_l)
% and (?? at least one point b/w the point with lowest thresh and X has
% higher thresh than min(theta_l, thresh_P), should we add this??)
MinPeakDistance= 10; % 10 points
MinPeakProminence= maxMisMatch/3;
MinPeakWidth= 3;
freqSeparationThresh=1.25;
slopeRatioThresh= 1.5;
threshNForSlopeFitting=5;

[~, locs]= min(tc_data);
if length(tc_data)<MinPeakDistance+2
    bf_freq= nan;
    bf_thresh= nan;
    return;
end
[~, temp_locs1]= findpeaks(-tc_data, 'MinPeakDistance', MinPeakDistance, 'MinPeakProminence', MinPeakProminence, 'MinPeakWidth', MinPeakWidth); % compute candidate bfs w/ certain criteria
locs= [locs; setdiff(temp_locs1, locs)];

% check low and high freq edges
if min(tc_data(1:MinPeakDistance))<min(tc_data(locs))
    [~, lower_loc]= min(tc_data(1:MinPeakDistance));
    locs= [lower_loc; locs];
end
locs= unique(locs);

% shift candidates to slightly higher CFs if their thresh is
% <Ident_Mismatch apart
[~, temp_locs2]= findpeaks(-tc_data);
temp_locs2= setdiff(temp_locs2, locs);

for candVar= 1:length(locs)
    temp_locs3= temp_locs2;
    temp_locs3(temp_locs3<locs(candVar))=[];
    temp_locs3(tc_data(temp_locs3)>tc_data(locs(candVar))+Ident_Mismatch)=[];
    if ~isempty(temp_locs3)
        locs(candVar)=temp_locs3(end); % update the point with min thresh
    end
end

locs= unique(locs);

% plotting props
lw2=1.5;
lw3=2;
lw4= 2;
lw5= 2;

mrkSize= 12;
mrkSize2= 3;
mrkSize3= 4;
mrkSize4= 5;

hold on;
plot(freq, tc_data, '-', 'linew', lw2, 'marker', '.', 'markersize', mrkSize);
plot(freq(locs), tc_data(locs), '*g', 'linew', lw4, 'markersize', mrkSize2);

% remove all points with thresh above (maxMisMatch above min thresh).
locs(tc_data(locs)>min(tc_data(locs))+maxMisMatch)=[];

% remove a point if there exists a candidate with higher CF and lower thresh
for candVar= 1:length(locs)-1
    if sum(tc_data(locs(candVar+1:end)) < tc_data(locs(candVar)))
        locs(candVar)= nan;
    end
end

locs(isnan(locs))=[];
plot(freq(locs), tc_data(locs), 'oc', 'linew', lw4, 'markersize', mrkSize3);
slopesVals= nan(length(locs),1);
nPointsForHFslope= nan(length(locs),1);
for candVar=length(locs):-1:1 % backwards because the last candidate is the most probable, and has a red * => second line should be red
    inds2use= locs(candVar):length(freq);
    
    
    [theta, yFit, numPointsSlope1]= tc_piecewise_lin_interp_mod_cost(freq(inds2use), tc_data(inds2use));
    
    slopesVals(candVar)= theta(3);
    nPointsForHFslope(candVar)= numPointsSlope1;
    
    plot(freq(inds2use), tc_data(inds2use), 'k--', 'linew', lw2);
    plot(freq(inds2use), yFit, 'linew', lw3);
end


if numel(locs)>1
    if slopesVals(end)/max([0; slopesVals(1:end-1)])>slopeRatioThresh && freq(locs(end))/max(freq(locs(1:end-1)))>freqSeparationThresh ...
            && min(tc_data(locs(1:end-1)))-tc_data(locs(end))>-nearMismatchThresh && nPointsForHFslope(end)>threshNForSlopeFitting
        % means freqs are apart and the last candidate slope is bigger,
        % pick the last one
        if plotYes
            plot(freq(locs(end)), tc_data(locs(end)), '*r', 'linew', lw5, 'markersize', mrkSize4);
            text(freq(locs(end))+.2, 1, sprintf('CF=%.1f kHz', freq(locs(end))), 'fontsize', txtSize);
            text(min(freq), tc_data(locs(end))-1, sprintf('Thresh=%.1f dB', tc_data(locs(end))), 'fontsize', txtSize);
            text(tx.x, tx.y,'reason: clear', 'fontsize', txtSize);
        end
        exitFlag= 1;
    elseif freq(locs(end))/max(freq(locs(1:end-1)))>freqSeparationThresh && abs(tc_data(locs(end))-min(tc_data(locs(1:end-1))))<nearMismatchThresh ...
            && nPointsForHFslope(end)>threshNForSlopeFitting
        % means frequencies are decently apart, thresholds are similar, so
        % pick the second one
        if plotYes
            plot(freq(locs(end)), tc_data(locs(end)), '*r', 'linew', lw5, 'markersize', mrkSize4);
            text(freq(locs(end))+.2, 1, sprintf('CF=%.1f kHz', freq(locs(end))), 'fontsize', txtSize);
            text(min(freq), tc_data(locs(end))-1, sprintf('Thresh=%.1f dB', tc_data(locs(end))), 'fontsize', txtSize);
            text(tx.x, tx.y,'reason: simThresh and apartFreq', 'fontsize', txtSize);
        end
        exitFlag= 1;
    elseif slopesVals(end)/max([0; slopesVals(1:end-1)])>slopeRatioThresh && freq(locs(end))/max(freq(locs(1:end-1)))>freqSeparationThresh ...
            && nPointsForHFslope(end)>threshNForSlopeFitting
        % means freqs are apart and the last candidate slope is bigger,
        % pick the last one
        if plotYes
            plot(freq(locs(end)), tc_data(locs(end)), '*r', 'linew', lw5, 'markersize', mrkSize4);
            text(freq(locs(end))+.2, 1, sprintf('CF=%.1f kHz', freq(locs(end))), 'fontsize', txtSize);
            text(min(freq), tc_data(locs(end))-1, sprintf('Thresh=%.1f dB', tc_data(locs(end))), 'fontsize', txtSize);
            text(tx.x, tx.y,'reason: betterSlope (not noisy), apartFreq', 'fontsize', txtSize);
        end
        exitFlag= 1;
    else
        if plotYes
            text(tx.x, tx.y, 'Confusing!', 'fontsize', txtSize);
        end
        exitFlag= 0;
    end
elseif numel(locs)==1
    if plotYes
        plot(freq(locs(end)), tc_data(locs(end)), '*r', 'linew', lw5, 'markersize', mrkSize4);
        text(freq(locs(end))+.2, 1, sprintf('CF=%.1f kHz', freq(locs(end))), 'fontsize', txtSize);
        text(min(freq), tc_data(locs(end))-1, sprintf('Thresh=%.1f dB', tc_data(locs(end))), 'fontsize', txtSize);
        text(tx.x, tx.y,'reason: clear', 'fontsize', txtSize);
    end
    exitFlag= 1;
end

if exitFlag
    bf_freq= freq(locs(end));
    bf_thresh= tc_data(locs(end));
else
    bf_freq= nan;
    bf_thresh= nan;
end

ylim([-10 1.05*max(tc_data)]);