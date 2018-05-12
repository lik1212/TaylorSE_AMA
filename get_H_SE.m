function [H, H_index] = get_H_SE(Y_L1L2L3, Y_012_Node_ID, x_hat)
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

H_index = table;
H_index.Node1_ID = ...
    repmat(Y_012_Node_ID,4,1);              % H_index includes all connection between node id and node names

H_index.Phase     = repmat([1; 2; 3], 4 * size_Y / 3, 1);
H_index.Meas_Type = repelem([1; 2; 3; 4], size_Y, 1);

%% Initialize meaurement model matrix H
H       = zeros(4*size_Y,2*size_Y);   % H includes all possible measurement modell equations

%%  Set measurement modell equations for voltage amounts U_L1L2L3
H(1:2*size_Y,1:2*size_Y) = eye(2*size_Y);

%%  Set measurement modell equations for active and reactive power
% for k_P = 1:size_Y
%     for k_Pos = 1:size_Y
%         delta_phi = x_hat(k_P + size_Y) - x_hat(k_Pos + size_Y);
%         H(2*size_Y+k_P,k_Pos) = H(2*size_Y+k_P,k_Pos) + x_hat(k_Pos) * ( cos(delta_phi)*G_ij(k_P,k_Pos) + sin(delta_phi)*B_ij(k_P,k_Pos)); % P_i/U_i
%         if Y_012_Node_ID(k_P) == Y_012_Node_ID(k_Pos)
%             H(2*size_Y+k_P,k_Pos) = H(2*size_Y+k_P,k_Pos) + x_hat(k_Pos) * ( cos(delta_phi)*G_ij(k_P,k_Pos) + sin(delta_phi)*B_ij(k_P,k_Pos)); % P_i/U_i
%         else
%             H(2*size_Y+k_P,k_Pos) = x_hat(k_P) * ( cos(delta_phi)*G_ij(k_P,k_Pos) + sin(delta_phi)*B_ij(k_P,k_Pos)); % P_j/U_j
%         end
% %             H(2*size_Y+k_P,size_Y+k_Pos)  = x_hat(k_P) * x_hat(k_Pos) * ( sin(delta_phi)*G_ij(k_P,k_Pos) - cos(delta_phi)*B_ij(k_P,k_Pos)); % P/phi
% %             H(3*size_Y+k_P,k_Pos)         = x_hat(k_Pos)              * ( sin(delta_phi)*G_ij(k_P,k_Pos) - cos(delta_phi)*B_ij(k_P,k_Pos)); % Q/U
% %             H(3*size_Y+k_P,size_Y+k_Pos)  = x_hat(k_P) * x_hat(k_Pos) * (-cos(delta_phi)*G_ij(k_P,k_Pos) - sin(delta_phi)*B_ij(k_P,k_Pos)); % Q/phi
%     end
% end

for k_i = 1 : size_Y
    for k_j = 1 : size_Y
        delta_phi = x_hat(k_i + size_Y) - x_hat(k_j + size_Y); % Ausdrucke kürzen die doppelt vorkommen.
        if k_i ~= k_j 
            H(2 * size_Y + k_i,          k_j) = x_hat(k_i) *              ( cos(delta_phi) * G_ij(k_i, k_j) + sin(delta_phi) * B_ij(k_i, k_j)); % P_i/  U_j
            H(2 * size_Y + k_i, size_Y + k_j) = x_hat(k_i) * x_hat(k_j) * ( sin(delta_phi) * G_ij(k_i, k_j) - cos(delta_phi) * B_ij(k_i, k_j)); % P_i/phi_j
            H(3 * size_Y + k_i,          k_j) = x_hat(k_i) *              ( sin(delta_phi) * G_ij(k_i, k_j) - cos(delta_phi) * B_ij(k_i, k_j)); % Q_i/  U_j
            H(3 * size_Y + k_i, size_Y + k_j) = x_hat(k_i) * x_hat(k_j) * (-cos(delta_phi) * G_ij(k_i, k_j) - sin(delta_phi) * B_ij(k_i, k_j)); % Q_i/phi_j
        else
            H(2 * size_Y + k_i,          k_i) = H(2 * size_Y + k_i,          k_i) +              x_hat(k_j) * ( cos(delta_phi) * G_ij(k_i,k_j) + sin(delta_phi) * B_ij(k_i,k_j)); % P_i/  U_i
            H(2 * size_Y + k_i, size_Y + k_i) = H(2 * size_Y + k_i, size_Y + k_i) - x_hat(k_i) * x_hat(k_j) * ( sin(delta_phi) * G_ij(k_i,k_j) + cos(delta_phi) * B_ij(k_i,k_j)); % P_i/phi_i
            H(3 * size_Y + k_i,          k_i) = H(3 * size_Y + k_i,          k_i) +              x_hat(k_j) * ( sin(delta_phi) * G_ij(k_i,k_j) - cos(delta_phi) * B_ij(k_i,k_j)); % Q_i/  U_i
            H(3 * size_Y + k_i, size_Y + k_i) = H(3 * size_Y + k_i, size_Y + k_i) - x_hat(k_i) * x_hat(k_j) * ( cos(delta_phi) * G_ij(k_i,k_j) + sin(delta_phi) * B_ij(k_i,k_j)); % Q_i/phi_i
        end
        H(2 * size_Y + k_i,          k_i) = H(2 * size_Y + k_i,          k_i) +              x_hat(k_j) * ( cos(delta_phi) * G_ij(k_i,k_j) + sin(delta_phi) * B_ij(k_i,k_j)); % P_i/  U_i    
        H(2 * size_Y + k_i, size_Y + k_i) = H(2 * size_Y + k_i, size_Y + k_i) + x_hat(k_i) * x_hat(k_j) * (-sin(delta_phi) * G_ij(k_i,k_j) + cos(delta_phi) * B_ij(k_i,k_j)); % P_i/phi_i
        H(3 * size_Y + k_i,          k_i) = H(3 * size_Y + k_i,          k_i) +              x_hat(k_j) * ( sin(delta_phi) * G_ij(k_i,k_j) - cos(delta_phi) * B_ij(k_i,k_j)); % Q_i/  U_i  
        H(3 * size_Y + k_i, size_Y + k_i) = H(3 * size_Y + k_i, size_Y + k_i) + x_hat(k_i) * x_hat(k_j) * ( cos(delta_phi) * G_ij(k_i,k_j) + sin(delta_phi) * B_ij(k_i,k_j)); % Q_i/phi_i
    end
end
