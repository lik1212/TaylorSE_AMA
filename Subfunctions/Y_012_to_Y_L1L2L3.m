function Y_L1L2L3 = Y_012_to_Y_L1L2L3(Y_012, full_flag)
%% Y_L1L2L3 = Y_012_to_Y_L1L2L3(Y_012, full_flag)
%
%   This function transforms the admittance matrix from symmetric
%   components 012 to conductor quantities L1L2L3,
%
% RB

%% Main
if nargin < 2; full_flag = false; end
a = exp(2 / 3 * 1i * pi);                   % Initializing the transformation matrix T
T = 1/3 * [       ...
    1   1   1   ; ...
    1   a   a^2 ; ...
    1   a^2 a     ...
    ];
sz_Y = size(Y_012, 1);
if full_flag == false                       % Option 1, good if Y_012 is very sparse
    Y_L1L2L3    = zeros(sz_Y);              % Set size of conductor quantity matrix Y_L1L2L3
    for Y_KAM_i = 1 : 3 : sz_Y              % Transform Y_012 to Y_L1L2L3 (in steps of 3x3 matrices)
        for Y_KAM_j = 1 : 3 : sz_Y
            if Y_012(Y_KAM_i, Y_KAM_j) ~= 0
                Y_L1L2L3(Y_KAM_i : Y_KAM_i + 2, Y_KAM_j : Y_KAM_j + 2 ) = ...
                    T \ Y_012(Y_KAM_i : Y_KAM_i + 2 , Y_KAM_j : Y_KAM_j + 2) * T;
            end
        end
    end
else % Option 2, some play with reshape and permute, is good if Y_012 is not sparse
    A        =     reshape(permute(reshape(Y_012, [3      , sz_Y/3 , 3      , sz_Y/3 ]), [1, 2, 4, 3]), []  , 3    ) * T ;
    B        =     reshape(permute(reshape(A    , [sz_Y/3 , 3      , sz_Y/3 , 3      ]), [1, 2, 4, 3]), sz_Y, sz_Y )     ;
    C        = T \ reshape(permute(reshape(B    , [3      , sz_Y/3 , 3      , sz_Y/3 ]), [1, 3, 4, 2]), 3   , []   )     ;
    Y_L1L2L3 =     reshape(permute(reshape(C    , [3      , sz_Y/3 , 3      , sz_Y/3 ]), [1, 4, 2, 3]), sz_Y, sz_Y )     ;
    % % Option 3 (not good, needs to much memory)
    % E_1      = kron(eye(sz_Y * sz_Y / 9),inv(T)) * A;
    % Y_L1L2L3 = reshape(permute(reshape(E_1  , [sz_Y/3 , 3      , sz_Y/3  ,3       ]),[1, 2, 4, 3]), sz_Y, sz_Y )     ;
end