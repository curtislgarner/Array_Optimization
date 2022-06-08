function points=latin_hypercube(Range_vars, N_bins)
%Rangevars=[[min1 max1; min2 max2;... min3 max3]

N_vars=size(Range_vars,1);

for i=1:N_vars
    points(i,randperm(N_bins))=linspace(Range_vars(i,1),Range_vars(i,2),N_bins);
end
    