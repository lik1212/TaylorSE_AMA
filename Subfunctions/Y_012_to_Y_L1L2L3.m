function Y_L1L2L3 = Y_012_to_Y_L1L2L3(Y_012)
%%  Function manual:
%   This function transforms the admittance matrix AM from
%   symmetric components 012 to conductor quantities L1L2L3

    % Command window output
        fprintf('Subfuntion: 012 --> L1L2L3\n');
    
    % Initializing the transformation matrix T
        a = exp(2/3*1i*pi);
        T = 1/3*[1 1 1;1 a a^2; 1 a^2 a];
    % Get number of nodes
        num_of_nodes = size(Y_012,2)/3;
    % Set size of conductor quantity matrix Y_L1L2L3
        Y_L1L2L3 = zeros(3*num_of_nodes,3*num_of_nodes);
    % Transform Y_012 to Y_L1L2L3 (in steps of 3x3 matrices)
        for Y_AM_i = 1:3:3*num_of_nodes
            for Y_KAM_j = 1:3:3*num_of_nodes
                if Y_012(Y_AM_i,Y_KAM_j) ~= 0
                    Y_L1L2L3(Y_AM_i:Y_AM_i+2,Y_KAM_j:Y_KAM_j+2) = ...
                        T\Y_012(Y_AM_i:Y_AM_i+2,Y_KAM_j:Y_KAM_j+2)*T;
                end
            end
        end
