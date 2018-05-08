function [z_estimate, Optional] = new_algo(z_all_data, z_all_flag, LineInfo, U_eva)
%NEW_ALGO(Z_ALL_DATA, Z_ALL_FLAG, Y_L1L2L3) Summary of this function goes here
%   Detailed explanation goes here

[Y_012, Y_012_Node_ID] = LineInfo2Y_012(LineInfo);
Y_L1L2L3               = Y_012_to_Y_L1L2L3(Y_012);
[H, H_index] = get_H(Y_L1L2L3, Y_012_Node_ID, U_eva);	


%% Configurations

fprintf('AugmentedMatrix_Algorithm\n\n');   % Command window output
sigma___U_Meas  = 0.1;                % Set standard deviation of voltage (in V) and power measurements (in W respectively var), Meas - Measured
sigma_phi_Meas  = 0.01;
sigma___P_Meas  = 1;
sigma___Q_Meas  = 1;
sigma___U_Pseu  = NaN;                % Set standard deviation of voltage (in V) and power measurements (in W respectively var), Pseu - Pseudo
sigma_phi_Pseu  = NaN;
sigma___P_Pseu  = 50;                 % Watt
sigma___Q_Pseu  = 50;                 % Var
% start_TimeStep  = 1;
% end___TimeStep  = 1440;

fprintf('Main-Function: 3) Static Variables\n');	% Command window output

% TODO: Ubersetzung irgenwir

[~, z_order] = sort(z_all_flag.Accur_Type);
z_all_flag   = z_all_flag(z_order,:);
z_all_data   = z_all_data(z_order,:);

HC_flag = NaN(size(z_all_flag,1), 1);

for k_z = 1 : size(HC_flag)
    HC_flag(k_z) = find(...
        H_index.Node1_ID == z_all_flag.Node1_ID(k_z) & ...
        H_index.Phase == z_all_flag.Phase(k_z) & ...
        H_index.Meas_Type == z_all_flag.Meas_Type(k_z));
end

HC_switch = find(z_all_flag.Accur_Type == 3, 1);
H_flag = HC_flag(1         : HC_switch - 1, :);
C_flag = HC_flag(HC_switch :           end, :);

H_AM   = H(H_flag,:);
C_AM   = H(C_flag,:);

% % Build diagonal matrix R with all measurement variances sigma^2
% R = diag([...
%     sigma___U_Meas^2 * ones(z_meas____num___U,1); ...
%     sigma_phi_Meas^2 * ones(z_meas____num_phi,1); ...
%     sigma___P_Meas^2 * ones(z_meas____num___P,1); ...
%     sigma___Q_Meas^2 * ones(z_meas____num___Q,1); ...
%     sigma___U_Pseu^2 * ones(z_pseudo__num___U,1); ...
%     sigma_phi_Pseu^2 * ones(z_pseudo__num_phi,1); ...
%     sigma___P_Pseu^2 * ones(z_pseudo__num___P,1); ...
%     sigma___Q_Pseu^2 * ones(z_pseudo__num___Q,1)  ...
%     ]);

R = eye(HC_switch - 1); % Temp, so abouve

% Build Hachtel matrix of the augmented matrix approach
alpha       = min(diag(R));
Hachtel     = [ ...
    1/alpha.*R                       , H_AM                             , zeros(size(H_AM,1),size(C_AM,1));...
    H_AM'                            , zeros(size(H_AM,2),size(H_AM,2)) , C_AM'                           ;...
    zeros(size(C_AM,1),size(H_AM,1)) , C_AM                             , zeros(size(C_AM,1),size(C_AM,1)) ...
    ];

% Calculate diagonal matrix R_r_estimate for standard deviations of estimated residuals
Hachtel_invers  = Hachtel \ eye(size(Hachtel,1));

k = 1;
for k = 1 : size(z_all_data,2)
    rhs_AM                  = [...      % Create right hand side of the LSE for the augmented matrix approach
        z_all_data(1 : HC_switch - 1, k);...
        zeros(size(C_AM,2),1)  ;...
        z_all_data(HC_switch :   end, k);...
        ];
    
    % STATE ESTIMATION: CALCULATE THE ESTIMATED NETWORK STATE VIA AUGMENTED MATRIX APPROACH
    solution_vector         = Hachtel_invers * rhs_AM;
    
    % Get estimated network state variable from the solution vector of the augmented matrix approach
    x_estimate(:,k)         = solution_vector(      ...
        HC_switch : ...
        end               - numel(C_flag)     );
    
    z_estimate_____all(:,k) = H_AM * x_estimate(:,k);	% Calculate estimated measurement values with the help of the estimated network state
    z_estimate(:,k)         = H *    x_estimate(:,k);
    
    
end

Optional.Y_L1L2L3 = Y_L1L2L3;
