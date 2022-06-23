function [Result,delays]=Beamform(dataset,voice_angle)
% Voice angle is measured in degrees from x axis

Nref=length(dataset.Error_Signals);
Locs(1,:)=dataset.Center_Error_Signal.Location;
for i=1:Nref
    Locs(i+1,:)=dataset.Error_Signals(i).Location;
end

%Get beam indices from DOA
for i=1:Nref
    [d,a]= distang(Locs(1,:),Locs(i+1,:));
    delays(i)=round(-dataset.Fs/343*d*cos(voice_angle*pi/180-pi-a));
end

%Apply delays
s(1,:)=dataset.Center_Error_Signal.Data;
for i=1:Nref
    s(i+1,:)=circshift(dataset.Error_Signals(i).Data,delays(i));
end
Result=Signal(sum(s,1)/(Nref+1),dataset.Fs);

end