%% Import
load('ArrayData\6mic_225_fweight.mat')

% Plot
Array_Info.array.plot_FRF;
sol=Array_Info.Solution_file;
a1=strcat(num2str(round(180*sol.Angles(1)/pi)));
a2=strcat(num2str(round(180*sol.Angles(2)/pi)));
tit=strcat(num2str(sol.mics),{' mics, '},a1,{'\circ to '},a2,{'\circ '},num2str(min(Array_Info.array.f_range)),{' to '},num2str(max(Array_Info.array.f_range)),{' Hz.'});
sgtitle(char(tit));
subplot(1,5,1:2)
title(char(strcat({'R squared = '},num2str(sol.R2))))