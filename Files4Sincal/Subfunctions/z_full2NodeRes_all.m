function NodeRes_all_estim = z_full2NodeRes_all(z_hat_full, SinInfo)
%Z_FULL2NODERES_ALL Modify the SE results in z_hat_full to match the
%NodeRes form (Sincal results)
%
%   Input:
%       z_hat_full - Result of State Estimation (U, phi, P and Q for all
%                    Nodes)
%       SinInfo    - Sincal Grid Information
%
%   Output:
%       NodeRes_all_estim - State Estimation results in the same form as
%                           the Sincal load flow results
%
% Author(s): P.Gassler, R. Brandalik

%% Initial prepeartion

num_meas     = size(z_hat_full, 1);
num_instants = size(z_hat_full, 2);
Node_IDs     = sort(SinInfo.Node.Node_ID);
num_Nodes    = numel(Node_IDs);

%% Preperation of measurement position

% Initial
U1_pos   = false(num_meas, 1);
U2_pos   = false(num_meas, 1);
U3_pos   = false(num_meas, 1);
phi1_pos = false(num_meas, 1);
phi2_pos = false(num_meas, 1);
phi3_pos = false(num_meas, 1);
P1_pos   = false(num_meas, 1);
P2_pos   = false(num_meas, 1);
P3_pos   = false(num_meas, 1);
Q1_pos   = false(num_meas, 1);
Q2_pos   = false(num_meas, 1);
Q3_pos   = false(num_meas, 1);

schema_L1 = repmat(logical([1; 0; 0]), num_Nodes, 1);
schema_L2 = repmat(logical([0; 1; 0]), num_Nodes, 1);
schema_L3 = repmat(logical([0; 0; 1]), num_Nodes, 1);

U1_pos  (                   1 : 3 *num_Nodes    ) = schema_L1;
U2_pos  (                   1 : 3 *num_Nodes    ) = schema_L2;
U3_pos  (                   1 : 3 *num_Nodes    ) = schema_L3;
phi1_pos(3 *num_Nodes +     1 : 3 *num_Nodes * 2) = schema_L1;
phi2_pos(3 *num_Nodes +     1 : 3 *num_Nodes * 2) = schema_L2;
phi3_pos(3 *num_Nodes +     1 : 3 *num_Nodes * 2) = schema_L3;
P1_pos  (3 *num_Nodes * 2 + 1 : 3 *num_Nodes * 3) = schema_L1;
P2_pos  (3 *num_Nodes * 2 + 1 : 3 *num_Nodes * 3) = schema_L2;
P3_pos  (3 *num_Nodes * 2 + 1 : 3 *num_Nodes * 3) = schema_L3;
Q1_pos  (3 *num_Nodes * 3 + 1 : 3 *num_Nodes * 4) = schema_L1;
Q2_pos  (3 *num_Nodes * 3 + 1 : 3 *num_Nodes * 4) = schema_L2;
Q3_pos  (3 *num_Nodes * 3 + 1 : 3 *num_Nodes * 4) = schema_L3;

%% Build NodeRes_all_estim

NodeRes_all_estim = zeros(num_Nodes * num_instants,19); % Initial

NodeRes_all_estim(:, 1) = repmat(Node_IDs, num_instants, 1);                              % Node_ID
NodeRes_all_estim(:, 2) =         reshape(z_hat_full(U1_pos  ,:),[], 1) * 10^-3;          % U1
NodeRes_all_estim(:, 7) =         reshape(z_hat_full(U2_pos  ,:),[], 1) * 10^-3;          % U2
NodeRes_all_estim(:,12) =         reshape(z_hat_full(U3_pos  ,:),[], 1) * 10^-3;          % U3
NodeRes_all_estim(:, 3) = rad2deg(reshape(z_hat_full(phi1_pos,:),[], 1));                 % phi1
NodeRes_all_estim(:, 8) = rad2deg(reshape(z_hat_full(phi2_pos,:),[], 1));                 % phi2
NodeRes_all_estim(:,13) = rad2deg(reshape(z_hat_full(phi3_pos,:),[], 1));                 % phi3
NodeRes_all_estim(:, 4) =         reshape(z_hat_full(P1_pos  ,:),[], 1) * 10^-6;          % P1
NodeRes_all_estim(:, 9) =         reshape(z_hat_full(P2_pos  ,:),[], 1) * 10^-6;          % P2
NodeRes_all_estim(:,14) =         reshape(z_hat_full(P3_pos  ,:),[], 1) * 10^-6;          % P3
NodeRes_all_estim(:, 5) =         reshape(z_hat_full(Q1_pos  ,:),[], 1) * 10^-6;          % Q1
NodeRes_all_estim(:,10) =         reshape(z_hat_full(Q2_pos  ,:),[], 1) * 10^-6;          % Q2
NodeRes_all_estim(:,15) =         reshape(z_hat_full(Q3_pos  ,:),[], 1) * 10^-6;          % Q3
NodeRes_all_estim(:, 6) = sqrt(NodeRes_all_estim(:, 5).^2 + NodeRes_all_estim(:, 4).^2 ); % S1
NodeRes_all_estim(:,11) = sqrt(NodeRes_all_estim(:,10).^2 + NodeRes_all_estim(:, 9).^2 ); % S2
NodeRes_all_estim(:,16) = sqrt(NodeRes_all_estim(:,15).^2 + NodeRes_all_estim(:,14).^2 ); % S3
NodeRes_all_estim(:,19) = repelem(1:num_instants, 1, num_Nodes);                          % ResTime

NodeRes_all_estim = array2table(NodeRes_all_estim, 'VariableNames', ... % To table
    {'Node_ID',...
    'U1','phi1','P1','Q1','S1',...
    'U2','phi2','P2','Q2','S2',...
    'U3','phi3','P3','Q3','S3',...
    'Ue','S','ResTime'});
