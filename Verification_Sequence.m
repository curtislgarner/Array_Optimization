clear; clc;

% load('ArrayData\5mic0to180_300to1500Hz.mat') % Solution file for Theoretical and virtual
load('ArrayData\4mic90to225_800to2300Hz.mat')
load('Datasets\ary800.mat') % Contains dataset from testing, Fs is duplicated for virtual
dataset=J15_800;

Voice_Angle=0; % Measured in degrees from x axis

%% Theoretical Reduction

a_idx=find(abs(Array_Info.a_range-Voice_Angle*pi/180)<1e-4);
theoretical=Array_Info.FRF(a_idx,:);

%% Virtual Signals

%Extract locations
vLocs=Array_Info.Locations;
Nref=size(vLocs,1)-1;
% Build virtual data
x=chirp(0:1/dataset.Fs:10,1,10,3000);
X=Signal([zeros(1,2000) x zeros(1,2000)],dataset.Fs);
dSetV=Dataset('VirtualData',dataset.Fs);
dls0=round((vLocs(1,2))*dataset.Fs/343)+70;
dSetV.Center_Error_Signal=X.delay(dls0);
dSetV.Center_Error_Signal.Location=dataset.Center_Error_Signal.Location;
for i=1:Nref
    dls(i)=round((vLocs(i+1,2))*dataset.Fs/343)+dls0;
    dSetV.Error_Signals(i)=X.delay(dls(i));
    dSetV.Error_Signals(i).Location=vLocs(i+1,:);
end
%Beamform
[Result,delays]=Beamform(dSetV,Voice_Angle);
% Result.Data=dSetV.Center_Error_Signal.Data+dSetV.Error_Signals(1).Data;
[f,amps0]=X.get_spectrum;
[~,amps]=Result.get_spectrum;
Virtual=amps-amps0;

% figure()
% plot(Array_Info.f_range,theoretical)
% hold on
% plot(f,Virtual)
% legend('Theoretical','Virtual')
% xlim([min(Array_Info.f_range) max(Array_Info.f_range)])
% ylim([-40 5])

V_frf=0*Array_Info.FRF;

for a=1:length(Array_Info.a_range)
    voiceangle(a)=Array_Info.a_range(a);
    [temp,delaysV]=Beamform(dSetV,voiceangle(a)*180/pi);
    [~,temp2]=temp.get_spectrum('smooth',20);
    temp3=temp2-amps0;
    V_frf(a,:)=temp3(Array_Info.f_range);
end

%% Real Signals

%Normalize mics
dataset.Center_Error_Signal.Data=dataset.Center_Error_Signal.Data/max(abs(dataset.Center_Error_Signal.Data));
[~,dTot]=dataset.Center_Error_Signal.get_spectrum('smooth',20);
for i=1:length(dataset.Error_Signals)
    dataset.Error_Signals(i).Data=dataset.Error_Signals(i).Data/max(abs(dataset.Error_Signals(i).Data));
    [~,tmp]=dataset.Error_Signals(i).get_spectrum('smooth',20);
    dTot=dTot+tmp;
end
amps0R=dTot/(length(dataset.Error_Signals)+1);
%Beamform

R_frf=0*Array_Info.FRF;
for a=1:length(Array_Info.a_range)
    voiceangle(a)=Array_Info.a_range(a);
    [tempR,delaysR]=Beamform(dataset,voiceangle(a)*180/pi);
    [~,temp2R]=tempR.get_spectrum('smooth',20);
    temp3R=temp2R-amps0R;
    R_frf(a,:)=temp3R(Array_Info.f_range);
end

datasetSV=dataset;
datasetSV.Center_Error_Signal=dataset.Center_Error_Signal.delay(dls0);
datasetSV.Center_Error_Signal.Location=dataset.Center_Error_Signal.Location;
for i=1:Nref
    datasetSV.Error_Signals(i)=dataset.Center_Error_Signal.delay(dls(i));
    datasetSV.Error_Signals(i).Location=dataset.Error_Signals(i).Location;
end

[f,amps0SV]=dataset.Center_Error_Signal.get_spectrum;
%Beamform
SV_frf=0*Array_Info.FRF;
for a=1:length(Array_Info.a_range)
    voiceangle(a)=Array_Info.a_range(a);
    [tempSV,delaysSV]=Beamform(datasetSV,voiceangle(a)*180/pi);
    [~,temp2SV]=tempSV.get_spectrum;
    temp3SV=temp2SV-amps0SV;
    SV_frf(a,:)=temp3SV(Array_Info.f_range);
    0;
end

%%

figure(1)
subplot(3,2,1)
plot_frf_map(Array_Info.a_range,Array_Info.f_range,Array_Info.FRF)
title('Theoretical Noise Reduction')
clim([-35 0])
subplot(3,2,2)
plot_frf_map(Array_Info.a_range,Array_Info.f_range,V_frf)
title('Actual Reduction of Virtual Noise')
clim([-35 0])
subplot(3,2,3)
plot_frf_map(Array_Info.a_range,Array_Info.f_range,SV_frf)
title('Actual Reduction of Semi-virtual Noise')
clim([-35 0])
subplot(3,2,4)
plot_frf_map(Array_Info.a_range,Array_Info.f_range,R_frf)
title('Actual Reduction of Real Noise')
clim([-35 0])






