function R2=linearity(p)
mics=zeros(length(p)/2,2);
for i=1:length(p)/2
    mics(i,:)=p([2*i-1 2*i]);
end
if all(mics(1,:)==[0 0])
    % Do Nothing
else
    mics=[[0 0]; mics];
end

mdl=fitlm(mics(:,1),mics(:,2));
r2=mdl.Rsquared.Ordinary;
micsr=mics*[0.7071 0.7071; 0.7071 -0.7071];
mdl=fitlm(micsr(:,1),micsr(:,2));
r2b=mdl.Rsquared.Ordinary;

R2=max([r2 r2b]);

end
