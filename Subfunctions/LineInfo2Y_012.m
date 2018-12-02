function [Y_012, Y_012_Node_ID] = LineInfo2Y_012(LineInfo)
%LINEINFO2Y_012 Create admittance matrix in symmetrical components from
%Line Info
%   From the Line parameters in LineInfo create the admittance matrix in
%   symmetrical components

%% Add series and shunt admittance to LineInfo

LineInfo.Y_series_1 = ((LineInfo.r                   + 1i * LineInfo.x                   ).* LineInfo.l).^ -1;
LineInfo.Y_series_0 = ((LineInfo.r .* LineInfo.r0_r1 + 1i * LineInfo.x .* LineInfo.x0_x1 ).* LineInfo.l).^ -1;
LineInfo.Y_shunt_1  = LineInfo.c  * 10^-9 * 0.5 * 2 * pi * 50 .* LineInfo.l; % Sincal default in nF
LineInfo.Y_shunt_0  = LineInfo.c0 * 10^-9 * 0.5 * 2 * pi * 50 .* LineInfo.l; % Sincal default in nF

%% Start creating the admittance matrix in symmetrical component

Node_IDs = unique(LineInfo{:, {'Node1_ID', 'Node2_ID'}});

Y_0 = zeros(numel(Node_IDs)); % initial zero   component
Y_1 = zeros(numel(Node_IDs)); % initial direct component

for k_Li = 1 : size(LineInfo, 1) % over all Lines
    if all(LineInfo{k_Li, {'Flag_State1', 'Flag_State2'}}) % Series elements, only both side connected lines
        N1_pos = Node_IDs == LineInfo.Node1_ID(k_Li); % Node 1 position in matrix
        N2_pos = Node_IDs == LineInfo.Node2_ID(k_Li); % Node 2 position in matrix
        Y_0(N1_pos, N1_pos) = + LineInfo.Y_series_0(k_Li) + Y_0(N1_pos, N1_pos); % zero component, diagonal
        Y_0(N2_pos, N2_pos) = + LineInfo.Y_series_0(k_Li) + Y_0(N2_pos, N2_pos); % zero component, diagonal
        Y_0(N1_pos, N2_pos) = - LineInfo.Y_series_0(k_Li) + Y_0(N1_pos, N2_pos); % zero component, non-diagonal
        Y_0(N2_pos, N1_pos) = - LineInfo.Y_series_0(k_Li) + Y_0(N2_pos, N1_pos); % zero component, non-diagonal
        Y_1(N1_pos, N1_pos) = + LineInfo.Y_series_1(k_Li) + Y_1(N1_pos, N1_pos); % direct component, diagonal
        Y_1(N2_pos, N2_pos) = + LineInfo.Y_series_1(k_Li) + Y_1(N2_pos, N2_pos); % direct component, diagonal       
        Y_1(N1_pos, N2_pos) = - LineInfo.Y_series_1(k_Li) + Y_1(N1_pos, N2_pos); % direct component, non-diagonal
        Y_1(N2_pos, N1_pos) = - LineInfo.Y_series_1(k_Li) + Y_1(N2_pos, N1_pos); % direct component, non-diagonal
    end
    if LineInfo{k_Li, {'Flag_State1'}} % Shunt elements
        Y_0(N1_pos, N1_pos) = + LineInfo.Y_shunt_0 (k_Li) + Y_0(N1_pos, N1_pos);
        Y_1(N1_pos, N1_pos) = + LineInfo.Y_shunt_1 (k_Li) + Y_1(N1_pos, N1_pos);
    end
    if LineInfo{k_Li, {'Flag_State2'}} % Shunt elements
        Y_0(N2_pos, N2_pos) = + LineInfo.Y_shunt_0 (k_Li) + Y_0(N2_pos, N2_pos);
        Y_1(N2_pos, N2_pos) = + LineInfo.Y_shunt_1 (k_Li) + Y_1(N2_pos, N2_pos);
    end
end
Y_2 = Y_1; % inverse component equal to direct component

%% Create the admittance matrix in symmetrical components

Y_012 = ...
    kron(Y_0, diag([1, 0, 0])) + ...
    kron(Y_1, diag([0, 1, 0])) + ...
    kron(Y_2, diag([0, 0, 1]));

Y_012_Node_ID = repelem(Node_IDs, 3, 1); % Save also the Node_IDs of the matrix
% The Node_IDs are important to match the measurement values to the right
% positions with the measurement functions.