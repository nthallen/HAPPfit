function RAW = ParseAerisRawSpectra(flnm)
% ParseAerisRawSpectra - Parses the 1 Hz raw spectra output from the Aeris sensor into a MATLAB data structure.
%
% Syntax: RAW = ParseAerisRawSpectra(flnm)
%
% Inputs:
%    flnm - Aeris file containing 1 Hz raw spectral scans (e.g. 'Pico100007_180630_215923spectra.txt')
%
% Outputs:
%    RAW - Data structure containing 1 Hz spectral scans and related information
%    (this script converts time into a MATLAB datetime object)
%
% Author: Joshua Shutter (JDS)
% Email: shutter@g.harvard.edu
% Date Created: 11-June-2017
% Last Revision: 21-October-2017: New data layout in sensor output files

%------------- BEGIN CODE --------------
% Open file for reading
fid = fopen(flnm);
if fid<0, error(['Could not open ',flnm,' for input']); end

% Use textscan to load all columns into an object called 'data'
% Converts first column into a Matlab datetime object; all other columns
% are converted into a double floating-point number
data = textscan(fid,['%{MM/dd/y HH:mm:ss.SSS}D',repmat('%f',[1,1035])],'HeaderLines',0,'Delimiter',',');

% Close file
fclose(fid);

%parse columns
RAW.datetime          = data{1,1};
RAW.inlet_number      = data{1,2};
RAW.p_mbars           = data{1,3};
RAW.T0_degC           = data{1,4};
RAW.T1_degC           = data{1,5};
RAW.T2_degC           = data{1,6};
RAW.T3_degC           = data{1,7};
RAW.T4_degC           = data{1,8};
RAW.T5_degC           = data{1,9};
RAW.Laser_PID_Readout = data{1,10};
RAW.Det_PID_Readout   = data{1,11};

data = cell2table(data); %Change data object into a table

temporary             = data{1,12:1036};

%Expand out columns in d.temporary and assign to d.signal
RAW.signal = [];
for i=1:1024
RAW.signal(:,i) = temporary{1,i}; %Each row corresponds to a single timepoint
end

RAW.SamplesPerRamp = (0:0.5:511.5)';
%------------- END OF CODE -------------
