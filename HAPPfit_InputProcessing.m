function HAPPfit_InputProcessing(run_date)
% HAPPfit_InputProcessing - Rewrites the 1 Hz raw spectral scans from 
% the Aeris sensor into a format suitable for HAPP fit. Also generates a
% PT.mat file (containing scan number, temperature, pressure, etc.) used in
% HAPP fit.
%
% Syntax: HAPPfit_InputProcessing(run_date)
%
% Inputs:
%   run_date - Date of run (e.g. '170719.1')
%   Please note: This script requires that you have created a folder within
%   Data called '170719.1' (or similar) and another folder in Data\RAW\  
%   called '170719.1' (or similar). Within this latter folder, another folder 
%   called SSP should be created.
%
% Raw Data Location: All data files from sensor should be placed in Data\RAW\run_date
%
% Required files: ParseAerisRawSpectra.m, mlf_path.m, mlf_mkdir.m,
%                 writebin.m, 
%
% Author: Joshua Shutter (JDS)
% Email: shutter@g.harvard.edu
% Date Created: 24-July-2017
% Revisions: 22-October-2017: New data layout in sensor output files
%            26-February-2018: Modified for running on Windows

%% DIRECTORY SETUP
% Folder containing the Aeris Pico data files
RAWdir = ['D:\Aeris\Data\RAW\',run_date,'\']; 
% Folder in which the PT.mat file will be saved
OUTdir  = ['D:\Aeris\Data\',run_date,'\'];
% Folder in which the PT.mat file will be saved
PTdir  = ['D:\Aeris\Data\',run_date,'\PT.mat'];
% Folder in which the PTE.txt file will be saved
PTEdir  = ['D:\Aeris\Data\',run_date,'\PTE.txt'];
% Folder in which the PTE_reverse.txt file will be saved
PTEdir_reverse  = ['D:\Aeris\Data\',run_date,'\PTE_reverse.txt'];
% Base folder that will contain the parsed scans
obase  = ['D:\Aeris\Data\RAW\',run_date,'\SSP\'];

addpath(RAWdir);
disp('Added RAW directory for this run to MATLAB search path')
addpath(OUTdir);
disp('Added output directory for this run to MATLAB search path')

%Find and extract the raw spectra file
flnm = dir(fullfile(RAWdir,'*spectra.txt'));
flnm = {flnm.name};
d = ParseAerisRawSpectra(flnm{1}); 

%% PARSE RAW SPECTRA SIGNAL
% Saves each scan to individual folders and files (in a binary format)
% within the folder called SSP (Data\RAW\run_date\SSP\)

for i=1:length(d.datetime)
  scan = i;
  po = mlf_path(obase,scan);
  mlf_mkdir(obase,scan);
  writebin(po, d.signal(scan,:)');
end

%% CREATE PT.mat FILE
% Copied from eng2PT.m

%Convert from datetime object into UNIX time (seconds since 1970)
unix_time = posixtime(d.datetime);

%Convert pressure from mbars to Torr
p_torr = (d.p_mbars)*0.75006375541921;

%Convert pressure from deg C to Kelvin
gas_temp = (d.T2_degC)+273.15;

%Create an array counting up to the total number of scans
scan_num = transpose([1:length(d.datetime)]);

%If necessary, create a waveform for the data
waveform = zeros(length(d.datetime),1);

PT.TPT = unix_time; % Time vector
PT.ScanNum = scan_num; % Scan number
PT.QCLI_Wave = waveform; % Waveform (if necessary)
PT.CellP = p_torr; %Cell Pressure (in Torr) to use for fit
PT.Tavg = gas_temp; %Gas Temperature (in K) to use for fit

save(PTdir,'-struct','PT');


%% CREATE PTE.txt FILE

PT = load('PT.mat');

% Write the forward version

PTE = zeros(length(d.datetime),11);
PTE(:,1) = PT.ScanNum;
PTE(:,2) = PT.CellP;
PTE(:,3) = PT.Tavg;
PTE(:,4) = 600;
PTE(:,5) = 0;
PTE(:,6) = 100;
PTE(:,7) = 0;
PTE(:,8) = 0;
PTE(:,9) = 1;
PTE(:,10) = 0;
PTE(:,11) = 1;

save(PTEdir,'-ascii','PTE');

% Write the backwards version

PTE = zeros(length(d.datetime),11);
PTE(:,1) = flipud(PT.ScanNum);
PTE(:,2) = flipud(PT.CellP);
PTE(:,3) = flipud(PT.Tavg);
PTE(:,4) = 600;
PTE(:,5) = 0;
PTE(:,6) = 100;
PTE(:,7) = 0;
PTE(:,8) = 0;
PTE(:,9) = 1;
PTE(:,10) = 0;
PTE(:,11) = 1;

save(PTEdir_reverse,'-ascii','PTE');

addpath(genpath(obase)) %Adds output from this script to MATLAB search path