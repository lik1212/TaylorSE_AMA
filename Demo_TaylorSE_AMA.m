%% Demostration file for Taylor SE with the Augmented Matrix approach

%% Clear start

path(pathdef); clear; close; clc

%% Path and Grid preperation

addpath([pwd,'\Subfunctions']);  % Add subfunction path

Inputs = struct;
Inputs.Grid_Name      = 'S1a_de';
Inputs.LF_Res_Path    = [pwd, '\LoadFlow_Results\'             ];
Inputs.Grid_Path      = [pwd, '\Sincal_Grids\'                 ];
Inputs.NodeRes_Name   = [Inputs.Grid_Name, '_NodeRes_raw.mat'  ];
Inputs.BranchRes_Name = [Inputs.Grid_Name, '_BranchRes_raw.mat'];
Inputs.pseudo         = 'false';

MeasurPos = GetMeasurPosition(Inputs)
[z_all_data, z_all_flag] = GetVector_z(Inputs);

tic
[BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] = AugmentedMatrix_Algorithm_Benchmark(Inputs);
toc

subplot(2,1,1)
plot(NodeRes_all        .U1 - NodeRes_all_exakt.U1)
subplot(2,1,2)
plot(BranchRes_all_exakt.I1 - BranchRes_all.    I1)