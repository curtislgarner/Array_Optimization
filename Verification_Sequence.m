clear; clc;

load('ArrayData\4mic0to135_500to2000Hz.mat') % Solution file for Theoretical and virtual
load('Datasets\Initial.mat') % Contains dataset from testing, Fs is duplicated for virtual
dataset=m4_f500_1500_a0_135;

Voice_Angle=90; % Measured in degrees from x axis

%% Theoretical Reduction

a_idx=find(abs(Array_Info.a_range-Voice_Angle*pi/180)<1e-4);
theoretical=Array_Info.FRF(a_idx,:);

%% Virtual Signals

%Extract locations
vLocs=Array_Info.Locations;
Nref=size(vLocs,1)-1;
% Build virtual data
x=chirp(0:1/32768:10,1,10,2000);
X=Signal([zeros(1,2000) x zeros(1,2000)],32768);
dSetV=Dataset('VirtualData',dataset.Fs);
dls0=round((vLocs(1,2))*dataset.Fs/343)+70;
dSetV.Center_Error_Signal=X.delay(dls0);
dSetV.Center_Error_Signal.Location=dataset.Center_Error_Signal.Location;
for i=1:Nref
    dls(i)=round((vLocs(i+1,2))*dataset.Fs/343)+dls0;
    dSetV.Error_Signals(i)=X.delay(dls(i));
    dSetV.Error_Signals(i).Location=vLocs(i+1,:);
end
dls=dls-dls0;
%Beamform
[Result,delays]=Beamform(dSetV,Voice_Angle);
% Result.Data=dSetV.Center_Error_Signal.Data+dSetV.Error_Signals(1).Data;
[f,amps0]=X.get_spectrum;
[~,amps]=Result.get_spectrum;
Virtual=amps-amps0;

figure()
plot(Array_Info.f_range,theoretical)
hold on
plot(f,Virtual)
legend('Theoretical','Virtual')
xlim([min(Array_Info.f_range) max(Array_Info.f_range)])
ylim([-40 5])
