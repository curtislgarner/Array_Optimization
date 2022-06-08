clear; clc;

% Number_of_mics=[3 4];
% Angle_ranges=[3*pi/4 pi; pi/4 3*pi/4; 0 3*pi/4; 0 pi; -pi/4 pi];

Number_of_mics=4;
Angle_ranges=[0 3*pi/4];

fRange=500:2000;
N_start=20;
Range=[-0.25 0.25; -0.375 0.375];

nOpt=length(Number_of_mics)*size(Angle_ranges,1)*N_start;

fprintf('Optimizing arrays: Currently calculating ')
tx=strcat(num2str(1),{' of '},num2str(nOpt),' Optimizations');
fprintf(char(tx))

options = optimoptions('fmincon','Display','off');
cOpt=0;
for n=1:length(Number_of_mics)
    for a=1:size(Angle_ranges,1)
        N_mics=Number_of_mics(n);
        doa=exp(1i*(Angle_ranges(a,1):pi/180:Angle_ranges(a,2))); %DOA range
        fWeights=ones(1,length(fRange));

        startpoints=latin_hypercube(repmat(Range,(N_mics-1),1),N_start);
        for i=1:N_start
            p=startpoints(:,i);
            [p_star(i,:),C(i),flags(i)]=fmincon(@(p)array_criterion(p,doa,fRange,fWeights),p,[],[],[],[],repmat(Range(:,1)',1,(N_mics-1)),repmat(Range(:,2)',1,(N_mics-1)),@linearity_bound,options);
            cOpt=cOpt+1;
            %Text output
            fprintf(repmat('\b',1,length(char(tx))));
            tx=strcat(num2str(cOpt),{' of '},num2str(nOpt),{' Optimizations'});
            fprintf(char(tx))
        end

        % Sort results
        [C,idx]=sort(C);
        p_star=[repmat([0 0],N_start,1) p_star(idx,:)]; % Sort and add 0,0 mic
        startpoints=[repmat([0 0],N_start,1) startpoints(:,idx)']; % Sort and add 0,0 mic
        
        % Determine best results (minimum footprint by largest d)
        for i=1:sum(C<=min(C)*1.01) % Loop through equivalent solutions (i) 
            d_max(i)=0;
            for ii=1:N_mics-1 % Loop through mics in solution to find max d (ii,jj) 
                for jj=ii+1:N_mics
                    d_max(i)=max([d_max(i) distang(p_star(i,[2*ii-1 2*ii]),p_star(i,[2*jj-1 2*jj]))]);
                end
            end
        end
        [footprint,idx]=min(d_max);
        sol.locations=[p_star(idx,2*(1:N_mics)-1)' p_star(idx,2*(1:N_mics))'];
        sol.num_Equivalent=i;
        sol.Criterion=C(1,idx);
        sol.Start=[startpoints(idx,2*(1:N_mics)-1)' startpoints(idx,2*(1:N_mics))'];
        sol.Angles=Angle_ranges(a,:);
        sol.a_range=Angle_ranges(a,1):pi/180:Angle_ranges(a,2);
        sol.mics=N_mics;
        sol.f_range=fRange;
        sol.R2=linearity(p_star(idx,3:end));
        sol.bounds=Range;
        Solutions(n,a)=sol;
        p_star=[];
    end
end
fprintf('\n');
fprintf('Optimization Complete.\n')

