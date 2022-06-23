% This script converts csv exports from BK Connect into .m files
% The name of each csv must begin with a letter

clear; clc

%%%%% REQUIRED INPUTS %%%%%
A = [-.393 0];
B = [-.293 0];
C = [-.203 0];
D = [-.085 0];
E = [.108 0];
F = [.195 0];
G = [.303 0];
H = [.405 0];
I = [0 .320];
J = [0 .223];
K = [0 .121];
L = [0 .043];
M = [0 -.085];
N = [0 -.183];
O = [0 -.282];
P = [0 -.384];
Q = [0 -.487]; 
%NOTE: Names of csv files will be converted to dataset variable names. File
%      names that begin with a NUMBER will NOT be converted.

%% Tyler's T array, 3 refs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %Name of signals (columns in the csv) in the order they appear
% Names={'time','Voltage','ref1','ref2','ref3','err1','err2',...
%     'err3','err4C','err5','err6','err7','err8',...
%     'err9','err10','err11','err12','err13'};
% %Microphone locations in the same order as above (in meters)
% Locations= [NaN NaN; NaN NaN; 0 -2; 0 -2.2; -0.5 -1.3; -0.38  0; -0.2 0; -0.18 0;...
%     .22 0; 0.315 0; 0.415 0;0 -0.37; 0 -0.27; 0 -0.17; 0 0.13; 0 0.23; 0 0.33;];
% 
% %Microphone designations in the same order as above
%     % t = Time vector
%     % c = Center error signal
%     % e = Other error signal
%     % r = Reference signal
% Designation='ttrrreeeceeeeeeee';
% %Extra entries in these 3 sections will be ignored

% %% 6 mic array, April 26 2022 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% %Name of signals (columns in the csv) in the order they appear
% Names={'time','err1','err2','err3','err4C','err5','err6'};
% %Microphone locations in the same order as above (in meters)
% Locations= [NaN NaN; -0.393 0; 0.405 0; 0 0.320; 0 0.043; 0 -0.183; 0 -0.487];
% 
% %Microphone designations in the same order as above
%     % t = Time vector
%     % c = Center error signal
%     % e = Other error signal
%     % r = Reference signal
% Designation='teeecee';

%% 6 mic, 1 ref array, May 10 2022 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %Name of signals (columns in the csv) in the order they appear
% Names={'time','err1','err2','err3','err4C','err5','err6'};
% %Microphone locations in the same order as above (in meters)
% Locations= [NaN NaN; A;D;H;I;N;Q;NaN NaN];
% 
% %Microphone designations in the same order as above
%     % t = Time vector
%     % c = Center error signal
%     % e = Other error signal
%     % r = Reference signal
% Designation='teeecee';

%% Wheel Loader Data May 19th %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Names={'time','err1','err2',...
%     'err3','err4','err5','err6','err7','err8',...
%     'err9','errC','err11','err12','ref1','ref2','cab'};
% %Microphone locations in the same order as above (in meters)
% Locations= [NaN NaN; A;B;D;F;G;H;I;J;K;L;N;P;0 -5;0 -5;0 -5];
%Microphone designations in the same order as above
    % t = Time vector
    % c = Center error signal
    % e = Other error signal
    % r = Reference signal
    % m = miscellaneous signal (cab)
% Designation='teeeeeeeeeceerrm';

%% m4_f500_1500_a0_135
Names={'time','Center','2','3','4'};
Locations=[NaN NaN; 0 0; 0.0025 -0.0723; -0.0528 -0.0651; -0.0511 -0.1371];
Designation='tceee';



%% %%%%% END OF INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Please select the folder containing the data files.\n')
d=dir(uigetdir);
warning('off')
fprintf([num2str(length(d)) ' files detected.\n'])
n=0;

fprintf('Please choose where to save the processed data files.\n')
[file, path] = uiputfile('*.mat');
for i=1: length(d)
    nm=char(d(i).name);
    if isletter(nm(1))
        [~,Vlb,ext]=fileparts(nm);
        if strcmp(ext,'.csv')
            n=n+1;
            fprintf(['Converting file ' num2str(i) ' of ' num2str(length(d)) '.\n'])
            Vlb=strrep(Vlb,'-','_');
            Vlb=strrep(Vlb,',','_');
            Vlb=strrep(Vlb,'(','');
            Vlb=strrep(Vlb,')','');
            Vlb=strrep(Vlb,' ','_');
            data=table2array(readtable(fullfile(d(i).folder,d(i).name)));
            Fs=(data(2,1)-data(1,1))^-1;
            temp=Dataset(Vlb);
            for j=2:size(data,2)
                switch Designation(j)
                    case 'r'
                        temp=temp.add_reference_signal(Signal(data(:,j),Fs,Names{j},Locations(j,:)));
                    case 'e'
                        temp=temp.add_error_signal(Signal(data(:,j),Fs,Names{j},Locations(j,:)));
                    case 'c'
                        temp=temp.add_center_error_signal(Signal(data(:,j),Fs,Names{j},Locations(j,:)));
                        temp.Original_Signal=temp.Center_Error_Signal;
                    case 'm'
                        temp=temp.add_misc_signal(Signal(data(:,j),Fs,Names{j},Locations(j,:)));
                    otherwise
                end
            end
            eval([Vlb '=temp;']);
            if n>1
                save(fullfile(path,file),Vlb,'-append');
            else
                save(fullfile(path,file),Vlb);
            end
        end
    end
end
fprintf([num2str(n) ' Data files converted.\n'])
warning('on')
fpath=fullfile(d(i).folder);
clear;

