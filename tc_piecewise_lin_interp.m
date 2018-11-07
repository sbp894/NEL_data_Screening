function [theta, yFit]= tc_piecewise_lin_interp(freq, thresh_dB)

% The parameter vector theta will be 4-dimensional:
% the first element is a constant offset from zero,
% the second element is the corner point,
% and the third and fourth elements are the two slopes.



fun = @tc_fit_fun;
P = polyfit(freq,thresh_dB,1);

DCguess= P(2);
Slope1guess= P(1);
freq_start= mean(freq);

theta= lsqcurvefit(fun, [DCguess; freq_start; Slope1guess; 0], freq, thresh_dB, [-Inf, -Inf, 0, 0], []);
yFit= fun(theta, freq);


function yFit_fun= tc_fit_fun(theta_fun, freq_fun)
dc_for_line1= theta_fun(1);
break_point= theta_fun(2);
line1_inds= freq_fun<break_point;
line2_inds= freq_fun>break_point;

line1_slope= theta_fun(3);
line2_slope= theta_fun(4);

yFit_fun= (dc_for_line1+line1_slope*freq_fun).* line1_inds + ...
    ((dc_for_line1+line1_slope*break_point) + line2_slope*(freq_fun-break_point)).*line2_inds;