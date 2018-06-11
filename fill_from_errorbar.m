function ax=fill_from_errorbar(x,y,e, fill_color, fAlpha, plot_mean, lw_color, lw)

if ~exist('plot_mean', 'var')
    plot_mean=1;
end

if ~exist('lw', 'var')
    lw=2;
end

if ~exist('lw_color', 'var')
    lw_color='k';
end

%% Convert to column vectors
if size(x,2)~=1
   x=x'; 
end

if size(y,2)~=1
   y=y'; 
end

if size(e,2)~=1
   e=e'; 
end

if sum(e>=0)~=length(e)
    error('Standard error/ deviation must be nonnegative');
end

%%
x_fill=[x; flipud(x); x(1)];
y_fill=[y+e; flipud(y-e); y(1)+e(1)];


ax=fill(x_fill, y_fill, fill_color, 'facealpha', fAlpha);
if plot_mean
    hold on;
    ax=plot(x,y, 'color', lw_color, 'linewidth', lw);
end
