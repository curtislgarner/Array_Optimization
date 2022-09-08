load('ArrayData\4mic0to135_500to2000Hz.mat');
paper=[8.5 11];
margins=[0.5 0.5];
xsz=(paper(1)-2*margins(1))*.0254;
ysz=(paper(2)-2*margins(2))*.0254;

% Array_Info.Locations=[0 0; 0 0.1];

plot(Array_Info.Locations(:,1),Array_Info.Locations(:,2),'k.','MarkerSize',20)
axis equal
xmin=min(Array_Info.Locations(:,1)-0.01);
% set(gcf,"Units",'centimeters',"Position",[8 6 25 35]/4)
xlim([xmin xmin+xsz])
ymin=min(Array_Info.Locations(:,2)-0.01);
ylim([ymin ymin+ysz])


% Make a plot
% x=7:0.05:15;
% y=sin(x);
% plot(x,y)

% Force MATLAB to render the figure so that the axes 
% are created and the properties are updated
drawnow  
% Define the axes' 'units' property
% Note: this does not mean that one cm of the axes equals 
%  one cm on the axis ticks.  The 'position' property 
%  will also need to be adjusted so that these match
set(gca,'units','centimeters')
% Force the x-axis limits and y-axis limits to honor your settings, 
% rather than letting the renderer choose them for you
set(gca,'xlimmode','manual','ylimmode','manual')
% Get the axes position in cm, [locationX locationY sizeX sizeY]
% so that we can reuse the locations
axpos = get(gca,'position');
% Use the existing axes location, and map the axes size (in cm) to the
%  axes limits so there is a true size correspondence
set(gca,'position',[axpos(1:2) abs(diff(xlim))*10 abs(diff(ylim))*10])
% Optional: Since we are forcing the x-axis limits and y-axis limits,
% the print out may not display the desired tick marks. In order to keep 
% these, you can select "File-->Preferences-->Figure Copy Template".  Then
% choose "Keep axes limits and tick spacing" in the "Uicontrols and axes"
% Frame.  Click on "Apply to Figure" and then "OK".
% Print the figure to paper in real size.
% print
% Print to a file in real size and look at the result
print(gcf,'-dpng','-r0','sine.png')
winopen('sine.png')
