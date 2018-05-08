function [Y_012, Y_012_Node_ID] = LineInfo2Y_012(LineInfo)
%LINEINFO2Y_012 Summary of this function goes here
%   Detailed explanation goes here

LineInfo.Y_series_1 = ((LineInfo.r                   + 1i * LineInfo.x                   ).* LineInfo.l).^ -1;
LineInfo.Y_series_0 = ((LineInfo.r .* LineInfo.r0_r1 + 1i * LineInfo.x .* LineInfo.x0_x1 ).* LineInfo.l).^ -1;

LineInfo.Y_shunt_1  = LineInfo.c  * 0.5 * 2 * pi * 50 .* LineInfo.l;
LineInfo.Y_shunt_0  = LineInfo.c0 * 0.5 * 2 * pi * 50 .* LineInfo.l;

Node_IDs = unique(LineInfo{:, {'Node1_ID', 'Node2_ID'}});

Y_0 = zeros(numel(Node_IDs));
Y_1 = zeros(numel(Node_IDs));

for k_Li = 1 : size(LineInfo, 1)
    if all(LineInfo{k_Li, {'Flag_State1','Flag_State2'}})
        N1_pos = Node_IDs == LineInfo.Node1_ID(k_Li);
        N2_pos = Node_IDs == LineInfo.Node2_ID(k_Li);
        Y_0(N1_pos, N1_pos) = + LineInfo.Y_series_0(k_Li) + Y_0(N1_pos, N1_pos);
        Y_0(N2_pos, N2_pos) = + LineInfo.Y_series_0(k_Li) + Y_0(N2_pos, N2_pos);        
        Y_0(N1_pos, N2_pos) = - LineInfo.Y_series_0(k_Li)                      ;
        Y_0(N2_pos, N1_pos) = - LineInfo.Y_series_0(k_Li)                      ;
        Y_1(N1_pos, N1_pos) = + LineInfo.Y_series_1(k_Li) + Y_1(N1_pos, N1_pos); 
        Y_1(N2_pos, N2_pos) = + LineInfo.Y_series_1(k_Li) + Y_1(N2_pos, N2_pos);        
        Y_1(N1_pos, N2_pos) = - LineInfo.Y_series_1(k_Li)                      ;
        Y_1(N2_pos, N1_pos) = - LineInfo.Y_series_1(k_Li)                      ;
    end
    if LineInfo{k_Li, {'Flag_State1'}}
        Y_0(N1_pos, N1_pos) = + LineInfo.Y_shunt_0 (k_Li) + Y_0(N1_pos, N1_pos);
        Y_1(N1_pos, N1_pos) = + LineInfo.Y_shunt_1 (k_Li) + Y_1(N1_pos, N1_pos);
    end
    if LineInfo{k_Li, {'Flag_State2'}}
        Y_0(N2_pos, N2_pos) = + LineInfo.Y_shunt_0 (k_Li) + Y_0(N2_pos, N2_pos);
        Y_1(N2_pos, N2_pos) = + LineInfo.Y_shunt_1 (k_Li) + Y_1(N2_pos, N2_pos);
    end
end

Y_2 = Y_1;

Y_012 = ...
    kron(Y_0, diag([1, 0, 0])) + ...
    kron(Y_1, diag([0, 1, 0])) + ...
    kron(Y_2, diag([0, 0, 1]));

Y_012_Node_ID = repelem(Node_IDs, 3, 1);

end