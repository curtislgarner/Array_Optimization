classdef FilterOutput
    properties
        Dataset %Original Dataset used to generate this output
        Fs %Sampling frequency
        Filtered_Error_Signals
        Filtered_Center_Error
        Filter_Output %Final result
        DOA %Direction of Arrival
        DOA_Reliability
        Debug
        
    end
    methods
        function obj=FilterOutput(Basis)
            
            
            if isa(Basis,'Dataset')
                obj.Dataset=Basis;
                obj.Fs=Basis.Fs;
                
                %Zero signal vectors
                obj.Filtered_Error_Signals=Basis.Center_Error_Signal([]);
                obj.Filter_Output=Basis.Center_Error_Signal([]);
            elseif isa(Basis,'FilterOutput')
                obj=Basis;
            end
            
        end
        function video(obj,filename,clips)
            audio=mix_audio(obj,clips);
            t=(0:length(audio.Data)-1)/obj.Fs;
            
            if length(clips)==1
                hFig=figure();
                subplot(2,3,[2 3])
                plot(t,obj.Dataset.Original_Signal.Data/max(abs(obj.Dataset.Original_Signal.Data)),'r')
                lims1=ylim();
                xlim([0 t(end)])
                hold on
                patch([0 clips clips 0],[lims1(1) lims1(1) lims1(2) lims1(2)],[0 0.9 0.3],'FaceAlpha',0.4,'LineStyle','none');
                h = get(gca,'Children');
                set(gca,'Children',[h(2) h(1)])
                title('Original Signal')
                
                subplot(2,3,[5 6])
                plot(t,obj.Filter_Output.Data/max(abs(obj.Filter_Output.Data)),'b')
                lims2=ylim();
                xlim([0 t(end)])
                hold on
                patch([clips t(end) t(end) clips],[lims2(1) lims2(1) lims2(2) lims2(2)],[0 0.9 0.3],'FaceAlpha',0.4,'LineStyle','none');
                h = get(gca,'Children');
                set(gca,'Children',[h(2) h(1)])
                title('Filtered Signal')
                
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.1, 0.55, 0.4]);

                try
                    DOAmax=max(max(obj.Debug.CXT));
                catch
                    DOAmax=4;
                end
                
                % Time loop
                for i=floor(length(t)*60/obj.Fs):-1:0
                    tm=i/60;
                    subplot(2,3,[2 3])
                    hLine1=plot([tm tm],lims1,'k','Linewidth',2);
                    subplot(2,3,[5 6])
                    hLine2=plot([tm tm],lims2,'k','Linewidth',2);
                    subplot(2,3,[1 4])
                    cla
%                     plot_DOA_set(obj,tm,hFig)
%                     axis square
                    obj.ring_plot(tm);
                    clim([0 DOAmax]);
                    
                    F(i+1)=getframe(gcf);
                    delete(hLine1);
                    delete(hLine2);
                end
                
                writerObj = VideoWriter(strcat(filename,'.avi'));
                writerObj.FrameRate = 60;
                open(writerObj);
                % write the frames to the video
                for i=1:length(F)
                    % convert the image to a frame
                    frame = F(i) ;
                    writeVideo(writerObj, frame);
                end
                % close the writer object
                close(writerObj);
                
                audiowrite(strcat(filename,'.wav'),audio.Data,obj.Fs);
                
                %% Triple segment cut
            elseif length(clips)==2
                figure()
                subplot(3,3,[2 3])
                plot(t,obj.Dataset.Original_Signal.Data/max(abs(obj.Dataset.Original_Signal.Data)),'r')
                lims1=ylim();
                xlim([0 t(end)])
                hold on
                patch([0 clips(1) clips(1) 0],[lims1(1) lims1(1) lims1(2) lims1(2)],[0 0.9 0.3],'FaceAlpha',0.4,'LineStyle','none');
                h = get(gca,'Children');
                set(gca,'Children',[h(2) h(1)])
                title('Original Signal')
                
                subplot(3,3,[5 6])
                plot(t,obj.Filtered_Center_Error.Data/max(abs(obj.Filtered_Center_Error.Data)),'Color',[0.6 0 1])
                lims2=ylim();
                xlim([0 t(end)])
                hold on
                patch([clips(1) clips(2) clips(2) clips(1)],[lims2(1) lims2(1) lims2(2) lims2(2)],[0 0.9 0.3],'FaceAlpha',0.4,'LineStyle','none');
                h = get(gca,'Children');
                set(gca,'Children',[h(2) h(1)])
                title('Partially Filtered Signal (after bandpass and LMS)')
                
                subplot(3,3,[8 9])
                plot(t,obj.Filter_Output.Data/max(abs(obj.Filter_Output.Data)),'b')
                lims3=ylim();
                xlim([0 t(end)])
                hold on
                patch([clips(2) t(end) t(end) clips(2)],[lims3(1) lims3(1) lims3(2) lims3(2)],[0 0.9 0.3],'FaceAlpha',0.4,'LineStyle','none');
                h = get(gca,'Children');
                set(gca,'Children',[h(2) h(1)])
                title('Fully Filtered Signal')
                
                set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.1, 0.65, 0.5]);
                
                DOAmax=max(max(obj.Debug.CXT));

                for i=floor(length(t)*60/obj.Fs):-1:0
                    tm=i/60;
                    subplot(3,3,[2 3])
                    hLine1=plot([tm tm],lims1,'k','Linewidth',2);
                    subplot(3,3,[5 6])
                    hLine2=plot([tm tm],lims2,'k','Linewidth',2);
                    subplot(3,3,[8 9])
                    hLine3=plot([tm tm],lims3,'k','Linewidth',2);

                    subplot(2,3,[1 4])
                    cla
                    obj.ring_plot(tm);
                    clim([0 DOAmax]);
                    
                    F(i+1)=getframe(gcf);
                    delete(hLine1);
                    delete(hLine2);
                    delete(hLine3);
                end
                
                writerObj = VideoWriter(strcat(filename,'.avi'));
                writerObj.FrameRate = 60;
                open(writerObj);
                % write the frames to the video
                for i=1:length(F)
                    % convert the image to a frame
                    frame = F(i) ;
                    writeVideo(writerObj, frame);
                end
                % close the writer object
                close(writerObj);
                
                audiowrite(strcat(filename,'.wav'),audio.Data,obj.Fs);
            end
        end
        function combo=mix_audio(obj,clipsS)
            clips=floor(clipsS*obj.Fs);
            combo=obj.Dataset.Original_Signal;

            combo.Data=combo.Data/max(abs(combo.Data));

            if length(clips)==1 %Full cut
                combo.Data(clips:end)=obj.Filter_Output.Data(clips:end)/max(abs(obj.Filter_Output.Data(clips:end)));
            elseif length(clips)==2 %Triple segment cut
                combo.Data(clips(1):clips(2))=obj.Filtered_Center_Error.Data(clips(1):clips(2))/max(abs(obj.Filtered_Center_Error.Data(clips(1):clips(2))));
                combo.Data(clips(2):end)=obj.Filter_Output.Data(clips(2):end)/max(abs(obj.Filter_Output.Data(clips(2):end)));
            end
            
        end
        function plot_DOA_set(obj,t,varargin) % Old doa
            if nargin>2
                fig=varargin{1};
            else
                fig=figure();
            end
            comp_frame=max([ceil(t*obj.Fs/obj.Debug.S2compression) 1]);
            DOA_all=obj.Debug.Ang_track(:,comp_frame);
            figure(fig);
            plot(real(DOA_all(1:end/2)),imag(DOA_all(1:end/2)),'bo')
            hold on
            plot(real(DOA_all(end/2+1:end)),imag(DOA_all(end/2+1:end)),'bo')
            ind=max([ceil(t*obj.Fs) 1]);
            p=[real(obj.DOA(ind)),imag(obj.DOA(ind))];
            plot([0 p(1)],[0 p(2)],'k')
        end
        function plot_all_cx(obj,varargin) % Old doa
            close all
            n=1;
            Ne=length(obj.Filtered_Error_Signals)+1;
            for i=1:Ne-1
                for j=i+1:Ne
                    figure(n)
                    obj.plotDOA_Cx(i,j,{varargin});
                    n=n+1;
                    view([0 0 1])
                end
            end
        end
        function plotDOA_Cx(obj,i,j,varargin) % Old doa
            if nargin>3
                True_vect=varargin{1};
                [d,a]=distang(obj.Debug.eLocs(i,:),obj.Debug.eLocs(j,:));
                ra=angle(True_vect)-a+pi;
                rd=d*cos(ra);
                t_ind=rd*obj.Fs/343;
            else
                t_ind=999;
            end
            Nref=length(obj.Filtered_Error_Signals);
            n=(i-1)*(Nref-i/2)+j-1;
            W=squeeze(obj.Debug.W(n,:,:));
            [T,LGS]=meshgrid(1:size(W,1),obj.Debug.lags);
            surf(LGS',T',W)
            title(strcat(obj.Debug.W_Names(n),{' '},num2str(t_ind)))
            shading interp
            
        end
        function ring_plot(obj,t,varargin) % New doa. t in seconds, can pass in [r1 r2]
            sample=round(t*obj.Fs/obj.Debug.Compression);
            sample=max([sample 1]);
            if nargin>2
                r=varargin{1};
            else
                r=[0.8 1];
            end
            Z=obj.Debug.CXT(sample,:);
            Z(361)=Z(1);
            Z=repmat(Z,2,1)';
            [fr,th]=meshgrid(r,(91:451)*pi/180);
            [x,y]=pol2cart(th,fr);
            surf(x,y,Z)
            shading interp
            xlim([-1 1])
            ylim([-1 1])
            axis square
            view(0,90)
            colorbar
            colormap jet
            title('DOA Estimation')
%             set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.1, 0.7, 0.6]);
        end
        function DOAsurf(obj)
            [T,LGS]=meshgrid(1:size(obj.Debug.CXT,1),1:360);
            surf(LGS',T',obj.Debug.CXT)
            title('Total CX vectors')
            shading interp
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
            obj.Dataset=obj.Dataset.trim_signals(L);
            for i=1:length(obj.Filtered_Error_Signals)
                obj.Filtered_Error_Signals(i).Data=obj.Filtered_Error_Signals(i).Data(1:L);
            end
            obj.Filtered_Center_Error.Data=obj.Filtered_Center_Error.Data(1:L);
            if ~isempty(obj.Filter_Output)
            obj.Filter_Output.Data=obj.Filter_Output.Data(1:L);
            end
        end
    end
end