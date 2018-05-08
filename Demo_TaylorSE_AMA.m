%% Demostration file for Taylor SE with the Augmented Matrix approach

%% Clear start

path(pathdef); clear; close; clc

%% Path and Grid preperation

addpath([pwd,'\Subfunctions']);  % Add subfunction path

Inputs = struct;
Inputs.Grid_Name          = 'S1a_de';
Inputs.LF_Res_Path        = [pwd, '\LoadFlow_Results\'                         ];
Inputs.Grid_Path          = [pwd, '\Sincal_Grids\'                             ];
Inputs.NodeRes_Name       = [Inputs.Grid_Name, '_NodeRes_raw.mat'              ];
Inputs.BranchRes_Name     = [Inputs.Grid_Name, '_BranchRes_raw.mat'            ];
Inputs.Simulation_Details = [Inputs.Grid_Name, '_Simulation_Details.mat'];
Inputs.with_TR            = true;
Inputs.pseudo             = false;

%%
if Inputs.with_TR; removeTR(Inputs); end

MeasurPos = GetMeasurPosition(Inputs);

[z_all_data, z_all_flag] = GetVector_z(Inputs, MeasurPos);


LineInfo = GetLineInfo(Inputs);
[Y_012, Y_012_Node_ID] = LineInfo2Y_012(LineInfo);
Y_L1L2L3               = Y_012_to_Y_L1L2L3(Y_012);
U_eva           = 1 * 400/sqrt(3); % Set voltage amount of evaluation (eva) point of linearization

[H, H_index] = get_H(Y_L1L2L3, Y_012_Node_ID, U_eva);	

tic
z_estimate = new_algo(z_all_data, z_all_flag, H, H_index);
[BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] =  get4compare(Inputs, z_estimate, Y_L1L2L3);
% [BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] = AugmentedMatrix_Algorithm_Benchmark(Inputs);
toc
% 
subplot(2,1,1)
plot(NodeRes_all        .U1 - NodeRes_all_exakt.U1)
subplot(2,1,2)
plot(BranchRes_all_exakt.I1 - BranchRes_all.    I1)