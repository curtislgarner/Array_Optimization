%% Import
load('ArrayData\4mic0to135_500to2000Hz.mat')

% Plot
Array_Info.array.plot_FRF;
sol=Array_Info.Solution_file;
tit=strcat(num2str(sol.mics),{' mics, '},a1,{'\circ to '},a2,{'\circ '},num2str(min(array.f_range)),{' to '},num2str(max(array.f_range)),{' Hz.'});
sgtitle(char(tit));
subplot(1,5,1:2)
title(char(strcat({'R squared = '},num2str(sol.R2))))