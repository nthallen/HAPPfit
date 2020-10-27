function HAPPfit_OutputProcessing(run_date,output_directory, mode, mode_scaling_factor)
% HAPPfit_OutputProcessing - Converts the output from HAPP fit into HCHO mixing ratios. 
% Generates a .mat file at the end for all HAPP fit-derived HCHO mixing ratios.
%
% Syntax: HAPPfit_OutputProcessing(run_date,output_directory, mode, mode_scaling_factor)
%
% Inputs:
%   run_date -            Date of run (e.g. '170719.1')
%   output_directory -    Directory where HAPP fit output is stored (e.g. 'ICOSout.all')
%   mode -                Specify whether the experiment was done in HDO or 
%                         CH4 mode (e.g.'HDO'). Only use CH4 mode if an 
%                         actual CH4 cylinder was used.
%   mode_scaling_factor - Apply the appropriate scaling factor that's
%                         dependent on the mode used during data collection.
%                         In general, this scaling factor is derived from a 
%                         stepped calibration that's performed on the Aeris 
%                         sensor beforehand.
%   
% Outputs:
%   MAT file containing the HAPP fit-derived HCHO mixing ratios
%
% Notes: Depending on how many spectral lines were fit, the column of
% Chiout that corresponds to HCHO might change. Please verify that you are
% using the correct column of Chiout!
%
% Required files: mixlines.m, isovals.m, ParseAerisRawSpectra.m, chunker.m
% 
% Author: Joshua Shutter (JDS)
% Email: shutter@g.harvard.edu
% Date Created: 29-April-2018
% Revisions: 04-July-2018: Minor improvements to code
%            15-May-2019: Preparing for public distribution

%% ADDING DIRECTORIES TO MATLAB PATH

OutputDir  = ['D:\Aeris\Data\',run_date,'\',output_directory,'\'];
RawDir = ['D:\Aeris\Data\RAW\',run_date,'\'];
SaveDir  = ['D:\Aeris\Data\',run_date,'\'];

addpath(OutputDir)
addpath(RawDir)
addpath(SaveDir)

%% IMPORT ICOSFIT OUTPUT DATA AND SCALE TO MIXING RATIO
%Call mixlines.m in order to obtain HAPP fit data
[ Chiout, xout, Pout, lines_out ] = mixlines(output_directory, 4);

%Obtain abundance info from HITRAN using isovals.m
abund = isovals( 201, 'abundance' ); 
% Isovals values for Aeris lines
% HCHO: 201
% HDO : 14 
% CH4 : 61

switch mode
    case 'HDO' 
         o.HAPPoutput = Chiout(:,3)*1e9*abund*mode_scaling_factor;   
    case 'CH4' 
         o.HAPPoutput = Chiout(:,3)*1e9*abund*mode_scaling_factor;
    otherwise
        error('HDO or CH4 mode not specified')
end

% Please note: The column of Chiout that corresponds to HCHO might
% vary depending on the number of total spectral lines being fit by HAPP.
% Also, Chiout needs to be scaled to ppbv since it's not actually a
% mixing ratio. That's why the user needs to perform a stepped calibration
% of the sensor to determine the mode-dependent scaling factor. When
% deriving the scaling factor, ensure that all lines that you wish to fit
% are included when working up the stepped calibration.

%% IMPORTING INLET INFORMATION FROM RAW DATA FILE

%Find 1 Hz raw spectra file and extract inlet and time information
flnm = dir(fullfile(RawDir,'*spectra.txt'));
flnm = {flnm.name};
d = ParseAerisRawSpectra(flnm{1}); 

% Specifying xout automatically accounts for running HAPP in forward or reverse
o.datetime = d.datetime(xout);
o.inlet_number = d.inlet_number(xout);

%% SEPARATE AND CHUNK SCRUBBED (ZERO) and UNSCRUBBED (ONE) INLET DATA

% Make some indices
o.zero      = find(o.inlet_number==0); %Zero inlet with DNPH cartridge
o.one       = find(o.inlet_number==1); %Sample inlet

% Chunk the indices
inlet_zero = chunker(o.zero);
inlet_one = chunker(o.one);

%% DETERMINE DIFFERENCE BETWEEN INLETS TO CALCULATE HCHO MIXING RATIO
% The difference between the inlets is the actual HCHO mixing ratio in the
% air sample

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Note that there's hysteresis due to the valve switching between the 
% scrubbed (DNPH) and unscrubbed inlets. This effect is eliminated by 
% removing the first seven seconds of each inlet cycle. It was also 
% discovered that removing the last point of each cycle also helped in 
% producing a more accurate mixing ratio.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ZERO INLET
l=size(inlet_zero,1)-1; %(-1) done to prevent incomplete chunks from final analysis

for i=1:l
    j = inlet_zero(i,1)+7:inlet_zero(i,2)-1;
    % Outlier removal within a set using the Hampel identifier
    zero.HAPPoutput(i) = nanmean(hampel(o.HAPPoutput(j)));
end

%Choose time that corresponds to first time in chunk
for i=1:l
    j = inlet_zero(i,1)+7;
    zero.datetime(i) = o.datetime(j);
end


%ONE INLET
l=size(inlet_one,1)-1; %(-1) done to prevent incomplete chunks from final analysis

for i=1:l
    j = inlet_one(i,1)+7:inlet_one(i,2)-1;
    % Outlier removal within a set using the Hampel identifier
    one.HAPPoutput(i) = nanmean(hampel(o.HAPPoutput(j)));
end

%Choose time that corresponds to first time in chunk
for i=1:l
    j = inlet_one(i,1)+7; 
    one.datetime(i) = o.datetime(j);
end

clear('i','j','l')

% Need the following condition since sometimes the number of chunks for 
% the one and zero inlets don't match
if length(one.datetime) > length(zero.datetime)
    k = length(zero.datetime);
else
    k = length(one.datetime);
end

%Finalized HCHO concentration is the difference between one and zero inlets
for i=1:k
    
if one.datetime(1) < zero.datetime(1) 
    if i==1
        o.HCHO(i) = one.HAPPoutput(i) - zero.HAPPoutput(i);
    else
        o.HCHO(i) = one.HAPPoutput(i) - (zero.HAPPoutput(i)+zero.HAPPoutput(i-1))/2;
    end    
else
    if i==k
        o.HCHO(i) = one.HAPPoutput(i) - zero.HAPPoutput(i);
    else
        o.HCHO(i) = one.HAPPoutput(i) - (zero.HAPPoutput(i)+zero.HAPPoutput(i+1))/2;
    end    
end
o.datetime_FINAL(i) = one.datetime(i);
end

%% SAVING TO MAT FILE
% Save HAPP fit-derived HCHO mixing ratios to a .mat file

HAPP.datetime = o.datetime_FINAL;
HAPP.HCHO = o.HCHO;
save(fullfile(SaveDir,strcat('HAPPfit_HCHO_',output_directory,'.mat')),'HAPP');
