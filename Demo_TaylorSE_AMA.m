%% Demostration file for Taylor SE with the Augmented Matrix approach
%  As input you need z_all_data, z_all_flag, U_eva and LineInfo, check
%  the input data description for more details. All other parts of this
%  Code are just an input/output preperation.

%% Clear start

path(pathdef); clear; close; clc

%% Input preperation

Inputs                    = struct                                       ;
Inputs.Grid_Name          = 'S1a_de'                                     ;
Inputs.LF_Res_Path        = [pwd, '\LoadFlow_Results\'                  ];
Inputs.Grid_Path          = [pwd, '\Sincal_Grids\'                      ];
Inputs.NodeRes_Name       = [Inputs.Grid_Name, '_NodeRes_raw.mat'       ];
Inputs.BranchRes_Name     = [Inputs.Grid_Name, '_BranchRes_raw.mat'     ];
Inputs.Simulation_Details = [Inputs.Grid_Name, '_Simulation_Details.mat'];
Inputs.with_TR            = true                                         ;
Inputs.pseudo             = false                                        ;  

%% Path preperation

addpath([pwd,'\Subfunctions']);  % Add subfunction path

%% Prepare Sincal Results as input for the TaylorSE_AMA

if Inputs.with_TR; removeTR(Inputs); end
MeasurPos = GetMeasurPosition(Inputs);
[z_all_data, z_all_flag] = GetVector_z(Inputs, MeasurPos);
LineInfo = GetLineInfo(Inputs);
U_eva           = 400/sqrt(3); % Set voltage amount of evaluation (eva) point of linearization


tic

%% Main estimation alfo

[z_estimate, Optional] = new_algo(z_all_data, z_all_flag, LineInfo, U_eva);


[BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] =  get4compare(Inputs, z_estimate, Optional.Y_L1L2L3);
% [BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] = AugmentedMatrix_Algorithm_Benchmark(Inputs);
toc
% 
subplot(2,1,1)
plot(NodeRes_all        .U1 - NodeRes_all_exakt.U1)
subplot(2,1,2)
plot(BranchRes_all_exakt.I1 - BranchRes_all.    I1)