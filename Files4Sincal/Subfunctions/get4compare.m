function [BranchRes_all_estim, NodeRes_all_estim] = get4compare(Input_Prep, z_hat_full, Y_L1L2L3)
%GET4COMPARE Prepare the estimated data to compare with exakt data (the
%exakt data is the load flow result used as input data for SE)
%
%   Input:
%       Input_Prep - Information about the load flow data (exakt data)
%       z_hat_full - Result of State Estimation (U, phi, P and Q for all
%                    Nodes)
%       Y_L1L2L3   - admittance matrix in conductor quantity
%
%   Output:
%       Exakt and Estimated Branch and Node results 

%% Load exakt values to compare with estimated

if Input_Prep.with_TR == false % Data with or wo TR
    SimDetails         = [Input_Prep.LF_Res_Path, Input_Prep.Simulation_Details];
else
    SimDetails         = [Input_Prep.LF_Res_Path, Input_Prep.Simulation_Details(1 : end - 4) ,'_wo_TR.mat'];
end
load(SimDetails        , 'SimDetails'   );

SinInfo             = SimDetails.SinInfo;

clear NodeRes_all BranchRes_all SimDetails

%% Preparing estimated data in the same form as the input from Sincal

NodeRes_all_estim   = z_full2NodeRes_all(z_hat_full, SinInfo);
BranchRes_all_estim = NodeRes2BranchRes(NodeRes_all_estim, SinInfo, Y_L1L2L3);
