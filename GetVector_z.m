% function [z_all_data, z_all_flag] = GetVector_z(Inputs)
%GETVECTOR_Z Adjust the Sincal Results to a measurement vector z
%   TOOD


NodeRes_PathName   = [Inputs.LF_Res_Path, Inputs.NodeRes_Name   ];
BranchRes_PathName = [Inputs.LF_Res_Path, Inputs .BranchRes_Name];

load(NodeRes_PathName  ,'NodeRes_all'  );
load(BranchRes_PathName,'BranchRes_all');

% TODO, Input somehow with Range of Steps or RAM Problems
% BranchRes for P, Q, S and I and NodeRes for U, phi, P, Q, S  for all phases
num_z_all_max = 12 * size(BranchRes_all, 1) + 15 * size(NodeRes_all, 1);
z_all_data = zeros(num_z_all_max, 1);

