% function Y_L1L2L3 = Y_012_to_Y_L1L2L3(Y_012)
%%  Function manual:
%   This function transforms the admittance matrix AM from
%   symmetric components 012 to conductor quantities L1L2L3
clear; load('temp_input.mat'); Y_012 = kron(eye(100),Y_012);
fprintf('Subfuntion: 012 --> L1L2L3\n');            % Command window output
a = exp(2/3*1i*pi);                                 % Initializing the transformation matrix T
T = 1/3*[1 1 1;1 a a^2; 1 a^2 a];

% % Option 1
% Y_L1L2L3    = zeros(size(Y_012));                   % Set size of conductor quantity matrix Y_L1L2L3
% num_of_nodes = size(Y_012,2)/3;                     % Get number of nodes
% for Y_KAM_i = 1 : 3 : 3 * num_of_nodes              % Transform Y_012 to Y_L1L2L3 (in steps of 3x3 matrices)
%     for Y_KAM_j = 1 : 3 : 3 * num_of_nodes
%         if Y_012(Y_KAM_i, Y_KAM_j) ~= 0
%             Y_L1L2L3(Y_KAM_i : Y_KAM_i + 2, Y_KAM_j : Y_KAM_j + 2 ) = ...
%                 T \ Y_012(Y_KAM_i : Y_KAM_i + 2 , Y_KAM_j : Y_KAM_j + 2) * T;
%         end
%     end
% end

% % Option 2
% B = reshape(Y_012,[3,28,3,28]);
% C = permute(B,[1,2,4,3]); % [1,3,4,2]
% D = reshape(C,[],3);
% E = (D * T);
% F = reshape(E,[28,3,28,3]);
% G = permute(F,[1,2,4,3]); % [1,3,4,2]
% H = reshape(G, 84, 84);
% I = reshape(H,[3,28,3,28]);
% J = permute(I,[1,3,4,2]); % [1,3,4,2]
% K = reshape(J,3,[]);
% L = T\K;
% M = reshape(L,[3,28,3,28]); 
% N = permute(M,[1,4,2,3]); % [1,3,4,2]
% O = reshape(N, 84, 84);
% 
% % Option 3
% E_1 = kron(eye(84 * 84 / 9),inv(T)) * E;
% F_1 = reshape(E_1,[28,3,28,3]);
% G_1 = permute(F_1,[1,2,4,3]); % [1,3,4,2]
% H_1 = reshape(G_1, 84, 84);
% 
% 
% load('temp_save.mat', 'Y_L1L2L3')