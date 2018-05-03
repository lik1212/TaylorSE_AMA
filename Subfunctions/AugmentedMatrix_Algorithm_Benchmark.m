function [BranchRes_all, BranchRes_all_exakt, NodeRes_all, NodeRes_all_exakt] = AugmentedMatrix_Algorithm_Benchmark(NodeRes_file,BranchRes_file,pseudo,LP_DB_filename,PV_DB_filename,LP_dist_name,PV_dist_name,SinName)
% function AugmentedMatrix_Algorithm_Benchmark(Memory_Path, Sigma_Power, End_TimeStep)
%%  CheapFlex_LFCvsTaylor_main
%{
        CheapFlex_LFCvsTaylor - Taylor State Estimation with Augmented
        Matrix Aproach, main try

        Flowchart:
                   1. ...

        Supervisor:     Robert Brandalik
        Author(s):      Robert Brandalik, Jiali Tu, Daniel Henschel
%}

%% Clear start

% fclose('all');                      % Close all open files
% close;                              % Close and delete the current figure
% clear                               % Clear all variables
% clearvars -except NodeRes_all r____meas_bench;      % Clear all Variables except of NodeRes_all
% clc;                                % Clear command window
% tic;

fprintf('AugmentedMatrix_Algorithm\n\n');   % Command window output

%% Configurations

U_eva           = 1 * 400/sqrt(3); % Set voltage amount of evaluation (eva) point of linearization
sigma___U_Meas  = 0.1;                % Set standard deviation of voltage (in V) and power measurements (in W respectively var), Meas - Measured
sigma_phi_Meas  = 0.01;
sigma___P_Meas  = 1;
sigma___Q_Meas  = 1;
sigma___U_Pseu  = NaN;                % Set standard deviation of voltage (in V) and power measurements (in W respectively var), Pseu - Pseudo
sigma_phi_Pseu  = NaN;
sigma___P_Pseu  = 50;                 % Watt
sigma___Q_Pseu  = 50;                 % Var
start_TimeStep  = 1;
% end___TimeStep  = 200;
end___TimeStep  = 1440; %24*60;
% pseudo = false;

%% Path and directory preparation

% addpath(           [pwd,'\Subfunctions' ]);  % Add subfunction path
% addpath(           [pwd,'\Static_Input\']);  % Add static input path
% LP_Path          = [cd,'\LFC_Results\' ];   % Get Load Flow calculation results path
% LP_Path          = 'Z:\Gassler\2_Sim\Lastfluss\Ergebnisse LFR Scada\';
SincalModel.Path = [pwd,'\Sincal_Grids\'];   % Get Sincal Grids path
% NodeRes_all_Name = 'NodeRes_all.mat';
% NodeRes_all_Name = 'Wessum-Riete_Netz_170726_NodeRes_raw.mat';

%% Load the load profiles (TODO)

fprintf('Main-Function: 1) Load Profiles\n');   % Command window output
if  exist('NodeRes_all', 'var')                 % Check if file "NodeRes_all.mat" exists
    % if 'NodeRes_all' exists in workspace, there is no need to load it
% elseif  exist([LP_Path,NodeRes_all_Name],'file')
elseif  exist(NodeRes_file,'file')
    load(NodeRes_file);
    disp([NodeRes_file,' sucessfully loaded.']);
    NodeRes_all = sortrows(NodeRes_all,'Node_ID','ascend');
    NodeRes_all = sortrows(NodeRes_all,'ResTime','ascend');
else
    inst = 5256; % TODO, anpassen
    NodeRes_all = loadLFC_Results(LP_Path,inst);
    NodeRes_all = sortrows(NodeRes_all,'Node_ID','ascend');
    NodeRes_all = sortrows(NodeRes_all,'ResTime','ascend');
    save([LP_Path,'NodeRes_all.mat'],'NodeRes_all');
end

%% Save exakt

NodeRes_all_exakt = NodeRes_all;

%% Load Information of Sincal model

fprintf('Main-Function: 2) Load Sincal Model\n');       % Command window output
% try
%     fprintf('Saved SincalModel Info will be loaded!\n'); % and saved as SincalModel.Info\n');
%     load([SincalModel.Path(1:end-13),'Static_Input\','SincalModel_.mat']);
% catch
    SincalModel.Name = SinName;    % Get sincal model Name
    SincalModel.Info = ...
        Mat2Sin_GetSinInfo(SincalModel.Name,SincalModel.Path);
% end

%% Swap or insert Pseudo values for load profiles

fprintf('Main-Function: 2a) Swap P Q measured values with pseudo values\n');   % Command window output
% load('Z:\Gassler\5_SYNTH_Data\Load_Profiles\DB111_10min_synth.mat');
if pseudo
%     NodeRes_all_backup = NodeRes_all;
    load(LP_DB_filename);   % TODO: Besser Funktion-Übergabe 
    load(PV_DB_filename);   % TODO: Besser Funktion-Übergabe 
    NodeRes_all = insert_LP_PseudoValues(NodeRes_all,SincalModel.Info,Load_Profiles,'list',LP_dist_name);
    NodeRes_all = insert_PV_PseudoValues(NodeRes_all,SincalModel.Info,PV___Profiles,'list',PV_dist_name);
    NodeRes_Path = [pwd,'\LFC_Results\']; clear Load_Profiles PV___Profiles
    save([NodeRes_Path,'NodeRes_Pseudo.mat'],'NodeRes_all');
%     clear 'NodeRes_all_backup'
end

%% Check if NodeRes_all contents really all the Results, convert NodeRes_all to table

Node_VN = NodeRes_all.Properties.VariableNames;
NodeRes_all = varfun(@double, NodeRes_all);
NodeRes_all.Properties.VariableNames = Node_VN;
fprintf('Main-Function: 2b) check if all the results are available\n'); 
if istable(NodeRes_all)
    BenchVN = {'U1','phi1','P1','Q1','U2','phi2','P2','Q2','U3','phi3','P3','Q3'};      % VN - VariableNames
    if ~all(ismember(BenchVN,NodeRes_all.Properties.VariableNames))
        fprintf('The Load Flow Calculation results are incomplete. Script stoped\n');   % Command window output
        return;
    end
    % Sort Columns right % TODO, anpassen das nur die BenchVN benutzt werden
    %     NodeRes_all = NodeRes_all(:,randperm(size(NodeRes_all,2))); % To test this part
    if ~all(cellfun(@strcmp, BenchVN, NodeRes_all.Properties.VariableNames([2:5,7:10,12:15])))
        Bench_pos     = cellfun(@(x) find(ismember(NodeRes_all.Properties.VariableNames,x)),BenchVN);
        Not_Bench_pos = setdiff(1:19,Bench_pos);
        NodeRes_all = NodeRes_all(:,[...
            Not_Bench_pos(1) Bench_pos(1:4)  Not_Bench_pos(2)     Bench_pos(5:8)...
            Not_Bench_pos(3) Bench_pos(9:12) Not_Bench_pos(4:end)               ]);
    end
    NodeRes_all.Node_ID = double(NodeRes_all.Node_ID);
    NodeRes_all = NodeRes_all{:,:}; % To double (to make code faster)
end

%% Trafo raus

load(BranchRes_file);
Branch_VN = BranchRes_all.Properties.VariableNames;
BranchRes_all = varfun(@double, BranchRes_all);
BranchRes_all.Properties.VariableNames = Branch_VN;

% NodeID_2_delete = SincalModel.Info.Infeeder.Node1_ID;
% SincalModel.Info.Node(SincalModel.Info.Node.Node_ID == NodeID_2_delete,:) = [];
% NodeID_Infeeder = ...
%     setdiff([SincalModel.Info.TwoWindingTransformer.Node1_ID,SincalModel.Info.TwoWindingTransformer.Node2_ID],NodeID_2_delete);
% SincalModel.Info.Infeeder.Node1_ID = NodeID_Infeeder;    
% ElementID_2_delete = SincalModel.Info.Infeeder.Element_ID;
% SincalModel.Info.Infeeder.Element_ID = SincalModel.Info.TwoWindingTransformer.Element_ID;  
% SincalModel.Info.Terminal(SincalModel.Info.Terminal.Node_ID == NodeID_2_delete & ...
%     SincalModel.Info.Terminal.Element_ID == ElementID_2_delete,:) = [];
% SincalModel.Info = rmfield(SincalModel.Info,'TwoWindingTransformer');
% NodeRes_all(NodeRes_all(:,1) == NodeID_Infeeder,[4:6,9:11,14:16]) = ...
%     NodeRes_all(NodeRes_all(:,1) == NodeID_2_delete,[4:6,9:11,14:16]);
% NodeRes_all(NodeRes_all(:,1) == NodeID_2_delete,:) = [];

NodeID_TR     = [SincalModel.Info.TwoWindingTransformer.Node1_ID,SincalModel.Info.TwoWindingTransformer.Node2_ID];
TerminalID_TR = [SincalModel.Info.TwoWindingTransformer.Terminal1_ID,SincalModel.Info.TwoWindingTransformer.Terminal2_ID];
Node_ID_Infeeder = SincalModel.Info.Infeeder.Node1_ID;
TerminalID_Infeeder = SincalModel.Info.Terminal.Terminal_ID(SincalModel.Info.Terminal.Element_ID == SincalModel.Info.Infeeder.Element_ID);
NodeID_2_delete = Node_ID_Infeeder;

SincalModel.Info.Infeeder.Node1_ID = NodeID_TR(NodeID_TR ~= Node_ID_Infeeder);
SincalModel.Info.Infeeder.Element_ID = SincalModel.Info.TwoWindingTransformer.Element_ID;  
SincalModel.Info = rmfield(SincalModel.Info,'TwoWindingTransformer');

SincalModel.Info.Node(SincalModel.Info.Node.Node_ID == Node_ID_Infeeder,:) = [];

NodeID_Infeeder = SincalModel.Info.Infeeder.Node1_ID;

NodeRes_all(NodeRes_all(:,1) == NodeID_Infeeder,[4:6,9:11,14:16]) = ...
    NodeRes_all(NodeRes_all(:,1) == NodeID_2_delete,[4:6,9:11,14:16]);
NodeRes_all(NodeRes_all(:,1) == NodeID_2_delete,:) = [];


TR_Terminals = unique(SincalModel.Info.Terminal.Terminal_ID(SincalModel.Info.Terminal.Node_ID == NodeID_2_delete));
BranchRes_TR = ...
    BranchRes_all(ismember(BranchRes_all.Terminal1_ID,TR_Terminals) | ismember(BranchRes_all.Terminal2_ID,TR_Terminals),:);
BranchRes_TR = BranchRes_TR{:,:};

temp1 = diff(abs(BranchRes_TR),1);
TR_losses = temp1(1:2:end,:);
NodeRes_all(NodeRes_all(:,1) == NodeID_Infeeder,[4:6,9:11,14:16]) = ...
    NodeRes_all(NodeRes_all(:,1) == NodeID_Infeeder,[4:6,9:11,14:16]) ...
    + TR_losses(:,[3:5,7:9,11:13]);
NodeRes_all_exakt(NodeRes_all_exakt.Node_ID == NodeID_2_delete,:) = [];
NodeRes_all_exakt{NodeRes_all_exakt.Node_ID == NodeID_Infeeder,:} = ...
    NodeRes_all(NodeRes_all(:,1) == NodeID_Infeeder,:);

TerminalID_TR(NodeID_TR == Node_ID_Infeeder);
SincalModel.Info.Terminal(ismember(SincalModel.Info.Terminal.Terminal_ID,[TerminalID_TR(NodeID_TR == Node_ID_Infeeder), TerminalID_Infeeder]),:) = [];


%% Load or calculate admittance matrix Y_012 and Y_L1L2L3

fprintf('Main-Function: 2c) calculate the Y_012 and Y_L1L2L3 admittance matrix\n'); 
% if  exist([cd,'\Static_Input\','Y_Info.mat'],'file')
%     load([cd,'\Static_Input\','Y_Info.mat'])
% else
    [Y_012, Y_012_NodeNames]    = ...                               % Get admittance matrix Y_012 (symmetrical components)
        Mat2Sin_GetY_012_withC(SincalModel.Name,SincalModel.Path);
    Y_L1L2L3                    = Y_012_to_Y_L1L2L3(Y_012);         % Transform admittance matrix from symmetrical componenetns to Y_L1L2L3
%     save([cd,'\Static_Input\','Y_Info.mat'],...                     % Save admittance matrix Y_L1L2L3
%         'Y_012','Y_012_NodeNames','Y_L1L2L3');
% end

%% Node seperation

All______Node_ID  = unique(SincalModel.Info.Node.      Node_ID );
Infeeder_Node_ID  = unique(SincalModel.Info.Infeeder.  Node1_ID);
PV_______Node_ID  = unique(SincalModel.Info.DCInfeeder.Node1_ID);
Load_____Node_ID  = unique(SincalModel.Info.Load.      Node1_ID);

Infeeder_Node_pos = ismember(SincalModel.Info.Node.Node_ID,Infeeder_Node_ID);
PV_______Node_pos = ismember(SincalModel.Info.Node.Node_ID,PV_______Node_ID);
Load_____Node_pos = ismember(SincalModel.Info.Node.Node_ID,Load_____Node_ID);
All______Node_pos = ismember(SincalModel.Info.Node.Node_ID,All______Node_ID);

%% Measured Node Positions

Measured_Node_U1___pos =   Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos;
Measured_Node_U2___pos =   Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos;
Measured_Node_U3___pos =   Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos;

Measured_Node_phi1_pos = ~ All______Node_pos;
Measured_Node_phi2_pos = ~ All______Node_pos;
Measured_Node_phi3_pos = ~ All______Node_pos;

if ~pseudo
    Measured_Node_P1___pos =   Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos;
    Measured_Node_P2___pos =   Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos;
    Measured_Node_P3___pos =   Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos;

    Measured_Node_Q1___pos =   Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos;
    Measured_Node_Q2___pos =   Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos;
    Measured_Node_Q3___pos =   Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos;
else
    % With pseudo values (synthtic load profiles)
    Measured_Node_P1___pos =   Infeeder_Node_pos;
    Measured_Node_P2___pos =   Infeeder_Node_pos;
    Measured_Node_P3___pos =   Infeeder_Node_pos;

    Measured_Node_Q1___pos =   Infeeder_Node_pos;
    Measured_Node_Q2___pos =   Infeeder_Node_pos;
    Measured_Node_Q3___pos =   Infeeder_Node_pos;
end

%% Virtual Node Positions

Virtual__Node_U1___pos = ~ All______Node_pos;
Virtual__Node_U2___pos = ~ All______Node_pos;
Virtual__Node_U3___pos = ~ All______Node_pos;

Virtual__Node_phi1_pos =   Infeeder_Node_pos;
Virtual__Node_phi2_pos =   Infeeder_Node_pos;
Virtual__Node_phi3_pos =   Infeeder_Node_pos;

if ~pseudo
    Virtual__Node_P1___pos = ~ Measured_Node_P1___pos;
    Virtual__Node_P2___pos = ~ Measured_Node_P2___pos;
    Virtual__Node_P3___pos = ~ Measured_Node_P3___pos;

    Virtual__Node_Q1___pos = ~ Measured_Node_Q1___pos;
    Virtual__Node_Q2___pos = ~ Measured_Node_Q2___pos;
    Virtual__Node_Q3___pos = ~ Measured_Node_Q3___pos;
else
    % With pseudo values (synthtic load profiles)
    Virtual__Node_P1___pos = ~ (Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos); 
    Virtual__Node_P2___pos = ~ (Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos); 
    Virtual__Node_P3___pos = ~ (Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos); 

    Virtual__Node_Q1___pos = ~ (Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos);
    Virtual__Node_Q2___pos = ~ (Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos); 
    Virtual__Node_Q3___pos = ~ (Infeeder_Node_pos | PV_______Node_pos | Load_____Node_pos);
end

%% Pseudo Node Positions

Pseudo___Node_U1___pos = ~ All______Node_pos;
Pseudo___Node_U2___pos = ~ All______Node_pos;
Pseudo___Node_U3___pos = ~ All______Node_pos;

Pseudo___Node_phi1_pos = ~ All______Node_pos;
Pseudo___Node_phi2_pos = ~ All______Node_pos;
Pseudo___Node_phi3_pos = ~ All______Node_pos;

if ~pseudo
    Pseudo___Node_P1___pos = ~ All______Node_pos;
    Pseudo___Node_P2___pos = ~ All______Node_pos;
    Pseudo___Node_P3___pos = ~ All______Node_pos;

    Pseudo___Node_Q1___pos = ~ All______Node_pos;
    Pseudo___Node_Q2___pos = ~ All______Node_pos;
    Pseudo___Node_Q3___pos = ~ All______Node_pos;
else
    % With pseudo values (synthtic load profiles)
    Pseudo___Node_P1___pos = PV_______Node_pos | Load_____Node_pos;
    Pseudo___Node_P2___pos = PV_______Node_pos | Load_____Node_pos;
    Pseudo___Node_P3___pos = PV_______Node_pos | Load_____Node_pos;

    Pseudo___Node_Q1___pos = PV_______Node_pos | Load_____Node_pos;
    Pseudo___Node_Q2___pos = PV_______Node_pos | Load_____Node_pos;
    Pseudo___Node_Q3___pos = PV_______Node_pos | Load_____Node_pos;
end

%% TODO: Adjust comments

num_Nodes     = numel(All______Node_pos);	% Get number of grid nodes and number of time step
num_PNM_Types = 4;                          % PNM - Posible noad measurements; 4 Types: U, phi, P, Q
num_PMN___max = 3 *num_Nodes;               % Max. posible measurements at nodes (PMN)

%% Real Measurements in measurement vector z

% Initial
z_meas____pos___U = false(num_PNM_Types * num_PMN___max, 1);
z_meas____pos_phi = false(num_PNM_Types * num_PMN___max, 1);
z_meas____pos___P = false(num_PNM_Types * num_PMN___max, 1);
z_meas____pos___Q = false(num_PNM_Types * num_PMN___max, 1);

z_meas____pos___U(                    1 :     num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Measured_Node_U1___pos';...
    Measured_Node_U2___pos';...
    Measured_Node_U3___pos'],[],1);

z_meas____pos_phi(    num_PMN___max + 1 : 2 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Measured_Node_phi1_pos';...
    Measured_Node_phi2_pos';...
    Measured_Node_phi3_pos'],[],1);

z_meas____pos___P(2 * num_PMN___max + 1 : 3 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Measured_Node_P1___pos';...
    Measured_Node_P2___pos';...
    Measured_Node_P3___pos'],[],1);

z_meas____pos___Q(3 * num_PMN___max + 1 : 4 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Measured_Node_Q1___pos';...
    Measured_Node_Q2___pos';...
    Measured_Node_Q3___pos'],[],1);

z_meas____pos_all = ...
    z_meas____pos___U | ...
    z_meas____pos_phi | ...
    z_meas____pos___P | ...
    z_meas____pos___Q   ...
    ;

z_meas____num___U = sum(z_meas____pos___U);
z_meas____num_phi = sum(z_meas____pos_phi);
z_meas____num___P = sum(z_meas____pos___P);
z_meas____num___Q = sum(z_meas____pos___Q);
z_meas____num_all = sum(z_meas____pos_all);  	% Get number of real measurements in z

%% Virtual Measurements in measurement vector z

% Initial
z_virtual_pos___U = false(num_PNM_Types * num_PMN___max, 1);
z_virtual_pos_phi = false(num_PNM_Types * num_PMN___max, 1);
z_virtual_pos___P = false(num_PNM_Types * num_PMN___max, 1);
z_virtual_pos___Q = false(num_PNM_Types * num_PMN___max, 1);

z_virtual_pos___U(                    1 :     num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Virtual__Node_U1___pos';...
    Virtual__Node_U2___pos';...
    Virtual__Node_U3___pos'],[],1);

z_virtual_pos_phi(    num_PMN___max + 1 : 2 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Virtual__Node_phi1_pos';...
    Virtual__Node_phi2_pos';...
    Virtual__Node_phi3_pos'],[],1);

z_virtual_pos___P(2 * num_PMN___max + 1 : 3 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Virtual__Node_P1___pos';...
    Virtual__Node_P2___pos';...
    Virtual__Node_P3___pos'],[],1);

z_virtual_pos___Q(3 * num_PMN___max + 1 : 4 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Virtual__Node_Q1___pos';...
    Virtual__Node_Q2___pos';...
    Virtual__Node_Q3___pos'],[],1);

z_virtual_pos_all = ...
    z_virtual_pos___U | ...
    z_virtual_pos_phi | ...
    z_virtual_pos___P | ...
    z_virtual_pos___Q   ...
    ;

z_virtual_num___U = sum(z_virtual_pos___U);
z_virtual_num_phi = sum(z_virtual_pos_phi);
z_virtual_num___P = sum(z_virtual_pos___P);
z_virtual_num___Q = sum(z_virtual_pos___Q);
z_virtual_num_all = sum(z_virtual_pos_all);   	% Get number of virtual measurements in z

%% Pseudo Measurements in measurement vector z

% Initial
z_pseudo__pos___U = false(num_PNM_Types * num_PMN___max, 1);
z_pseudo__pos_phi = false(num_PNM_Types * num_PMN___max, 1);
z_pseudo__pos___P = false(num_PNM_Types * num_PMN___max, 1);
z_pseudo__pos___Q = false(num_PNM_Types * num_PMN___max, 1);

z_pseudo__pos___U(                    1 :     num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Pseudo___Node_U1___pos';...
    Pseudo___Node_U2___pos';...
    Pseudo___Node_U3___pos'],[],1);

z_pseudo__pos_phi(    num_PMN___max + 1 : 2 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Pseudo___Node_phi1_pos';...
    Pseudo___Node_phi2_pos';...
    Pseudo___Node_phi3_pos'],[],1);

z_pseudo__pos___P(2 * num_PMN___max + 1 : 3 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Pseudo___Node_P1___pos';...
    Pseudo___Node_P2___pos';...
    Pseudo___Node_P3___pos'],[],1);

z_pseudo__pos___Q(3 * num_PMN___max + 1 : 4 * num_PMN___max) = reshape([...	% Expand logic vector so it fits a node vector with L1, L2, L3
    Pseudo___Node_Q1___pos';...
    Pseudo___Node_Q2___pos';...
    Pseudo___Node_Q3___pos'],[],1);

z_pseudo__pos_all = ...
    z_pseudo__pos___U | ...
    z_pseudo__pos_phi | ...
    z_pseudo__pos___P | ...
    z_pseudo__pos___Q   ...
    ;

z_pseudo__num___U = sum(z_pseudo__pos___U);
z_pseudo__num_phi = sum(z_pseudo__pos_phi);
z_pseudo__num___P = sum(z_pseudo__pos___P);
z_pseudo__num___Q = sum(z_pseudo__pos___Q);
z_pseudo__num_all = sum(z_pseudo__pos_all);   	% Get number of pseudo measurements in z

%% Define static variables (TODO, adjust Comments)

fprintf('Main-Function: 3) Static Variables\n');	% Command window output

[H, ~] = get_H(Y_L1L2L3, Y_012_NodeNames, U_eva);	% Creation of measurement model matrix H_ideal and auxiliary matrix H_index

H_AM   = H(z_meas____pos_all | z_pseudo__pos_all,:);
C_AM   = H(z_virtual_pos_all                    ,:);

% Build diagonal matrix R with all measurement variances sigma^2
R = diag([...
    sigma___U_Meas^2 * ones(z_meas____num___U,1); ...
    sigma_phi_Meas^2 * ones(z_meas____num_phi,1); ...
    sigma___P_Meas^2 * ones(z_meas____num___P,1); ...
    sigma___Q_Meas^2 * ones(z_meas____num___Q,1); ...
    sigma___U_Pseu^2 * ones(z_pseudo__num___U,1); ...
    sigma_phi_Pseu^2 * ones(z_pseudo__num_phi,1); ...
    sigma___P_Pseu^2 * ones(z_pseudo__num___P,1); ...
    sigma___Q_Pseu^2 * ones(z_pseudo__num___Q,1)  ...
    ]);

% Build Hachtel matrix of the augmented matrix approach
alpha       = min(diag(R));
Hachtel     = [ ...
    1/alpha.*R                       , H_AM                             , zeros(size(H_AM,1),size(C_AM,1));...
    H_AM'                            , zeros(size(H_AM,2),size(H_AM,2)) , C_AM'                           ;...
    zeros(size(C_AM,1),size(H_AM,1)) , C_AM                             , zeros(size(C_AM,1),size(C_AM,1)) ...
    ];

% Calculate diagonal matrix R_r_estimate for standard deviations of estimated residuals
Hachtel_invers  = Hachtel \ eye(size(Hachtel,1));
% Sensitivity     = 1/alpha.* R * Hachtel_invers(1:size(R,1),1:size(R,2));    % TODO, Bad Data is not working
% R_residual      = Sensitivity * R;

% clear Hachtel % Delete big Variable

%% Find the connections between network nodes respectively find the position of branches (TODO: For currents)

% % fprintf('Main-Function: 4) Connected Nodes\n');         % Command window output
% % % Set size of reshape matrix and fill reshape matrix with information of the admittance matrix
% % % Y_L1L2L3 --> (774:774)  ------> reshape matrix Y_L1L2L3_reshape --> (774*258:3)
% % Y_L1L2L3_reshape = zeros(num_Nodes^2*3, 3);
% % for k_column_triple = 1:num_Nodes
% %     Y_L1L2L3_reshape((k_column_triple-1)*3*num_Nodes+1:k_column_triple*3*num_Nodes,1:3) = Y_L1L2L3(:,(k_column_triple-1)*3+1:k_column_triple*3);
% % end

%% Assuming that NodeRes_all for each timestamp is sorted according to Node_ID

fprintf('Main-Function: 4) Sorting Nodes\n');           % Command window output
% Sort NodeRes in the same order as Y_012_NodeNames
Node_ID_sorted2Y = ...
    cellfun(@(x) find(ismember(Y_012_NodeNames(1:3:end),x)),SincalModel.Info.Node.Name);
% NOTE: NodeRes_all is not used for this purpose, because it only contains
% the Node_ID but the node names must be available --> so the sincal model
% info is used

%% Initialize all variables for estimated values (network state and power bilances of each node)
%%% TODO (all Comments adjust)
fprintf('Main-Function: 5) Initializing State Estimation\n');	% Command window output

Num_TimeStep        = end___TimeStep - start_TimeStep + 1;    	% Calculate number of time steps

x__precise          = zeros(2 * num_PMN___max,	Num_TimeStep);  % Initialize vector of the precise (x_precise) of the augmented matrix approach (U,phi)
x_estimate          = zeros(2 * num_PMN___max,	Num_TimeStep); 	% Initialize vector of the estimated network state (x_estimate_with_slack)         (U,phi)

z_precise______all  = zeros(4 * num_PMN___max,	Num_TimeStep);	% Initialize vector of the precise (z__precise_AM) of the augmented matrix approach (U, phi, P, Q)

z_precise_____meas  = zeros(z_meas____num_all,	Num_TimeStep);
z_precise___pseudo  = zeros(z_pseudo__num_all,	Num_TimeStep);
z_precise__virtual  = zeros(z_virtual_num_all,	Num_TimeStep);

z_input_______meas  = zeros(z_meas____num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)
z_input_____pseudo  = zeros(z_pseudo__num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)
z_input____virtual  = zeros(z_virtual_num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)

z_estimate          = zeros(num_PNM_Types * num_PMN___max, Num_TimeStep);
z_estimate____meas  = zeros(z_meas____num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)
z_estimate__pseudo  = zeros(z_pseudo__num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)
z_estimate_virtual  = zeros(z_virtual_num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)

r____meas           = zeros(z_meas____num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)
r__pseudo           = zeros(z_pseudo__num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)
r_virtual           = zeros(z_virtual_num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)

pFeh____meas        = zeros(z_meas____num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)
pFeh__pseudo        = zeros(z_pseudo__num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)
pFeh_virtual        = zeros(z_virtual_num_all,	Num_TimeStep);  % Initialize vector of the real (z_meas_AM)

r_normalized        = zeros(z_meas____num_all,     Num_TimeStep);  % Initialize vector the normalized residuals

% BadData_Detection   = zeros(3,                  Num_TimeStep);  % Initialize matrix for BadData detection

%% Estimation of the network state of the chosen time steps

fprintf('Main-Function: 6) State Estimation Loop\n');   % Command window output
% fprintf('Calculation step: '                        );
% SE_waitbar = waitbar(0,'AMA State Estimation in Progress','Name','AMA State Estimation','CreateCancelBtn',...
%                 'setappdata(gcbf,''canceling'',1)');
%     setappdata(SE_waitbar,'canceling',0);
k = 1;
% Loop for number of chosen time steps
for TimeStep = start_TimeStep:end___TimeStep
    % Progress information (TODO, besser machen)
%     if updateWaitbar('update',SE_waitbar,TimeStep/end___TimeStep,'AMA State Estimation in Progress')
%             return
%     end
    
%     if TimeStep == 1 || mod(TimeStep,1000) == 0 || mod(TimeStep,52560) == 0
%         fprintf('%d \n',TimeStep);
%     end
    NodeRes_t           = NodeRes_all((TimeStep-1)*num_Nodes+1:TimeStep*num_Nodes,:);   % Get the node results of the current time step
    NodeRes_t           = NodeRes_t(Node_ID_sorted2Y,:);                                % Sort the NodeRes in the same order as the admittance matrix Y_012, only if sorted after Node_ID
    
    % Save all calculated qunatity vectors in NodeRes_Column_t
    NodeRes_Column_t = zeros(num_PMN___max,4);
    
    % U   all three phase
    NodeRes_Column_t(:,1)	= reshape([...
        NodeRes_t(:,2)';...
        NodeRes_t(:,7)';...
        NodeRes_t(:,12)'],[],1)*10^3;
    
    % phi all three phase
    NodeRes_Column_t(:,2)	= deg2rad(reshape([...
        NodeRes_t(:,3),...
        NodeRes_t(:,8),...
        NodeRes_t(:,13)].',[],1));
    
    % P   all three phase
    NodeRes_Column_t(:,3)   = reshape([...
        NodeRes_t(:,4),...
        NodeRes_t(:,9),...
        NodeRes_t(:,14)].',[],1)*10^6;
    
    % Q   all three phase
    NodeRes_Column_t(:,4)   = reshape([...
        NodeRes_t(:,5),...
        NodeRes_t(:,10),...
        NodeRes_t(:,15)].',[],1)*10^6;
    
    % Seperate the complexe precise network state and precise measurement values
    % x_precise (U, phi)
    x__precise(:,k)         = [...
        NodeRes_Column_t(:,1);...
        NodeRes_Column_t(:,2)];
    
    % z__precise (U, phi, P, Q)
    z_precise______all(:,k) = [...
        NodeRes_Column_t(:,1);...
        NodeRes_Column_t(:,2);...
        NodeRes_Column_t(:,3);...
        NodeRes_Column_t(:,4)];
    % Mistakes: Because NodeRes has changed!!! But for voltage it is ok.
    z_precise_____meas(:,k)  = z_precise______all(z_meas____pos_all,k);
    z_precise___pseudo(:,k)  = z_precise______all(z_pseudo__pos_all,k);
    z_precise__virtual(:,k)  = z_precise______all(z_virtual_pos_all,k);
    
    rng(TimeStep);                      % Control the creation of random numbers
    
    % Calculate real mesaurement values by adding some random errors to the precise measurement values
    Noise                   = [...
        normrnd(0,sigma___U_Meas,  [num_PMN___max,1]);...   % U
        zeros([3*num_Nodes,1]);...                          % phi (no noise)
        normrnd(0,sigma___P_Meas,  [num_PMN___max,1]);...   % P
        normrnd(0,sigma___Q_Meas,  [num_PMN___max,1]);...   % Q
        ];
    Noise_meas                = Noise    (z_meas____pos_all,1);
    
    z_input_______meas(:,k)    = z_precise_____meas(:,k) + Noise_meas;
    z_input_____pseudo(:,k)    = z_precise___pseudo(:,k);  % Pseudo generation (if pseudo values ocure)
    z_input____virtual(:,k)    = z_precise__virtual(:,k);
    
    rhs_AM                  = [...      % Create right hand side of the LSE for the augmented matrix approach
        z_input_______meas(:,k);...
        z_input_____pseudo(:,k);...
        zeros(size(C_AM,2),1)  ;...
        z_input____virtual(:,k);...
        ];
    
    % STATE ESTIMATION: CALCULATE THE ESTIMATED NETWORK STATE VIA AUGMENTED MATRIX APPROACH
    solution_vector         = Hachtel_invers * rhs_AM;
    
    % Get estimated network state variable from the solution vector of the augmented matrix approach
    x_estimate(:,k)         = solution_vector(      ...
        z_meas____num_all + z_pseudo__num_all + 1 : ...
        end               - z_virtual_num_all          );
    
    z_estimate_____all(:,k) = H_AM * x_estimate(:,k);	% Calculate estimated measurement values with the help of the estimated network state
    z_estimate(:,k)         = H *    x_estimate(:,k);
    
    z_estimate_virtual(:,k) = C_AM * x_estimate(:,k);
    z_estimate____meas(:,k) = z_estimate_____all(                    1 : z_meas____num_all ,k                   );
    z_estimate__pseudo(:,k) = z_estimate_____all(z_meas____num_all + 1 : z_meas____num_all + z_pseudo__num_all,k);
    
    r____meas   (:,k) = z_input_______meas(:,k) - z_estimate____meas(:,k);   	% Calculate residual of the estimated mesaurement values
    r__pseudo   (:,k) = z_input_____pseudo(:,k) - z_estimate__pseudo(:,k);   	% Calculate residual of the estimated mesaurement values
    r_virtual   (:,k) = z_input____virtual(:,k) - z_estimate_virtual(:,k);   	% Calculate residual of the estimated mesaurement values
    
    pFeh____meas(:,k) = z_precise_____meas(:,k) - z_estimate____meas(:,k);
    pFeh__pseudo(:,k) = z_precise___pseudo(:,k) - z_estimate__pseudo(:,k);
    pFeh_virtual(:,k) = z_input____virtual(:,k) - z_estimate_virtual(:,k);
    
%     r_normalized(:,k) = abs(r____meas(:,k))./sqrt(abs(diag(R_residual)));	% Calculate normalized residuals
    
    k = k + 1;
end

%% Memory sequence

fprintf('Main-Function: 7) Saving results\n');   % Command window output
% Memory_Path = [cd,'\Auswertungen\temp\'];
% if ~ isdir(Memory_Path)
%     mkdir(Memory_Path)
% end

% if updateWaitbar('update',SE_waitbar,1,'Saving results')
%             return
% end

clear NodeRes_all;
NodeRes_all = z_results2NodeRes_all(z_estimate,SincalModel.Info,end___TimeStep,num_PNM_Types,num_PMN___max,num_Nodes);
BranchRes_all = NodeRes2BranchRes(NodeRes_all,SincalModel.Info,Y_L1L2L3);
BranchRes_all_exakt = NodeRes2BranchRes(NodeRes_all_exakt,SincalModel.Info,Y_L1L2L3);
% save([Memory_Path, 'NodeRes_raw'],	'NodeRes_all','-v7.3');
% save([Memory_Path, 'BranchRes_raw'],	'BranchRes_all','-v7.3');
% 
% save([Memory_Path, 'x__precise'        ],	'x__precise'        );
% save([Memory_Path, 'x_estimate'        ],	'x_estimate'        );
% 
% save([Memory_Path, 'z_precise______all'],	'z_precise______all');
% save([Memory_Path, 'z_precise_____meas'],	'z_precise_____meas');
% save([Memory_Path, 'z_precise___pseudo'],	'z_precise___pseudo');
% save([Memory_Path, 'z_precise__virtual'],	'z_precise__virtual');
% 
% save([Memory_Path, 'z_input_______meas'],	'z_input_______meas');
% save([Memory_Path, 'z_input_____pseudo'],	'z_input_____pseudo');
% save([Memory_Path, 'z_input____virtual'],	'z_input____virtual');
% 
% save([Memory_Path, 'z_estimate_____all'],	'z_estimate_____all');
% save([Memory_Path, 'z_estimate____meas'],	'z_estimate____meas');
% save([Memory_Path, 'z_estimate__pseudo'],	'z_estimate__pseudo');
% save([Memory_Path, 'z_estimate_virtual'],	'z_estimate_virtual');
% 
% save([Memory_Path, 'r____meas'         ],	'r____meas'         );
% save([Memory_Path, 'r__pseudo'         ],	'r__pseudo'         );
% save([Memory_Path, 'r_virtual'         ],	'r_virtual'         );
% 
% save([Memory_Path, 'pFeh____meas'      ],   'pFeh____meas'    	);
% save([Memory_Path, 'pFeh__pseudo'      ],	'pFeh__pseudo'  	);
% save([Memory_Path, 'pFeh_virtual'      ],	'pFeh_virtual'     	);
% 
% save([Memory_Path, 'r_normalized'],            'r_normalized');

% updateWaitbar('delete',SE_waitbar);

%% Toc
% fprintf('Time required: %d seconds\n\n', toc);
% toc % not for function

%% RB:

% % Compare for voltage:
% max_min_error = min(min(x__precise(1:702,:) - x_estimate(1:702,:)));
% max_max_error = max(max(x__precise(1:702,:) - x_estimate(1:702,:)));
% histogram(x__precise(1:702,:) - x_estimate(1:702,:));


end



