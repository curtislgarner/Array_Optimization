classdef mic_array
    properties
        p %All points except center, { (n-1)x2 array }
        f_range=[0:2000]; %Frequencies of interest
        a_range=(-180:0.5:180)*pi/180; %Angles of interest
        mic_range;
        FRF %Based on fixed noise, moving voice
    end
    methods
        function obj = mic_array(p,varargin)
            obj.p=p;
            for i=1:nargin-1
                if strcmp(varargin{i},'f_range')
                    obj.f_range=varargin{i+1};
                elseif strcmp(varargin{i},'a_range')
                    obj.a_range=varargin{i+1};
                elseif strcmp(varargin{i},'mic_range')
                    obj.mic_range=varargin{i+1};
                end
            end
        end
        
        function obj=calculate_FRF(obj)
            obj.FRF=zeros(length(obj.a_range),length(obj.f_range));
            frf=zeros(size(obj.p,1),length(obj.a_range),length(obj.f_range));
            for m=1:size(obj.p,1)
                for i=1:length(obj.a_range)
                    frf(m,i,:)=mic_array.get_FRF(obj.p(m,:),exp(1j*obj.a_range(i)),-1i,obj.f_range);
                end
                obj.FRF=obj.FRF+squeeze(frf(m,:,:));
            end            
            obj.FRF=(obj.FRF+1)/(size(obj.p,1)+1); %Add center cignal, divide by n
            obj.FRF=10*log10(obj.FRF.^2); %Convert to dB
            obj.FRF(obj.FRF<-40)=-40; %Set floor to -40dB
        end
        
        function plot_FRF(obj)
            figure();
            subplot(1,5,1:2)
            set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.17, 0.8, 0.8]);

            x=[obj.mic_range(1,1) obj.mic_range(1,1) obj.mic_range(1,2) obj.mic_range(1,2)];
            y=[obj.mic_range(2,1) obj.mic_range(2,2) obj.mic_range(2,2) obj.mic_range(2,1)];
            patch(x,y,[0.5 0.8 1],'edgecolor','none','FaceAlpha',0.5)

            hold on
            
            plot(0,0,'.','Color',[0 1 0.3],'MarkerSize',30)

            for i=1:size(obj.p,1)
                plot(obj.p(i,1),obj.p(i,2),'b.','MarkerSize',30)
            end
            
            lim=max(max(abs(obj.mic_range)))*1.2;
            xlim([-lim lim])
            ylim([-lim lim])
            axis square
            set(gca, 'XAxisLocation', 'origin', 'YAxisLocation', 'origin')
            subplot(1,5,3:5)
            [fr,th]=meshgrid(obj.f_range,obj.a_range);
            [x,y]=pol2cart(th,fr);
            surf(x,y,obj.FRF)
            shading interp
            set(gca,'DataAspectRatio',[500 500 20])
            set(gca, 'XAxisLocation', 'origin', 'YAxisLocation', 'origin')
            set(gca,'Layer','top')
            view(0,90)
            grid off
            colorbar
            colormap jet
            
            h=gca;    
            
            h.XLim=1.2*h.XLim;
            h.YLim=1.2*h.YLim;
            
            h.YTick=h.XTick;
            h.XTickLabel={};            
            h.YTickLabel=num2cell(abs(h.XTick));
            xlabel('Frequency (Hz)        ')
            h.YLabel.Rotation=90;
        end
        
        
    end
    
    methods(Static)
        function FRF=get_FRF(p,dVoice,dNoise,f_range) %2-mic obj.FRF in 1D
            av=angle(dVoice)-atan2(p(2),p(1));
            an=angle(dNoise)-atan2(p(2),p(1));
            ndelay=(cos(av)-cos(an))*sqrt(p(2)^2+p(1)^2)/343;
            FRF=cos(ndelay*f_range*2*pi);
        end
    end
end