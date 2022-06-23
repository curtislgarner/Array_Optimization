function Beamformer_obj=auto_setup_bf(dataset,DOA)
FO=FilterOutput(dataset);
FO.Filtered_Error_Signals=dataset.Error_Signals;
FO.Filtered_Center_Error=dataset.Center_Error_Signal;
FO.DOA=DOA;
Beamformer_obj=Beamformer(FO,'auto_L');

end