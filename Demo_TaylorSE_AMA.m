%% Demostration file for Taylor SE with the Augmented Matrix approach

%% Clear start

path(pathdef); clear; close; clc

%% Path and Grid preperation

addpath([pwd,'\Subfunctions']);  % Add subfunction path

Inputs = struct;
Inputs.Grid_Name      = 'S1a_de';

Inputs.NodeRes_Name   = [pwd,'\LoadFlow_Results\',Inputs.Grid_Name,'_NodeRes_raw.mat'  ];
Inputs.BranchRes_Name = [pwd,'\LoadFlow_Results\',Inputs.Grid_Name,'_BranchRes_raw.mat'];
Inputs.Grid_Path      = [pwd,'\Sincal_Grids\'                                          ];

% TODO later (integration of pseudo-values)
Inputs.pseudo = false;
Inputs.LP_DB_name   = ''; 
Inputs.PV_DB_name   = '';  
Inputs.LP_dist_name = ''; % [SinName, '_LoadNameOriginal.txt'      ];
Inputs.PV_dist_name = ''; % [SinName, '_DCInfeederNameOriginal.txt'];

tic
[BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] = AugmentedMatrix_Algorithm_Benchmark(Inputs);
toc

% plot(NodeRes_all        .U1 - NodeRes_all_exakt.U1)
% plot(BranchRes_all_exakt.I1 - BranchRes_all.    I1)