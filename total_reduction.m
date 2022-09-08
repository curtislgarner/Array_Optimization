function Reduction=total_reduction(frf_map_dB)

r_p2=10.^(frf_map_dB/10);
r_mp2=mean(mean(r_p2));
Reduction=10*log10(r_mp2);

end