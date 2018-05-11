function [x_hat, z_hat, z_hat_all, Optional] = TaylorSE_AMA(z_all_data, z_all_flag, LineInfo, Inputs)
%NEW_ALGO(Z_ALL_DATA, Z_ALL_FLAG, Y_L1L2L3) Summary of this function goes here
%   Detailed explanation goes here
%
% Author(s):    R. Brandalik
%               D. Henschel
%               J. Tu
%               P. Gassler
%
% Contact: brandalikrobert@gmail.com, brandalik@eit.uni-kl.de
%
% Special thanks go to the entire TUK ESEM team.
%
% Parts of the work were the result of the project CheapFlex, sponsored by
% the German Federal Ministry of Economic Affairs and Energy as part of the
% 6th Energy Research Programme of the German Federal Government.

%% Inputs to Settings

Settings = defaultSettings(Inputs);
U_eva    = Settings.U_eva;

%% TODO

[Y_012, Y_012_Node_ID] = LineInfo2Y_012(LineInfo);
Y_L1L2L3               = Y_012_to_Y_L1L2L3(Y_012);
[H, H_index]           = get_H(Y_L1L2L3, Y_012_Node_ID, U_eva);


%% Configurations

% fprintf('AugmentedMatrix_Algorithm\n\n');   % Command window output

[~, z_order     ] = sort(z_all_flag.Accur_Type);
[~, z_order_back] = sort(z_order              );
z_all_flag_order   = z_all_flag(z_order,:);
z_all_data_order   = z_all_data(z_order,:);

HC_flag = NaN(size(z_all_flag_order,1), 1);

for k_z = 1 : size(HC_flag)
    HC_flag(k_z) = find(...
        H_index.Node1_ID  == z_all_flag_order.Node1_ID (k_z) & ...
        H_index.Phase     == z_all_flag_order.Phase    (k_z) & ...
        H_index.Meas_Type == z_all_flag_order.Meas_Type(k_z));
end

HC_switch = find(z_all_flag_order.Accur_Type == 3, 1);
H_flag = HC_flag(1         : HC_switch - 1, :);
C_flag = HC_flag(HC_switch :           end, :);

H_AM   = H(H_flag,:);
C_AM   = H(C_flag,:);

H_init = [H_AM; C_AM];
H_init = H_init(z_order_back,:);

R = diag(z_all_flag_order.Sigma(1 : HC_switch - 1).^2);

% Build Hachtel matrix of the augmented matrix approach
alpha       = min(diag(R));
Hachtel     = [ ...
    1/alpha.*R                       , H_AM                             , zeros(size(H_AM,1),size(C_AM,1));...
    H_AM'                            , zeros(size(H_AM,2),size(H_AM,2)) , C_AM'                           ;...
    zeros(size(C_AM,1),size(H_AM,1)) , C_AM                             , zeros(size(C_AM,1),size(C_AM,1)) ...
    ];
% Calculate diagonal matrix R_r_estimate for standard deviations of estimated residuals
Hachtel_invers  = Hachtel \ eye(size(Hachtel,1));
x_hat = NaN(size(H,2), size(z_all_data_order,2)); % Initial
z_hat_all = NaN(size(H,1), size(z_all_data_order,2)); % Initial
z_hat     = NaN(size(z_all_data, 1), size(z_all_data_order,2)); % Initial

for k = 1 : size(z_all_data_order,2)
    rhs_AM                  = [...      % Create right hand side of the LSE for the augmented matrix approach
        z_all_data_order(1 : HC_switch - 1, k);...
        zeros(size(C_AM,2),1)  ;...
        z_all_data_order(HC_switch :   end, k);...
        ];
    % STATE ESTIMATION: CALCULATE THE ESTIMATED NETWORK STATE VIA AUGMENTED MATRIX APPROACH
    solution_vector         = Hachtel_invers * rhs_AM;
    % Get estimated network state variable from the solution vector of the augmented matrix approach
    x_hat(:,k)         = solution_vector(      ...
        HC_switch : ...
        end               - numel(C_flag)     );
    z_hat_all(:,k)         = H *    x_hat(:,k);
    z_hat(:,k) = H_init * x_hat(:,k);	% Calculate estimated measurement values with the help of the estimated network state
end
Optional.Y_L1L2L3 = Y_L1L2L3;
