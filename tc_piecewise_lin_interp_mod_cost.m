function [theta, yFit, numPointsSlope1]= tc_piecewise_lin_interp_mod_cost(freq, thresh_dB)

% The parameter vector theta will be 4-dimensional:
% the first element is a constant offset from zero,
% the second element is the corner point,
% and the third and fourth elements are the two slopes.


fun_cost=@(x)tc_cost_fun(x,freq, thresh_dB);
P = polyfit(freq,thresh_dB,1);
DCguess= P(2);
freq_start= mean(freq);
Slope1guess= P(1);
x_init= [DCguess; freq_start; Slope1guess; 0];

theta = fminsearch(fun_cost, x_init);
yFit= tc_fit_fun(theta, freq);
numPointsSlope1= sum(freq<theta(2));
end



function errValue=tc_cost_fun(theta, freq, thresh_dB)

yFit= tc_fit_fun(theta, freq);
% errValue= norm(yFit-thresh_dB);

line1inds= freq<theta(2);
line2inds= freq>=theta(2);
fitError= (5*norm(yFit(line1inds)-thresh_dB(line1inds)) + norm(yFit(line2inds)-thresh_dB(line2inds)));
errValue= fitError;
% errValue= fitError/theta(2);
end

function yFit_fun= tc_fit_fun(theta_fun, freq_fun)
dc_for_line1= theta_fun(1);
break_point= theta_fun(2);
line1_inds= freq_fun<break_point;
line2_inds= freq_fun>break_point;

line1_slope= theta_fun(3);
line2_slope= theta_fun(4);

yFit_fun= (dc_for_line1+line1_slope*freq_fun).* line1_inds + ...
    ((dc_for_line1+line1_slope*break_point) + line2_slope*(freq_fun-break_point)).*line2_inds;
end
