function [H, H_index] = get_H(Y_L1L2L3, Y_012_index, U_eva)
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

delta1_eva  =    0     ;
delta2_eva  =  2/3 * pi;
delta3_eva  = -2/3 * pi;

H_index = table;
H_index.Node1_ID = ...
    repmat(Y_012_index,4,1);              % H_index includes all connection between node id and node names

H_index.Phase     = repmat([1; 2; 3], 4 * size_Y / 3, 1);
H_index.Meas_Type = repelem([1; 2; 3; 4], size_Y, 1);

%% Initialize meaurement model matrix H
H       = zeros(4*size_Y,2*size_Y);   % H includes all possible measurement modell equations

%%  Set measurement modell equations for voltage amounts U_L1L2L3
H(1:2*size_Y,1:2*size_Y) = eye(2*size_Y);

%%  Set measurement modell equations for active power P_L1L2L3
for k_P = 1:size_Y
    for k_Pos = 1:size_Y
        case_phase = mod(k_P,3) - mod(k_Pos,3);
        switch case_phase
            case 0      % case L1-L1 L2-L2 L3-L3
                delta_eva = delta1_eva;
            case {-1,2} % case L1-L2 L2-L3 L3-L1
                delta_eva = delta2_eva;
            case {-2,1} % case L2-L1 L3-L2 L1-L3
                delta_eva = delta3_eva;
        end
        H(2*size_Y+k_P,k_Pos)         = U_eva   * (cos(delta_eva)*G_ij(k_P,k_Pos) + sin(delta_eva)*B_ij(k_P,k_Pos));
        H(2*size_Y+k_P,size_Y+k_Pos)  = U_eva^2 * (sin(delta_eva)*G_ij(k_P,k_Pos) - cos(delta_eva)*B_ij(k_P,k_Pos));
    end
end

%%  Set measurement modell equations for reactive power Q_L1L2L3
for k_P = 1:size_Y
    for k_Pos = 1:size_Y
        case_phase = mod(k_P,3)-mod(k_Pos,3);
        switch case_phase
            case 0
                delta_eva = delta1_eva;
            case {-1,2}
                delta_eva = delta2_eva;
            case {-2,1}
                delta_eva = delta3_eva;
        end
        H(3*size_Y+k_P,k_Pos)          	= U_eva   * ( sin(delta_eva)*G_ij(k_P,k_Pos) - cos(delta_eva)*B_ij(k_P,k_Pos));
        H(3*size_Y+k_P,size_Y+k_Pos)    = U_eva^2 * (-cos(delta_eva)*G_ij(k_P,k_Pos) - sin(delta_eva)*B_ij(k_P,k_Pos));
    end
end
end