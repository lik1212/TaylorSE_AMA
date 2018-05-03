%% Demostration file for Taylor SE with the Augmented Matrix approach

%% Clear start

path(pathdef); clear; close; clc

%% Path and Grid preperation

Grid_Name      = 'S1a_de';
addpath([pwd,'\Subfunctions']);  % Add subfunction path

NodeRes_Name   = [pwd,'\LoadFlow_Results\',Grid_Name,'_NodeRes_raw.mat'  ];
BranchRes_Name = [pwd,'\LoadFlow_Results\',Grid_Name,'_BranchRes_raw.mat'];
Grid_Path      = [pwd,'\Sincal_Grids\'                                   ];
% TODO later (integration of pseudo-values)
pseudo = false;
LP_DB_name   = ''; 
PV_DB_name   = '';  
LP_dist_name = ''; % [SinName, '_LoadNameOriginal.txt'      ];
PV_dist_name = ''; % [SinName, '_DCInfeederNameOriginal.txt'];

tic
[BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] = AugmentedMatrix_Algorithm_Benchmark(NodeRes_Name,BranchRes_Name,pseudo,LP_DB_name,PV_DB_name,LP_dist_name,PV_dist_name,Grid_Name,Grid_Path);
toc

% plot(NodeRes_all        .U1 - NodeRes_all_exakt.U1)
% plot(BranchRes_all_exakt.I1 - BranchRes_all.    I1)