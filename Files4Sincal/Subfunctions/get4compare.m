function [BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] = get4compare(Input_Prep, z_estimate, Y_L1L2L3)
%GET4COMPARE Summary of this function goes here
%   Detailed explanation goes here
% 
if Input_Prep.with_TR == false
    NodeRes_PathName   = [Input_Prep.LF_Res_Path, Input_Prep.NodeRes_Name   ];
    BranchRes_PathName = [Input_Prep.LF_Res_Path, Input_Prep .BranchRes_Name];
    SimDetails         = [Input_Prep.LF_Res_Path, Input_Prep.Simulation_Details];
else
    NodeRes_PathName   = [Input_Prep.LF_Res_Path, Input_Prep.NodeRes_Name(1 : end - 4)   ,'_wo_TR.mat'];
    BranchRes_PathName = [Input_Prep.LF_Res_Path, Input_Prep .BranchRes_Name(1 : end - 4),'_wo_TR.mat'];
    SimDetails         = [Input_Prep.LF_Res_Path, Input_Prep.Simulation_Details(1 : end - 4)   ,'_wo_TR.mat'];
end


load(SimDetails       ,'SimDetails')

All______Node_ID  = unique(SimDetails.SinInfo.Node.      Node_ID );
All______Node_pos = ismember(SimDetails.SinInfo.Node.Node_ID,All______Node_ID);
num_Nodes     = numel(All______Node_pos);	% Get number of grid nodes and number of time step
num_PNM_Types = 4;                          % PNM - Posible noad measurements; 4 Types: U, phi, P, Q
num_PMN___max = 3 *num_Nodes;               % Max. posible measurements at nodes (PMN)

load(NodeRes_PathName,'NodeRes_all');
% disp([NodeRes_PathName,' sucessfully loaded.']);
NodeRes_all = sortrows(NodeRes_all,'Node_ID','ascend');
NodeRes_all = sortrows(NodeRes_all,'ResTime','ascend');

% Save exakt

NodeRes_all_exakt = NodeRes_all;

NodeRes_all = z_results2NodeRes_all(z_estimate,SimDetails.SinInfo,size(z_estimate,2),num_PNM_Types,num_PMN___max,num_Nodes);
BranchRes_all = NodeRes2BranchRes(NodeRes_all,SimDetails.SinInfo,Y_L1L2L3);
BranchRes_all_exakt = NodeRes2BranchRes(NodeRes_all_exakt,SimDetails.SinInfo,Y_L1L2L3);
end

