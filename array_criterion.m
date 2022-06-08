function C=array_criterion(p,doa,f_range,f_weights)
mics=zeros(length(p)/2,2);
for i=1:length(p)/2
    mics(i,:)=p([2*i-1 2*i]);
end

C=0;
for d=1:length(doa)
    total_frf=f_weights; %frf over all mics at this doa
    for m=1:size(mics,1)
        %noise frf of this mic after voice alignment
        frf=get_frf(mics(m,:),doa(d),-1i,f_range).*f_weights;
        total_frf=total_frf+frf;
    end
    C=C+sum(total_frf.^2); %Cumlative sum of squared pressure
end
C=C/length(doa)/length(f_range); %Normalize over sum dimensions

end