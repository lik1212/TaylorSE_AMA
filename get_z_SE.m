function [z_SE, z_index] = get_z_SE(Y_L1L2L3, Y_012_Node_ID, x_hat)
%%  Function manual:
%   This function creates the measurement modell matrix H for the
%   evaluation point {U_eva,delta_eva} of the Taylor Series of the
%   measurement modell equations for active power P and reactive power Q

%% TODO: Adjust comments

size_Y	= size(Y_L1L2L3,1);	% Get number of grid nodes
G_ij    = real(Y_L1L2L3);	% Get real part (condcutance) of admmittance matrix
B_ij    = imag(Y_L1L2L3);	% Get imaginary part (susceptance) of admmittance matrix

% Set voltage angle difference of evaluation (eva) point of linearization
% Note: This angle is an agle difference because the measurement modell
%       equations of active and reactive power include the
%       cos(delta_i_v - delta_j_w) and sin(delta_i_v - delta_j_w)
%       where i,j are grid node names and v,w are conductor names

z_index = table;
z_index.Node1_ID = ...
    repmat(Y_012_Node_ID,4,1);              % H_index includes all connection between node id and node names

z_index.Phase     = repmat([1; 2; 3], 4 * size_Y / 3, 1);
z_index.Meas_Type = repelem([1; 2; 3; 4], size_Y, 1);

%% Initialize meaurement model matrix H
z_SE       = zeros(4*size_Y,1);   % H includes all possible measurement modell equations

%%  Set measurement modell equations for voltage amounts U_L1L2L3
z_SE(1:2*size_Y,1) = x_hat(1:2*size_Y,1);

%%  Set measurement modell equations for active and reactive power
for k_i = 1:size_Y  
    for k_j = 1:size_Y
        delta_phi = x_hat(k_i + size_Y) - x_hat(k_j + size_Y);
        z_SE(2*size_Y+k_i,1) = z_SE(2*size_Y+k_i,1) + x_hat(k_i) * x_hat(k_j) * ( cos(delta_phi)*G_ij(k_i,k_j) + sin(delta_phi)*B_ij(k_i,k_j));
        z_SE(3*size_Y+k_i,1) = z_SE(3*size_Y+k_i,1) + x_hat(k_i) * x_hat(k_j) * ( sin(delta_phi)*G_ij(k_i,k_j) - cos(delta_phi)*B_ij(k_i,k_j));
    end
end

