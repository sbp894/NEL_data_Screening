clear;

xdata = 5:0.2:40;
ydata = min(25,xdata) + randn(size(xdata));
tc_piecewise_lin_interp_mod_cost(xdata, ydata)
[theta,yFitted]= tc_piecewise_lin_interp_mod_cost(xdata, ydata);

clf;
hold on
plot(xdata, ydata);
plot(xdata, yFitted, 'r');