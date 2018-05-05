function MeasurPos = GetMeasurPosition(Inputs)
%% Load SinInfo

SincalModel.Name = Inputs.Grid_Name;    % Get sincal model Name
SincalModel.Info = ...
    Mat2Sin_GetSinInfo(SincalModel.Name, Inputs.Grid_Path);

%% Initial matrix of measurements

if isfield(SincalModel.Info, 'TwoWindingTransformer')
    SincalModel.Info.Line = ...
        [SincalModel.Info.Line; SincalModel.Info.TwoWindingTransformer];
    % TODO -> Replace Infeeder with 
end

num_Node   = size(SincalModel.Info.Node, 1);
num_Branch = size(SincalModel.Info.Line, 1);
num_all    = num_Node + num_Branch;
 
% all_measur = num_Node + 2 * num_Branch;
MeasurPos = array2table(                 ...
    NaN(num_all, 20),                    ... % 20: Node1_ID, Node_2ID, 3 * (U, phi, P, Q, S, I)
    'VariableNames',{                    ...
    'Node1_ID', 'Node2_ID'               ...
    'U1', 'phi1', 'P1', 'Q1', 'S1', 'I1' ...
    'U2', 'phi2', 'P2', 'Q2', 'S2', 'I2' ...
    'U3', 'phi3', 'P3', 'Q3', 'S3', 'I3' ...
    });

%% Add IDs to Matrix of measurements

MeasurPos.Node1_ID = [...
    SincalModel.Info.Node.Node_ID; SincalModel.Info.Line.Node1_ID];
MeasurPos.Node2_ID (num_Node + 1 : num_all) = ...
    SincalModel.Info.Line.Node2_ID;

%% Node seperation

Node_ID_all      = SincalModel.Info.Node.Node_ID;
Node_ID_Infeeder = unique(SincalModel.Info.Infeeder.  Node1_ID);
Node_ID_PV       = unique(SincalModel.Info.DCInfeeder.Node1_ID);
Node_ID_Load     = unique(SincalModel.Info.Load.      Node1_ID);
Node_ID_Joint    = setdiff(SincalModel.Info.Node.Node_ID, ...
    [Node_ID_Infeeder; Node_ID_PV; Node_ID_Load]);

Measured_UPQ_Node_ID = unique([Node_ID_Infeeder; Node_ID_PV; Node_ID_Load]);
Virtual_PQ_Node_ID   = setdiff(Node_ID_all, Measured_UPQ_Node_ID);
Virtual_phi_Node_ID  = Node_ID_Infeeder;

%% Node measurement position, flag for measurement value position is 1

MeasurPos.U1(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Measured_UPQ_Node_ID)) = 1;
MeasurPos.U2(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Measured_UPQ_Node_ID)) = 1;
MeasurPos.U3(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Measured_UPQ_Node_ID)) = 1;
MeasurPos.P1(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Measured_UPQ_Node_ID)) = 1;
MeasurPos.P2(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Measured_UPQ_Node_ID)) = 1;
MeasurPos.P3(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Measured_UPQ_Node_ID)) = 1;
MeasurPos.Q1(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Measured_UPQ_Node_ID)) = 1;
MeasurPos.Q2(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Measured_UPQ_Node_ID)) = 1;
MeasurPos.Q3(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Measured_UPQ_Node_ID)) = 1;

%% Node pseudo position, flag for pseudo values position is 2
%% Node virtual position, flag for virtual values position is 3

MeasurPos.phi1(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Virtual_phi_Node_ID)) = 3;
MeasurPos.phi2(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Virtual_phi_Node_ID)) = 3;
MeasurPos.phi3(isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Virtual_phi_Node_ID)) = 3;
MeasurPos.P1  (isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Virtual_PQ_Node_ID )) = 3;
MeasurPos.P2  (isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Virtual_PQ_Node_ID )) = 3;
MeasurPos.P3  (isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Virtual_PQ_Node_ID )) = 3;
MeasurPos.Q1  (isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Virtual_PQ_Node_ID )) = 3;
MeasurPos.Q2  (isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Virtual_PQ_Node_ID )) = 3;
MeasurPos.Q3  (isnan(MeasurPos.Node2_ID) & ismember(MeasurPos.Node1_ID, Virtual_PQ_Node_ID )) = 3;

%% Pseudo Node Positions

% %% Real Measurements in measurement vector z
% 
% % Initial
% z_meas____pos___U = false(num_PNM_Types * num_PMN___max, 1);
% z_meas____pos_phi = false(num_PNM_Types * num_PMN___max, 1);
% z_meas____pos___P = false(num_PNM_Types * num_PMN___max, 1);
% z_meas____pos___Q = false(num_PNM_Types * num_PMN___max, 1);
% 
% z_meas____pos___U(                    1 :     num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Measured_Node_U1___pos';...
%     Measured_Node_U2___pos';...
%     Measured_Node_U3___pos'],[],1);
% 
% z_meas____pos_phi(    num_PMN___max + 1 : 2 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Measured_Node_phi1_pos';...
%     Measured_Node_phi2_pos';...
%     Measured_Node_phi3_pos'],[],1);
% 
% z_meas____pos___P(2 * num_PMN___max + 1 : 3 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Measured_Node_P1___pos';...
%     Measured_Node_P2___pos';...
%     Measured_Node_P3___pos'],[],1);
% 
% z_meas____pos___Q(3 * num_PMN___max + 1 : 4 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Measured_Node_Q1___pos';...
%     Measured_Node_Q2___pos';...
%     Measured_Node_Q3___pos'],[],1);
% 
% z_meas____pos_all = ...
%     z_meas____pos___U | ...
%     z_meas____pos_phi | ...
%     z_meas____pos___P | ...
%     z_meas____pos___Q   ...
%     ;
% 
% z_meas____num___U = sum(z_meas____pos___U);
% z_meas____num_phi = sum(z_meas____pos_phi);
% z_meas____num___P = sum(z_meas____pos___P);
% z_meas____num___Q = sum(z_meas____pos___Q);
% z_meas____num_all = sum(z_meas____pos_all);  	% Get number of real measurements in z
% 
% %% Virtual Measurements in measurement vector z
% 
% % Initial
% z_virtual_pos___U = false(num_PNM_Types * num_PMN___max, 1);
% z_virtual_pos_phi = false(num_PNM_Types * num_PMN___max, 1);
% z_virtual_pos___P = false(num_PNM_Types * num_PMN___max, 1);
% z_virtual_pos___Q = false(num_PNM_Types * num_PMN___max, 1);
% 
% z_virtual_pos___U(                    1 :     num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Virtual__Node_U1___pos';...
%     Virtual__Node_U2___pos';...
%     Virtual__Node_U3___pos'],[],1);
% 
% z_virtual_pos_phi(    num_PMN___max + 1 : 2 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Virtual__Node_phi1_pos';...
%     Virtual__Node_phi2_pos';...
%     Virtual__Node_phi3_pos'],[],1);
% 
% z_virtual_pos___P(2 * num_PMN___max + 1 : 3 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Virtual__Node_P1___pos';...
%     Virtual__Node_P2___pos';...
%     Virtual__Node_P3___pos'],[],1);
% 
% z_virtual_pos___Q(3 * num_PMN___max + 1 : 4 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Virtual__Node_Q1___pos';...
%     Virtual__Node_Q2___pos';...
%     Virtual__Node_Q3___pos'],[],1);
% 
% z_virtual_pos_all = ...
%     z_virtual_pos___U | ...
%     z_virtual_pos_phi | ...
%     z_virtual_pos___P | ...
%     z_virtual_pos___Q   ...
%     ;
% 
% % z_virtual_num___U = sum(z_virtual_pos___U);
% % z_virtual_num_phi = sum(z_virtual_pos_phi);
% % z_virtual_num___P = sum(z_virtual_pos___P);
% % z_virtual_num___Q = sum(z_virtual_pos___Q);
% z_virtual_num_all = sum(z_virtual_pos_all);   	% Get number of virtual measurements in z
% 
% %% Pseudo Measurements in measurement vector z
% 
% % Initial
% z_pseudo__pos___U = false(num_PNM_Types * num_PMN___max, 1);
% z_pseudo__pos_phi = false(num_PNM_Types * num_PMN___max, 1);
% z_pseudo__pos___P = false(num_PNM_Types * num_PMN___max, 1);
% z_pseudo__pos___Q = false(num_PNM_Types * num_PMN___max, 1);
% 
% z_pseudo__pos___U(                    1 :     num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Pseudo___Node_U1___pos';...
%     Pseudo___Node_U2___pos';...
%     Pseudo___Node_U3___pos'],[],1);
% 
% z_pseudo__pos_phi(    num_PMN___max + 1 : 2 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Pseudo___Node_phi1_pos';...
%     Pseudo___Node_phi2_pos';...
%     Pseudo___Node_phi3_pos'],[],1);
% 
% z_pseudo__pos___P(2 * num_PMN___max + 1 : 3 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Pseudo___Node_P1___pos';...
%     Pseudo___Node_P2___pos';...
%     Pseudo___Node_P3___pos'],[],1);
% 
% z_pseudo__pos___Q(3 * num_PMN___max + 1 : 4 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
%     Pseudo___Node_Q1___pos';...
%     Pseudo___Node_Q2___pos';...
%     Pseudo___Node_Q3___pos'],[],1);
% 
% z_pseudo__pos_all = ...
%     z_pseudo__pos___U | ...
%     z_pseudo__pos_phi | ...
%     z_pseudo__pos___P | ...
%     z_pseudo__pos___Q   ...
%     ;
% 
% z_pseudo__num___U = sum(z_pseudo__pos___U);
% z_pseudo__num_phi = sum(z_pseudo__pos_phi);
% z_pseudo__num___P = sum(z_pseudo__pos___P);
% z_pseudo__num___Q = sum(z_pseudo__pos___Q);
% z_pseudo__num_all = sum(z_pseudo__pos_all);   	% Get number of pseudo measurements in z
