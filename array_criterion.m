function C=array_criterion(p,doa,f_range,f_weights,varargin)
if length(nargin)>4
    a_weights=varargin{1};
else
    a_weights=ones(1,length(doa));
end
mics=zeros(length(p)/2,2);
for i=1:length(p)/2
    mics(i,:)=p([2*i-1 2*i]);
end

C=0;
for d=1:length(doa)
    total_frf=ones(1,length(f_range)); %Center mic is in phase with itself at all f
    for m=1:size(mics,1)
        %noise frf of this mic after voice alignment
        frf=get_frf(mics(m,:),doa(d),-1i,f_range).*f_weights;
        total_frf=total_frf+frf;
    end
    pressure=abs(total_frf)/(length(p)/2+1);
    C=C+sum(pressure.^2)*a_weights(d); %Cumlative sum of squared pressure
end
C=C/length(doa)/length(f_range); %Normalize over sum dimensions

end