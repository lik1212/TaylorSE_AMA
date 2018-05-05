function [z_all_data, z_all_flag] = GetVector_z(Inputs, MeasurPos)
%GETVECTOR_Z Adjust the Sincal Results to a measurement vector z
%   TOOD


NodeRes_PathName   = [Inputs.LF_Res_Path, Inputs.NodeRes_Name   ];
BranchRes_PathName = [Inputs.LF_Res_Path, Inputs .BranchRes_Name];

load(NodeRes_PathName  ,'NodeRes_all'  );
load(BranchRes_PathName,'BranchRes_all');

num_z_meas_inst = sum(sum((MeasurPos{:,3:end} == 1)));
num_z_pseu_inst = sum(sum((MeasurPos{:,3:end} == 2)));
num_z_virt_inst = sum(sum((MeasurPos{:,3:end} == 3)));

num_z_all_inst  = num_z_meas_inst + num_z_pseu_inst + num_z_virt_inst;
num_inst   = max(NodeRes_all.ResTime) - min(NodeRes_all.ResTime) + 1;

% TODO, Input somehow with Range of Steps or RAM Problems
% BranchRes for P, Q, S and I and NodeRes for U, phi, P, Q, S  for all phases
num_z_all  = num_z_all_inst * num_inst;
z_all_data = zeros(num_z_all, 1);

