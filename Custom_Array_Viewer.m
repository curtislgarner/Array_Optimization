mic_positions=[ 0      0     ;
               -0.029  0.071 ;
                0.029 -0.071 ;
                0.058 -0.142 ;
               -0.188 -0.003 ;
               -0.217  0.068 ;
               -0.159 -0.074 ;
               -0.130 -0.145];
f_range=500:2000;
a_range=0:pi/180:5*pi/4;
Range=[-0.2 0.2; -0.2 0.2];

CustomArray=mic_array(mic_positions(2:end,:),'f_range',f_range,'a_range',a_range,'mic_range',Range);
sol.Angles=[min(a_range) max(a_range)];
mics=mic_positions';
p_star=mics(:);
sol.R2=linearity(p_star(3:end));
a1=strcat(num2str(round(180*sol.Angles(1)/pi)));
a2=strcat(num2str(round(180*sol.Angles(2)/pi)));

% Plot
CustomArray=CustomArray.calculate_FRF;
CustomArray.plot_FRF;
tit=strcat(num2str(size(mic_positions,1)),{' mics, '},a1,{'\circ to '},a2,{'\circ '},num2str(min(CustomArray.f_range)),{' to '},num2str(max(CustomArray.f_range)),{' Hz.'});
sgtitle(char(tit));
title(num2str(total_reduction(CustomArray.FRF)));
subplot(1,5,1:2)
title(char(strcat({'R squared = '},num2str(sol.R2))))

