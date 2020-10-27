function ART_ENG = ParseARTfit_Eng(flnm)

% ParseARTfit_Eng - Parses Aeris data file ending with the 'Eng' suffix
% The 'Eng' file contains additional information like pressure and ART fit 
% parameters that are not included in the standard output file. This script
% parses the 'Eng' file into a MATLAB data structure.
%
% Syntax: ART_ENG = ParseARTfit_Eng(flnm)
%
% Inputs:
%    flnm - Filename of 'Eng' file (e.g. 'Pico100007_171017_052836Eng.txt')
%
% Outputs:
%    ART_ENG - Data structure containing parsed ART fit results and other related information
%    (this script converts time into a MATLAB datetime object)
%
% Author: Joshua Shutter (JDS)
% Email: shutter@g.harvard.edu
% Date Created: 07-November-2017
% Last revision: May 2019 (new data file layout)

%------------- BEGIN CODE --------------
% Open file for reading
fid = fopen(flnm);
if fid<0, error(['Could not open ',flnm,' for input']); end

% Use textscan to load all columns into an array called 'data'
% Converts first column into a MATLAB datetime object; all other columns
% are converted into a double floating-point number
data = textscan(fid,['%{MM/dd/y HH:mm:ss.SSS}D',repmat('%f',[1,47])],'HeaderLines',1,'Delimiter',',');

% Close file
fclose(fid);

%parse columns
ART_ENG.datetime           = data{1,1};
ART_ENG.inlet_number       = data{1,2};
ART_ENG.p_mbars            = data{1,3};
ART_ENG.T0_degC            = data{1,4};
ART_ENG.T1_degC            = data{1,5};
ART_ENG.T2_degC            = data{1,6};
ART_ENG.T3_degC            = data{1,7};
ART_ENG.T4_degC            = data{1,8};
ART_ENG.T5_degC            = data{1,9};
ART_ENG.laser_PIDreadout   = data{1,10};
ART_ENG.det_PIDreadout     = data{1,11};
ART_ENG.win0Fit0           = data{1,12};
ART_ENG.win0Fit1           = data{1,13};
ART_ENG.win0Fit2           = data{1,14};
ART_ENG.win0Fit3           = data{1,15};
ART_ENG.win0Fit4           = data{1,16};
ART_ENG.win0Fit5           = data{1,17};
ART_ENG.win0Fit6           = data{1,18};
ART_ENG.win0Fit7           = data{1,19};
ART_ENG.win0Fit8           = data{1,20};
ART_ENG.win0Fit9           = data{1,21};
ART_ENG.win1Fit0           = data{1,22};
ART_ENG.win1Fit1           = data{1,23};
ART_ENG.win1Fit2           = data{1,24};
ART_ENG.win1Fit3           = data{1,25};
ART_ENG.win1Fit4           = data{1,26};
ART_ENG.win1Fit5           = data{1,27};
ART_ENG.win1Fit6           = data{1,28};
ART_ENG.win1Fit7           = data{1,29};
ART_ENG.win1Fit8           = data{1,30};
ART_ENG.win1Fit9           = data{1,31};
ART_ENG.win0InitialChi2    = data{1,32};
ART_ENG.win0FinalChi2      = data{1,33};
ART_ENG.win1InitialChi2    = data{1,34};
ART_ENG.win1FinalChi2      = data{1,35};
ART_ENG.det_bkgd           = data{1,36};
ART_ENG.HCHO_ppb           = data{1,37};
ART_ENG.H2O_ppm            = data{1,38};
ART_ENG.CH3OH              = data{1,39};
ART_ENG.corrected_HCHO_ppb = data{1,40};
ART_ENG.mean_H2O_ppm       = data{1,41};
ART_ENG.mean_CH3OH         = data{1,42};
ART_ENG.battery_charge_V   = data{1,43};
ART_ENG.power_input_mV     = data{1,44};
ART_ENG.current_mA         = data{1,45};
ART_ENG.SOC_percent        = data{1,46};
ART_ENG.battery_T_degC     = data{1,47};
ART_ENG.FET_T_degC         = data{1,48};

figure,plot(ART_ENG.datetime,ART_ENG.corrected_HCHO_ppb)
%------------- END OF CODE -------------

