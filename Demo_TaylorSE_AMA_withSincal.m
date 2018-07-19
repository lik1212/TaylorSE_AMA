%% Demostration file for Taylor SE with the Augmented Matrix approach &
%  Sincal power flow data as input
%
%  As input you need z_all_data, z_all_flag, U_eva and LineInfo, check
%  the input data description for more details. All other parts of this
%  Code are just an input/output preperation for better comparison with
%  Sincal power flow results.
%
% Author(s):    R. Brandalik
%               D. Henschel
%               J. Tu
%               P. Gassler
%
% Contact: brandalikrobert@gmail.com, brandalik@eit.uni-kl.de
%
% Special thanks go to the entire TUK ESEM team.
%
% Parts of the work were the result of the project CheapFlex, sponsored by
% the German Federal Ministry of Economic Affairs and Energy as part of the
% 6th Energy Research Programme of the German Federal Government.

%% Clear start

path(pathdef); clear; close; clc

%% Path preperation

addpath([pwd,             '\Subfunctions']);  % Add subfunction path
addpath([pwd,'\Files4Sincal\Subfunctions']);  % Add subfunction path for Sincal

%% Prepare Sincal Results as input for the TaylorSE_AMA
%  This is not part of the main SE, just the input preperation

Input_Prep                    = struct                                           ;
Input_Prep.Grid_Name          = 'S1a_de'                                         ;
Input_Prep.LF_Res_Path        = [pwd, '\Files4Sincal\Results\'                  ];
Input_Prep.Grid_Path          = [pwd, '\Files4Sincal\Grids\'                    ];
Input_Prep.NodeRes_Name       = [Input_Prep.Grid_Name, '_NodeRes_raw.mat'       ];
Input_Prep.BranchRes_Name     = [Input_Prep.Grid_Name, '_BranchRes_raw.mat'     ];
Input_Prep.Simulation_Details = [Input_Prep.Grid_Name, '_Simulation_Details.mat'];
Input_Prep.with_TR            = true                                             ;
Input_Prep.pseudo             = false                                            ;  

%% Prepare Measurement Data from Sincal

% Remove trafo if in Results
if Input_Prep.with_TR; removeTR(Input_Prep); end
LineInfo  = GetLineInfo      (Input_Prep);
MeasurPos = GetMeasurPosition(Input_Prep);

% Get measurement data
[z_all_data, z_all_flag] = GetVector_z(Input_Prep, MeasurPos); 

%% Add noise

rng(0);
z_all_data_noisy = z_all_data + normrnd(0, 1, size(z_all_data)) .* z_all_flag.Sigma;

%% Inputs for State Estimation (can be extended with Inputs)

Inputs_SE.U_eva = 400/sqrt(3); % Voltage of linearization evaluation (eva)

%% Main estimation alfo

tic
[x_hat, z_hat, z_hat_full, Out_Optional] = TaylorSE_AMA(z_all_data_noisy, z_all_flag, LineInfo, Inputs_SE);
toc

%% Compare results with input

[BranchRes_all_estim, BranchRes_all_exakt, NodeRes_all_estim, NodeRes_all_exakt] = get4compare(Input_Prep, z_hat_full, Out_Optional.Y_L1L2L3);

subplot(2,1,1)
plot((NodeRes_all_estim  .U1 - NodeRes_all_exakt  .U1) * 10^3);
ylabel('Error in V');
subplot(2,1,2)
plot((BranchRes_all_exakt.I1 - BranchRes_all_estim.I1) * 10^3);
ylabel('Error in A');
