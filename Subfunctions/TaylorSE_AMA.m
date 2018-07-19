function [x_hat, z_hat, z_hat_full, Out_Optional] = TaylorSE_AMA(z_all_data, z_all_flag, LineInfo, Inputs_SE)
%TAYLORSE_AMA State Estimation with augmented matrix approach and
%linearized measurement equations (Taylor linearization)
%   Input
%       z_all_data - The measurement data
%       z_all_flag - Basic information about the measurements (what is
%                    measured, where is it measured ...). 
%                    See Description_Of_Inputs
%       LineInfo   - Basic information about the lines (branches) of the
%                    grid
%       Inputs_SE  - Optional. For now only the voltage magnitude of the
%                    evaluation point is given. Can be used in the future 
%                    for more static parameters.
%
%   Output
%       x_hat        - Estimated state vector
%       z_hat        - Estimated measurement vector
%       z_hat_full   - Estimation of all important measurements:
%                      (U, phi, P & Q)
%       Out_Optional - Optional output.
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

if nargin < 4; Inputs_SE = struct; end
Settings = defaultSettings(Inputs_SE);
U_eva    = Settings.U_eva;

%% Sort measurement values in this order: real, pseudo, virtual

[~, z_order]     = sort(z_all_flag.Accur_Type);
z_all_flag_order = z_all_flag(z_order,:);
z_all_data_order = z_all_data(z_order,:);

%% Prepare the Hachtel's matrix and all other needed matrixes

[Y_012, Y_012_Node_ID] = LineInfo2Y_012(LineInfo);              % Admittance matrix in symmetrical components
Y_L1L2L3               = Y_012_to_Y_L1L2L3(Y_012);              % Admittance matrix in phase sequences
[H, H_index]           = get_H(Y_L1L2L3, Y_012_Node_ID, U_eva); % All meas. functions for U, phi, P and Q -> Matrix H

HC_flag = NaN(size(z_all_flag_order, 1), 1);                     % Initial matrix of real-pseudo and virtual values
for k_z = 1 : numel(HC_flag) % Find flag for matrix rows of real-pseudo and virtual values in H
    HC_flag(k_z) = find(...
        H_index.Node1_ID  == z_all_flag_order.Node1_ID (k_z) & ...
        H_index.Phase     == z_all_flag_order.Phase    (k_z) & ...
        H_index.Meas_Type == z_all_flag_order.Meas_Type(k_z));
end

HC_switch = find(z_all_flag_order.Accur_Type == 3, 1); % HC_switch defines the position were HC_flag seperates virtual from real-pseudo values
H_flag = HC_flag(1         : HC_switch - 1, :);        % Position of real-pseudo values in H
C_flag = HC_flag(HC_switch :           end, :);        % Position of virtual     values in H

H_AM   = H(H_flag,:);                                        % Matrix of real-pseudo values, AM stands for augmented matrix
C_AM   = H(C_flag,:);                                        % Matrix of virtual     values
R      = diag(z_all_flag_order.Sigma(1 : HC_switch - 1).^2); % Covariance matrix 

% Build Hachtel's matrix of the augmented matrix approach
alpha  = min(diag(R));
Hachtel     = [ ...
    1/alpha.*R                       , H_AM                             , zeros(size(H_AM,1),size(C_AM,1));...
    H_AM'                            , zeros(size(H_AM,2),size(H_AM,2)) , C_AM'                           ;...
    zeros(size(C_AM,1),size(H_AM,1)) , C_AM                             , zeros(size(C_AM,1),size(C_AM,1)) ...
    ];
Hachtel_invers  = Hachtel \ eye(size(Hachtel,1)); % Save the inverse of the Hachtel's matrix

%% Matrix for geting back the same position of z_hat as in z_all_data 

[~, z_order_back] = sort(z_order); % Flag for sorting back
H_init = [H_AM; C_AM];
H_init = H_init(z_order_back,:);

%% Initial output (results)

x_hat      = NaN(size(H,2)     , size(z_all_data_order,2));
z_hat_full = NaN(size(H,1)     , size(z_all_data_order,2));
z_hat      = NaN(numel(HC_flag), size(z_all_data_order,2));

%% State Estimation over all time instances

for k = 1 : size(z_all_data_order,2) % over all time instances
    rhs_AM = [...                                    % Create right hand side of the LSE for the augmented matrix approach
        z_all_data_order(1 : HC_switch - 1, k); ...  % real-pseudo values
        zeros(size(C_AM,2),1)                 ; ...  % zero vector
        z_all_data_order(HC_switch :   end, k); ...  % virtual values
        ];
    solution_vector = Hachtel_invers * rhs_AM;                              % Calculate the estimated network state via augmented matrix approach
    x_hat     (:,k) = solution_vector(HC_switch : end - numel(C_flag));     % Get estimated network state variable from the solution vector
    z_hat     (:,k) = H_init * x_hat(:,k);                                  % Calculate estimated measurement values
    z_hat_full(:,k) = H      * x_hat(:,k);                                  % Calculate all posible measurements
end

%% Optional output

Out_Optional.Y_L1L2L3 = Y_L1L2L3; % Needed for comparison of results
