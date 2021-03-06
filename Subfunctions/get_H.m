function [H, H_index] = get_H(Y_L1L2L3, Y_012_Node_ID, U_eva)
%GET_H Prepare the measurement matrix H of all Node measurements for U,
%   phi, P and Q
%   
%   This function creates the measurement modell matrix H for the
%   evaluation point {U_eva,delta_eva} of the Taylor Series of the
%   measurement modell equations for active power P and reactive power Q

%% Preperation

size_Y	= size(Y_L1L2L3,1);	% Get number of grid nodes
G_ij    = real(Y_L1L2L3);	% Get real part (condcutance) of admmittance matrix
B_ij    = imag(Y_L1L2L3);	% Get imaginary part (susceptance) of admmittance matrix

% Set voltage angle difference of evaluation (eva) point of linearization
% Note: This angle is an agle difference because the measurement modell
%       equations of active and reactive power include the
%       cos(delta_i_v - delta_j_w) and sin(delta_i_v - delta_j_w)
%       where i,j are grid node names and v,w are conductor names

delta1_eva  =    0     ;
delta2_eva  = -2/3 * pi;
delta3_eva  =  2/3 * pi;

H_index = table;
H_index.Node1_ID  = repmat(Y_012_Node_ID,4,1);
H_index.Phase     = repmat([1; 2; 3], 4 * size_Y / 3, 1);
H_index.Meas_Type = repelem([1; 2; 3; 4], size_Y, 1);

%% Initialize meaurement model matrix H
H = zeros(4*size_Y,2*size_Y);   % H includes all possible measurement model equations

%% Set measurement modell equations for voltage magnitues and angles U_L1L2L3
H(1:2*size_Y,1:2*size_Y) = eye(2*size_Y);

%%  Set measurement modell equations for active and reactive power
for k_i = 1:size_Y
    for k_j = 1:size_Y
        case_phase = mod(k_i - k_j, 3);
        switch case_phase
            case 0 % case L1-L1 L2-L2 L3-L3
                delta_eva = delta1_eva;
            case 1 % case L2-L1 L3-L2 L1-L3
                delta_eva = delta2_eva;
            case 2 % case L1-L2 L2-L3 L3-L1
                delta_eva = delta3_eva;
        end
        H(2 * size_Y + k_i, k_j         ) = U_eva   * ( cos(delta_eva) * G_ij(k_i,k_j) + sin(delta_eva) * B_ij(k_i,k_j)); % P/U
        H(2 * size_Y + k_i, size_Y + k_j) = U_eva^2 * ( sin(delta_eva) * G_ij(k_i,k_j) - cos(delta_eva) * B_ij(k_i,k_j)); % P/phi
        H(3 * size_Y + k_i, k_j         ) = U_eva   * ( sin(delta_eva) * G_ij(k_i,k_j) - cos(delta_eva) * B_ij(k_i,k_j)); % Q/U
        H(3 * size_Y + k_i, size_Y + k_j) = U_eva^2 * (-cos(delta_eva) * G_ij(k_i,k_j) - sin(delta_eva) * B_ij(k_i,k_j)); % Q/phi
    end
end

%%  Set measurement modell equations for active and reactive power (to compare)

% for k_i = 1:size_Y
%     for k_j = 1:size_Y
%         case_phase = mod(k_i,3) - mod(k_j,3);
%         switch case_phase
%             case 0      % case L1-L1 L2-L2 L3-L3
%                 delta_eva = delta1_eva;
%             case {-1,2} % case L1-L2 L2-L3 L3-L1
%                 delta_eva = delta2_eva;
%             case {-2,1} % case L2-L1 L3-L2 L1-L3
%                 delta_eva = delta3_eva;
%         end
%         if k_i ~= k_j
%             H(2 * size_Y + k_i,          k_j) = U_eva   * ( cos(delta_eva) * G_ij(k_i,k_j) + sin(delta_eva) * B_ij(k_i,k_j)); % P_i/  U_j
%             H(2 * size_Y + k_i, size_Y + k_j) = U_eva^2 * ( sin(delta_eva) * G_ij(k_i,k_j) - cos(delta_eva) * B_ij(k_i,k_j)); % P_i/phi_j
%             H(3 * size_Y + k_i,          k_j) = U_eva   * ( sin(delta_eva) * G_ij(k_i,k_j) - cos(delta_eva) * B_ij(k_i,k_j)); % Q_i/  U_j
%             H(3 * size_Y + k_i, size_Y + k_j) = U_eva^2 * (-cos(delta_eva) * G_ij(k_i,k_j) - sin(delta_eva) * B_ij(k_i,k_j)); % Q_i/phi_j
%         else
%             H(2 * size_Y + k_i,          k_i) = H(2 * size_Y + k_i,          k_i) + U_eva   * ( cos(delta_eva) * G_ij(k_i,k_j) + sin(delta_eva) * B_ij(k_i,k_j)); % P_i/  U_i
%             H(2 * size_Y + k_i, size_Y + k_i) = H(2 * size_Y + k_i, size_Y + k_i) - U_eva^2 * (-sin(delta_eva) * G_ij(k_i,k_j) + cos(delta_eva) * B_ij(k_i,k_j)); % P_i/phi_i
%             H(3 * size_Y + k_i,          k_i) = H(3 * size_Y + k_i,          k_i) + U_eva   * ( sin(delta_eva) * G_ij(k_i,k_j) - cos(delta_eva) * B_ij(k_i,k_j)); % Q_i/  U_i
%             H(3 * size_Y + k_i, size_Y + k_i) = H(3 * size_Y + k_i, size_Y + k_i) - U_eva^2 * ( cos(delta_eva) * G_ij(k_i,k_j) + sin(delta_eva) * B_ij(k_i,k_j)); % Q_i/phi_i            
%         end
%         H(2 * size_Y + k_i,          k_i) = H(2 * size_Y + k_i,          k_i) + U_eva   * ( cos(delta_eva) * G_ij(k_i,k_j) + sin(delta_eva) * B_ij(k_i,k_j)); % P_i/  U_i
%         H(2 * size_Y + k_i, size_Y + k_i) = H(2 * size_Y + k_i, size_Y + k_i) + U_eva^2 * (-sin(delta_eva) * G_ij(k_i,k_j) + cos(delta_eva) * B_ij(k_i,k_j)); % P_i/phi_i
%         H(3 * size_Y + k_i,          k_i) = H(3 * size_Y + k_i,          k_i) + U_eva   * ( sin(delta_eva) * G_ij(k_i,k_j) - cos(delta_eva) * B_ij(k_i,k_j)); % Q_i/  U_i  
%         H(3 * size_Y + k_i, size_Y + k_i) = H(3 * size_Y + k_i, size_Y + k_i) + U_eva^2 * ( cos(delta_eva) * G_ij(k_i,k_j) + sin(delta_eva) * B_ij(k_i,k_j)); % Q_i/phi_i
%     end
% end