%% Import
close all
%% Plot
for i=1:size(Solutions,1)
    for j=1:size(Solutions,2)
        clear Array_Info
        sol=Solutions(i,j);
        array=mic_array(sol.locations(2:end,:),'f_range',sol.f_range,'a_range',sol.a_range,'mic_range',sol.bounds);
        a1=strcat(num2str(round(180*sol.Angles(1)/pi)));
        a2=strcat(num2str(round(180*sol.Angles(2)/pi)));
        
        % Plot
        array=array.calculate_FRF;
        array.plot_FRF;
        tit{i,j}=strcat(num2str(sol.mics),{' mics, '},a1,{'\circ to '},a2,{'\circ '},num2str(min(array.f_range)),{' to '},num2str(max(array.f_range)),{' Hz.'});
        sgtitle(char(tit{i,j}));
        subplot(1,5,1:2)
        title(char(strcat({'R squared = '},num2str(sol.R2))))
        
        % Format
        micpos=[array.p];
        micpos_New(:,1)=0.38365-micpos(:,2);
        micpos_New(:,2)=0.251919-micpos(:,1);
        Array_Info.Locations=sol.locations;
        Array_Info.DXF_mm=1000*micpos_New;
        fr=strcat(num2str(min(array.f_range)),{'to'},num2str(max(array.f_range)),{'Hz.'});
        Array_Info.ID=char(strcat(num2str(sol.mics),{'mic'},a1,{'to'},a2,{'_'},fr));
        Array_Info.FRF=array.FRF; %in mm for an 18 inch square plate
        Array_Info.f_range=array.f_range;
        Array_Info.a_range=array.a_range;
        Array_Info.Predicted_Criterion=sol.Criterion;
%         save(strcat('ArrayData/',Array_Info.ID,'.mat'),'Array_Info')
        Eqiv(i,j)=sol.num_Equivalent;
    end
end
save('most_recent','Solutions')