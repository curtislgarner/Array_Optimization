figure(2)
clf
load('ArrayData\5mic0to180_300to1500Hz.mat')
load('Datasets\J13_5mic.mat')
dSet_list={'J13'}; % A
for d=1:length(dSet_list)
    eval(strcat('dataset=',dSet_list{d},';'));
    dataset.Center_Error_Signal.Data=dataset.Center_Error_Signal.Data/max(abs(dataset.Center_Error_Signal.Data));
    [~,dTot]=dataset.Center_Error_Signal.get_spectrum('smooth',20);
    for i=1:length(dataset.Error_Signals)
        dataset.Error_Signals(i).Data=dataset.Error_Signals(i).Data/max(abs(dataset.Error_Signals(i).Data));
        [~,tmp]=dataset.Error_Signals(i).get_spectrum('smooth',20);
        dTot=dTot+tmp;
    end



    % [f,SV_spec(1,:)]=datasetSV.Center_Error_Signal.get_spectrum;
    [f,R_spec(1,:)]=dataset.Center_Error_Signal.get_spectrum('smooth',20);
    for i=1:length(dataset.Error_Signals)
        %    [~,R_spec(i+1,:)]=datasetSV.Error_Signals(i).get_spectrum;
        [f,R_spec(i+1,:)]=dataset.Error_Signals(i).get_spectrum('smooth',20);
    end


    subplot(length(dSet_list),1,d)
    hold on
    for i=1:length(dataset.Error_Signals)+1
        plot(f,R_spec(i,:),'LineWidth',1)
    end
    xlim([0 3000])
    ylim([20 50])
    xlabel('Frequency (Hz)')
    ylabel('Amplitude (dB)')
    set(gcf,"Units",'Normalized',"OuterPosition",[0.2 0.2 0.5 0.5])
end



