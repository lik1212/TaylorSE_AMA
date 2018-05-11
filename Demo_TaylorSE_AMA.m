%% Demostration file for Taylor SE with the Augmented Matrix approach
%  As input you need z_all_data, z_all_flag, U_eva and LineInfo, check
%  the input data description for more details. All other parts of this
%  Code are just an input/output preperation.
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

addpath([pwd,'\Subfunctions'       ]);  % Add subfunction path
addpath([pwd,'\Subfunctions4Sincal']);  % Add subfunction path for Sincal

%% Prepare Sincal Results as input for the TaylorSE_AMA
%  This is not part of the main SE, just the input preperation

Inputs                    = struct                                       ;
Inputs.Grid_Name          = 'S1a_de'                                     ;
Inputs.LF_Res_Path        = [pwd, '\LoadFlow_Results\'                  ];
Inputs.Grid_Path          = [pwd, '\Subfunctions4Sincal\Sincal_Grids\'  ];
Inputs.NodeRes_Name       = [Inputs.Grid_Name, '_NodeRes_raw.mat'       ];
Inputs.BranchRes_Name     = [Inputs.Grid_Name, '_BranchRes_raw.mat'     ];
Inputs.Simulation_Details = [Inputs.Grid_Name, '_Simulation_Details.mat'];
Inputs.with_TR            = true                                         ;
Inputs.pseudo             = false                                        ;  

% Remove trafo if in Results
if Inputs.with_TR; removeTR(Inputs); end

MeasurPos                = GetMeasurPosition(Inputs);
[z_all_data, z_all_flag] = GetVector_z(Inputs, MeasurPos);
LineInfo = GetLineInfo(Inputs);
U_eva           = 400/sqrt(3); % Set voltage amount of evaluation (eva) point of linearization


tic

%% Main estimation alfo

[z_estimate, Optional] = TaylorSE_AMA(z_all_data, z_all_flag, LineInfo, U_eva);


[BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] =  get4compare(Inputs, z_estimate, Optional.Y_L1L2L3);
% [BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] = AugmentedMatrix_Algorithm_Benchmark(Inputs);
toc
% 
subplot(2,1,1)
plot(NodeRes_all        .U1 - NodeRes_all_exakt.U1)
subplot(2,1,2)
plot(BranchRes_all_exakt.I1 - BranchRes_all.    I1)