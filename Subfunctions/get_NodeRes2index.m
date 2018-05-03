function NodeRes2index_t = get_NodeRes2index(NodeRes_t)

% Number of nodes
num_Nodes = size(NodeRes_t,1);

% Initial
U_L1L2L3 = zeros(3*num_Nodes,1);
P_L1L2L3 = zeros(3*num_Nodes,1);  
Q_L1L2L3 = zeros(3*num_Nodes,1);  
% S_L1L2L3 = zeros(3*num_Nodes,1);  
% I_L1L2L3 = zeros(3*num_Nodes,1);  

for k_Node=1:num_Nodes % all nodes
    U_L1L2L3(3*k_Node-2:3*k_Node) = [...
        NodeRes_t.U1(k_Node)*exp(NodeRes_t.phi1(k_Node)*(pi/180)*1i);...
        NodeRes_t.U2(k_Node)*exp(NodeRes_t.phi2(k_Node)*(pi/180)*1i);...
        NodeRes_t.U3(k_Node)*exp(NodeRes_t.phi3(k_Node)*(pi/180)*1i)]*10^3;
    P_L1L2L3(3*k_Node-2:3*k_Node) = ...
        [NodeRes_t.P1(k_Node);NodeRes_t.P2(k_Node);NodeRes_t.P3(k_Node)]*10^6;
    Q_L1L2L3(3*k_Node-2:3*k_Node) = ...
        [NodeRes_t.Q1(k_Node);NodeRes_t.Q2(k_Node);NodeRes_t.Q3(k_Node)]*10^6;
%     S_L1L2L3(3*k_Node-2:3*k_Node) = [...
%         NodeRes_t.P1(k_Node) + 1i*NodeRes_t.Q1(k_Node);...
%         NodeRes_t.P2(k_Node) + 1i*NodeRes_t.Q2(k_Node);...        
%         NodeRes_t.P3(k_Node) + 1i*NodeRes_t.Q3(k_Node)...
%         ]*10^6;
%     I_L1L2L3 = ...
%         conj(S_L1L2L3./U_L1L2L3);
end

% NodeRes2index table
NodeRes2index_t = table;
NodeRes2index_t.U_L1L2L3 = U_L1L2L3;
NodeRes2index_t.P_L1L2L3 = P_L1L2L3;
NodeRes2index_t.Q_L1L2L3 = Q_L1L2L3;
% NodeRes2index_t.S_L1L2L3 = S_L1L2L3;
% NodeRes2index_t.I_L1L2L3 = I_L1L2L3;
NodeRes2index_t.U_abs = abs(NodeRes2index_t.U_L1L2L3);
NodeRes2index_t.U_angle = angle(NodeRes2index_t.U_L1L2L3);