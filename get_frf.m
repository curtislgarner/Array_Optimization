function FRF=get_frf(p,dVoice,dNoise,f_range) %p is a single mic position, directions are complex numbers
av=angle(dVoice)-atan2(p(2),p(1));
an=angle(dNoise)-atan2(p(2),p(1));
ndelay=(cos(av)-cos(an))*sqrt(p(2)^2+p(1)^2)/343;
FRF=cos(ndelay*f_range*2*pi);
end