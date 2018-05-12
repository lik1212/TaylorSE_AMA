% function [x_hat, z_hat, z_hat_all, Optional] = GenSE_AMA(z_all_data, z_all_flag, LineInfo, Inputs_SE)
%GENSE_AMA TODO
%   TODO

%% Temp, delete this

clear; load('temp_2');
z_all_data = z_all_data(:,1);

%% Inputs to Settings

Settings = defaultSettings(Inputs_SE);
U_eva    = Settings.U_eva;

%% TODO

[Y_012, Y_012_Node_ID] = LineInfo2Y_012(LineInfo);
Y_L1L2L3               = Y_012_to_Y_L1L2L3(Y_012);
x_hat = [repmat(400/sqrt(3),size(Y_L1L2L3,1),1); ...
    repmat([...
    z_all_data(z_all_flag.Accur_Type == 3 & z_all_flag.Meas_Type == 2 & z_all_flag.Phase == 1) ; ...
    z_all_data(z_all_flag.Accur_Type == 3 & z_all_flag.Meas_Type == 2 & z_all_flag.Phase == 2) ; ...
    z_all_data(z_all_flag.Accur_Type == 3 & z_all_flag.Meas_Type == 2 & z_all_flag.Phase == 3)], size(Y_L1L2L3,1)/3,1)]; 

size_Y	= size(Y_L1L2L3,1);	% Get number of grid nodes
H_index = table;
H_index.Node1_ID = ...
    repmat(Y_012_Node_ID,4,1);              % H_index includes all connection between node id and node names

H_index.Phase     = repmat([1; 2; 3], 4 * size_Y / 3, 1);
H_index.Meas_Type = repelem([1; 2; 3; 4], size_Y, 1);

%%

[~, z_order     ] = sort(z_all_flag.Accur_Type);
[~, z_order_back] = sort(z_order              );
z_all_flag_order  = z_all_flag(z_order,:);
z_all_data_order  = z_all_data(z_order,:);

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

z_all_data_with_phi = z_all_data_with_phi([1:3:9,2:3:9,3:3:9,10:3:18,11:3:18,12:3:18,19:3:27,20:3:27,21:3:27,28:3:36,29:3:36,30:3:36],1);
for k = 1 : 10
    
%     x_perfect = z_all_data_with_phi(1:18,1);
%     z_SE_perfect = get_z_SE(Y_L1L2L3, Y_012_Node_ID, x_perfect); % Probablty this part is wrong too.
    z_SE = get_z_SE(Y_L1L2L3, Y_012_Node_ID, x_hat); % Probablty this part is wrong too.
    z_SE(size(z_SE,1)/2 + 1 : end) = z_SE(size(z_SE,1)/2 + 1 : end) * 2;
%     H_perfect = get_H_SE(Y_L1L2L3, Y_012_Node_ID, x_perfect); % Probablty this part is wrong too.
    H = get_H_SE(Y_L1L2L3, Y_012_Node_ID, x_hat); % Probablty this part is wrong too.
    H(size(H,1)/2+1:end,size(H,2)/2+1:end) = 0;
    H(:,13:end) = []; % Temp
    H_AM   = H(H_flag,:);
    C_AM   = H(C_flag,:);
    
    % H_init = [H_AM; C_AM];
    % H_init = H_init(z_order_back,:);
    R = diag(z_all_flag_order.Sigma(1 : HC_switch - 1).^2);
    R(1:size(R,1)+1:end) = 1;
    % Build Hachtel matrix of the augmented matrix approach
    alpha       = min(diag(R));
    alpha = 1;
    % c_hat = 1
    z_hat = [z_SE(H_flag); z_all_data_order(HC_switch : end)];	% This part is wrong!
    delta_z = z_all_data_order - z_hat;
    sum(delta_z.^2)
    Hachtel     = [ ...
        1/alpha.*R                       , H_AM                             , zeros(size(H_AM,1),size(C_AM,1));...
        H_AM'                            , zeros(size(H_AM,2),size(H_AM,2)) , C_AM'                           ;...
        zeros(size(C_AM,1),size(H_AM,1)) , C_AM                             , zeros(size(C_AM,1),size(C_AM,1)) ...
        ];
    rhs_AM                  = [...      % Create right hand side of the LSE for the augmented matrix approach
        delta_z(1 : HC_switch - 1);...
        zeros(size(C_AM,2),1)  ;...
        delta_z(HC_switch :   end);...
        ];
    solution_vector = Hachtel \ rhs_AM;
    x_delta(:,1)         = solution_vector(      ...
        HC_switch : ...
        end               - numel(C_flag)     );
    x_hat(1:numel(x_delta)) = x_hat(1:numel(x_delta)) + x_delta;
    
end
%%
