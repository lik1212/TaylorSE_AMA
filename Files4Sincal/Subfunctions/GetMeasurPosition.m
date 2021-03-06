function MeasurPos = GetMeasurPosition(Inputs)
%GETMEASURPOSITION Based on the input information define measurements of
%   all nodes and branches. The measurement flags have the following
%   meaning: 1 - measurement value, 2 - pseudo value, 3 - virtual value
%
%   TODO: This function defines the default MeasurPos, other function can
%   addjust the position of the measurements. Needs revision in the future.

%% Load SinInfo of the Sincal Model

SimDetails = load([Inputs.LF_Res_Path, Inputs.Simulation_Details] ,'SimDetails');

SinInfo = SimDetails.SimDetails.SinInfo;
    
%% Initial matrix of measurements

if isfield(SinInfo, 'TwoWindingTransformer')
    SinInfo.Line = ...
        [SinInfo.Line; SinInfo.TwoWindingTransformer];  % TODO: Replace Infeeder?    
end

num_Node   = size(SinInfo.Node, 1)    ;
num_Branch = size(SinInfo.Line, 1) * 2;
num_all    = num_Node + num_Branch    ;
 
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
    SinInfo.Node.Node_ID; SinInfo.Line.Node1_ID; SinInfo.Line.Node2_ID]; % [Node, Branch one direction, Branch other direction]
MeasurPos.Node2_ID (num_Node + 1 : num_all) = [...
    SinInfo.Line.Node2_ID; SinInfo.Line.Node1_ID];                       % [Node, Branch one direction, Branch other direction]

%% Node seperation

Node_ID_all      = SinInfo.Node.Node_ID;
Node_ID_Infeeder = unique(SinInfo.Infeeder.  Node1_ID);
% Sometimes they are no DCInfeeder
if any(ismember(fields(SinInfo),'DCInfeeder'))
    Node_ID_PV       = unique(SinInfo.DCInfeeder.Node1_ID);
else
    Node_ID_PV = [];
end
Node_ID_Load     = unique(SinInfo.Load.      Node1_ID);
Node_ID_Joint    = setdiff(Node_ID_all, ...
    [Node_ID_Infeeder; Node_ID_PV; Node_ID_Load]);  % TODO after function revision. Depents on the Input.pseudo flag

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
