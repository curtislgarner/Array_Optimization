function plot_frf_map(a_range,f_range,frf)

[fr,th]=meshgrid(f_range,a_range);
[x,y]=pol2cart(th,fr);

surf(x,y,frf)
shading interp
set(gca,'DataAspectRatio',[500 500 20])
set(gca, 'XAxisLocation', 'origin', 'YAxisLocation', 'origin')
set(gca,'Layer','top')
view(0,90)
grid off
colorbar
colormap jet

h=gca;

h.XLim=1.2*h.XLim;
h.YLim=1.2*h.YLim;

h.YTick=h.XTick;
h.XTickLabel={};
h.YTickLabel=num2cell(abs(h.XTick));
xlabel('Frequency (Hz)        ')
h.YLabel.Rotation=90;
end