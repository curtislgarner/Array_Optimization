classdef Dataset
    properties
        Name
        Fs %Sampling frequency
                
        Reference_Signals
        Error_Signals
        Center_Error_Signal
        Original_Signal
        Misc_Signals
    end
    methods
        function obj = Dataset(Name,varargin)
            obj.Name=Name; 
            if ~isempty(varargin); obj.Fs=varargin{1}; end
            
            temp=Signal(0,0);
            obj.Reference_Signals=temp([]);
            obj.Error_Signals=temp([]);
            obj.Misc_Signals=temp([]);
            obj.Center_Error_Signal=temp([]);
        end
        function obj=add_reference_signal(obj,Signal)
            [obj.Reference_Signals(length(obj.Reference_Signals)+1), obj.Fs]=resolve_Fs(obj,Signal);
        end
        function obj=add_error_signal(obj,Signal)
            [obj.Error_Signals(length(obj.Error_Signals)+1), obj.Fs]=resolve_Fs(obj,Signal);
        end
        function obj=add_center_error_signal(obj,Signal)
            [obj.Center_Error_Signal(length(obj.Center_Error_Signal)+1), obj.Fs]=resolve_Fs(obj,Signal);
        end
        function obj=add_misc_signal(obj,Signal)
            [obj.Misc_Signals(length(obj.Misc_Signals)+1), obj.Fs]=resolve_Fs(obj,Signal);
        end
        function obj=trim_signals(obj,varargin)
            if nargin>1
                L=varargin{1};
            else
                L=inf;
                for i=1:length(obj.Error_Signals)
                    L=min([L length(obj.Error_Signals(i).Data)]);
                end
                for i=1:length(obj.Reference_Signals)
                    L=min([L length(obj.Reference_Signals(i).Data)]);
                end
            end
            for i=1:length(obj.Reference_Signals)
                obj.Reference_Signals(i).Data=obj.Reference_Signals(i).Data(1:L);
            end
            for i=1:length(obj.Error_Signals)
                obj.Error_Signals(i).Data=obj.Error_Signals(i).Data(1:L);
            end
            obj.Center_Error_Signal.Data=obj.Center_Error_Signal.Data(1:L);
            obj.Original_Signal.Data=obj.Original_Signal.Data(1:L);
        end
        function [sig,Fs] = resolve_Fs(obj,Signal)
            if isempty(obj.Fs)
                Fs=Signal.Fs;
                sig=Signal;
            else
                if Signal.Fs==obj.Fs
                    sig=Signal;
                    Fs=Signal.Fs;
                else
                    error('Resampling functionality not implemented. Please use signals with the same sampling rate.')
                end
            end
        end
        function play(obj,sig,varargin)
            if nargin<3; varargin{1}=1; end
            if strcmp(sig,'e')
                obj.Error_Signals(varargin{1}).play()
            elseif strcmp(sig,'r')
                obj.Reference_Signals(varargin{1}).play()
            elseif strcmp(sig,'c')
                obj.Center_Error_Signal.play()
            end
            
        end
        function plotSpec(obj)
            figure()
            [f,amps]=obj.Center_Error_Signal.get_spectrum();
            amps=10*log10(amps/20e-6);
            plot(f,amps,'Color',[0 1 0])
            hold on
            leg={obj.Center_Error_Signal.Name};
            L=length(obj.Reference_Signals);
            for i=1:L
                [~,amps]=obj.Reference_Signals(i).get_spectrum();
                amps=10*log10(amps/20e-6);
                plot(f,amps,'Color',[1 0.5-i/L/2 0+i/L/2])
                leg(length(leg)+1)={obj.Reference_Signals(i).Name};
            end
            L=length(obj.Error_Signals);
            for i=1:L
                [~,amps]=obj.Error_Signals(i).get_spectrum();
                amps=10*log10(amps/20e-6);
                plot(f,amps,'Color',[0 1-i/L 0+i/L])
                leg(length(leg)+1)={obj.Error_Signals(i).Name};
            end
            legend(leg);
        end
        function obj=bandpass_ref(obj,band)
            for i=1:length(obj.Reference_Signals)
                obj.Reference_Signals(i)=obj.Reference_Signals(i).bandpass(band);
            end
        end
        function obj=bandpass_err(obj,band)
            for i=1:length(obj.Error_Signals)
                obj.Error_Signals(i)=obj.Error_Signals(i).bandpass(band);
            end
            obj.Center_Error_Signal=obj.Center_Error_Signal.bandpass(band);
        end
        function plotConfiguration(obj)
            %To do: make center error mic different color,
            sizeRef = size(obj.Reference_Signals,2);
            sizeErr = size(obj.Error_Signals,2);
            Names = strings([1,sizeRef + sizeErr]);
            X = zeros(1,sizeErr + sizeRef);
            Y = zeros(1,sizeErr + sizeRef);
            for i = 1:sizeRef
                X(i) = obj.Reference_Signals(i).Location(1);
                Y(i) = obj.Reference_Signals(i).Location(2);
                Names(i) = obj.Reference_Signals(i).Name;
            end
            for i = (1):(sizeErr)
                X(i+sizeRef) = obj.Error_Signals(i).Location(1);
                Y(i+sizeRef) = obj.Error_Signals(i).Location(2);
                Names(i+sizeRef) = obj.Error_Signals(i).Name;
            end
%             X(sizeErr + 1) = obj.Center_Error_Signal.Location(1);
%             Y(sizeErr + 1) = obj.Center_Error_Signal.Location(2);
            centx = obj.Center_Error_Signal.Location(1);
            centy = obj.Center_Error_Signal.Location(2);
            centerName = strings(1);
            centerName(1) = obj.Center_Error_Signal.Name;
            
            figure
            %plot error mics
            plot(X((1+sizeRef):end),Y((1+sizeRef):end),'.','markersize',30)
            hold on;
            %plot center error mic
            plot(centx,centy,'.','markersize',30)
            %fake ref mic locations
            plot([.4,.45],[-.3,-.3],'.','markersize',30)
            axis square
            text([.35,.4],[-.35,-.35], ' ' + Names(1:sizeRef))
            xlim([-.5 .5])
            ylim([-.5 0.5])
            text(X((1+sizeRef):end),Y((1+sizeRef):end),' ' + Names((1+sizeRef):end))%+ Names(1 + sizeRef:end))
            text(centx,centy,' ' + centerName(1))
            set(gcf,'Units','Normalized','OuterPosition',[0,0,1,1]);

%             saveas(gcf,'chart3.png');

            figure
            %plot reference mics
            plot(X(1:sizeRef),Y(1:sizeRef),'.','markersize',30)
            hold on;
            %hold on;
            %Plot error mics
            plot(X((1+sizeRef):end),Y((1+sizeRef):end),'.','markersize',30)
%           plot center error
            plot(centx,centy,'.','markersize',30)
            axis square
            %plot reference mics
%             plot([.4,.45],[-.3,-.3],'.','markersize',30)
%             axis square
            xlim([-.5 1.3])
            ylim([-1.9 0.5])
            text(X,Y,' ' + Names)%+ Names(1 + sizeRef:end))
            text(centx,centy,' ' + centerName(1))
%             text([.35,.4],[-.35,-.35], ' ' + Names(1:sizeRef))
             set(gcf,'Units','Normalized','OuterPosition',[0,0,1,1]);
            %text(X,Y,'\leftarrow ' + Names(3:16))
%             saveas(gcf,'chart4.png');
        end
    end
end