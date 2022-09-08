%{
v1.5

Constructor: Signal(data,Fs,Name,Location)


%}

classdef Signal
    properties
        Data {mustBeNumeric} 
        Fs {mustBeNumeric}
        Name
        Location
    end
    methods
        function obj = Signal(data,Fs,varargin)
            obj.Fs=Fs;
            if size(data,1)==1
                obj.Data=data;
            else
                data=data';
            end
            if size(data,1)==1
                obj.Data=data;
            else
                error('Signal data must be 1-D vector, silly!')
            end
            if ~isempty(varargin); obj.Name=varargin{1}; end
            if length(varargin)>1; obj.Location=varargin{2}; end
        end
        function hp = highpass(obj,band)
            hp=obj;
            hp.Data = highpass(obj.Data,band,obj.Fs);
        end
        function bp = bandpass(obj,band)
            bp=obj;
            bp.Data = bandpass(obj.Data,band,obj.Fs);
        end
        %%
        function [f,amps_dB,hist]=get_spectrum(obj,varargin)
            
            x=obj.Data;

            x=x(1:2*floor(length(x)/2)); % Force even number of samples
            N=length(x);
            nfft=round(N/obj.Fs)*2;
            Lfft=obj.Fs;
            smooth=0;

            for i=1:nargin-1
                if strcmp(varargin{i},'nfft') && ~isempty(varargin{i+1})
                    nfft=varargin{i+1};
                elseif strcmp(varargin{i},'lfft') && ~isempty(varargin{i+1})
                    Lfft=varargin{i+1};
                elseif strcmp(varargin{i},'smooth') && ~isempty(varargin{i+1})
                    smooth=varargin{i+1};
                end
            end
            %set block translation
            db=floor((N-Lfft)/(nfft-1));

            X=zeros(1,Lfft);
            for b=1:nfft
                xi=x((b-1)*db+1:(b-1)*db+Lfft);
                xi=2*xi.*hann(Lfft)';
                Xi(b,:)=abs(sqrt(2)*fft(xi)/Lfft);
                X=X+Xi(b,:);
            end
            Xss=X(1:floor(Lfft/2))/nfft;
            Xi=Xi(:,1:floor(Lfft/2));
            hist=20*log10(Xi/20e-6);
            if smooth>0
                Xss=smoothdata(Xss,2,'gaussian',smooth);
            end
            amps_dB=20*log10(Xss/20e-6);
            df=obj.Fs/Lfft;
            f=0:df:(Lfft/2-1)*df;
        end
        %%
        function spectrogram(obj,varargin)
            
            [f,~,hist]=get_spectrum(obj,varargin{:});
            t=linspace(0,length(obj.Data)/obj.Fs,size(hist,1));
            [T,F]=ndgrid(t,f);
            surf(T,F,hist)
            shading interp
            colormap jet
            view(0,90)

        end
        %%
        function play(obj)
            soundsc(obj.Data,obj.Fs);
        end
        function writeWAV(obj,fName)
            audiowrite(fName,obj.Data/max(abs(obj.Data)),obj.Fs);
        end
        function I=intensity(obj)
            I=mean(obj.Data.^2)/343;
        end
        function I=tail_intensity(obj,fraction)
            dta=obj.Data(round(length(obj.Data)*fraction):end);
            I=mean(dta.^2)/343;
        end
        function new_signal=delay(obj,s)
            new_signal=Signal([zeros(1,s) obj.Data(1:end-s)],obj.Fs,strcat(obj.Name,{' (Delayed)'}));
        end
        function obj=add_noise(obj,ratio)
            obj.Data=obj.Data+(rand(1,length(obj.Data))-0.5)*ratio*max(abs(obj.Data));
        end
        function varargout=plot_spectrum_ERRONEOUS(obj,range,varargin) %Pass extra parameter to suppress plot
            x=obj.Data;
            if rem(length(x),2)==1
                x=x(1:end-1);
            end
            N = length(x);
            xdft = fft(x);
            xdft = xdft(1:N/2+1);
            psdx = (1/(obj.Fs*N)) * abs(xdft).^2;
            psdx(2:end-1) = 2*psdx(2:end-1);
            freq = 0:obj.Fs/length(x):obj.Fs/2;
            amps=psdx/1e-12;
            Pt=10*log10(bandpower(x,obj.Fs,[0 obj.Fs/2])/1e-12);
            if nargin<3
                amps=10*log10(amps);
                plot(freq,amps)
                xlim(range)
                ylabel('Power/Frequency (dB/Hz)')
                xlabel('Frequency (Hz)')
                title(strcat(obj.Name,{' Spectrum, Total power: '},num2str(Pt),{' dB'}));
            else
                for i=1:length(varargin)
                    if strcmp(varargin{i},'Normalize')
                        amps=amps*1e-12/bandpower(x,obj.Fs,[0 obj.Fs/2]);
                    elseif strcmp(varargin{i},'Smooth')
                        amps=smoothdata(amps,2,'gaussian',100);
                    end
                end
                amps=10*log10(amps);
                plot(freq,amps)
                xlim(range)
                ylabel('Power/Frequency (dB/Hz)')
                xlabel('Frequency (Hz)')
            end
            varargout={freq,amps,Pt};
        end
        function obj=resample_to(obj,FsNew)
            obj.Data=resample(obj.Data,FsNew,obj.Fs);
            obj.Fs=FsNew;
        end

    end
end