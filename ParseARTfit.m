function ART = ParseARTfit(flnm,MakePlot)
% ParseARTfit - Parses ART fit-derived HCHO mixing ratios into a MATLAB data structure
% Also parses useful information like inlet number (0 or 1), absolute water
% content (ppmv), cell temperature, etc.
%
% Syntax: ART = ParseARTfit(flnm,MakePlot)
%
% Inputs:
%    flnm     - Filename (no suffixes) of ART-fit HCHO mixing ratios (e.g. 'Pico100007_190424_144506.txt')
%    MakePlot - Option to view a plot of ART-fit HCHO mixing ratios (0 - false and 1 - true)
%
% Outputs:
%    ART - Data structure containing parsed ART fit results and other related information
%    (this script converts time into a MATLAB datetime object)
%
% Author: Joshua Shutter (JDS)
% Email: shutter@g.harvard.edu
% Date Created: 11-June-2017
% Last revision: March 2019 (new data file layout)

%------------- BEGIN CODE --------------
% Open file for reading
fid = fopen(flnm);
if fid<0, error(['Could not open ',flnm,' for input']); end

% Use textscan to load all columns into an array called 'data'
% Converts first column into a MATLAB datetime object; all other columns
% are converted into a double floating-point number
data = textscan(fid,['%{MM/dd/y HH:mm:ss.SSS}D',repmat('%f',[1,12])],'HeaderLines',1,'Delimiter',',');

% Close file
fclose(fid);

%parse columns
ART.datetime          = data{1,1};
ART.inlet_number      = data{1,2};
ART.T_degC            = data{1,3};
ART.HCHO_ppb          = data{1,4};
ART.H2O_ppm           = data{1,5};
ART.CH3OH_ppb         = data{1,6};
ART.corrected_HCHO_ppb= data{1,7};
ART.mean_H2O_ppm      = data{1,8};
ART.mean_CH3OH_ppb    = data{1,9};
ART.batt_charge_V     = data{1,10};
ART.power_input_mV    = data{1,11};
ART.current_mA        = data{1,12};
ART.relative_soc      = data{1,13};

if MakePlot
    figure,plot(ART.datetime,ART.corrected_HCHO_ppb)
end
%------------- END OF CODE -------------
