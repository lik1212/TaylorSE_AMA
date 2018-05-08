
k_instant = 1;
k_line = 1;
Node1_ID = SinInfo.Line.Node1_ID(k_line);
Node2_ID = SinInfo.Line.Node2_ID(k_line);
[~,Node1_Num] = ismember(Node1_ID,SinInfo.Node.Node_ID);
[~,Node2_Num] = ismember(Node2_ID,SinInfo.Node.Node_ID);
% U1_L1_ = NodeRes.U1(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node1_ID) *...
%     exp(1i * deg2rad(NodeRes.phi1(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node1_ID)));
% U1_L2_ = NodeRes.U2(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node1_ID) *...
%     exp(1i * deg2rad(NodeRes.phi2(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node1_ID)));
% U1_L3_ = NodeRes.U3(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node1_ID) *...
%     exp(1i * deg2rad(NodeRes.phi3(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node1_ID)));
% U2_L1_ = NodeRes.U1(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node2_ID) *...
%     exp(1i * deg2rad(NodeRes.phi1(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node2_ID)));
% U2_L2_ = NodeRes.U2(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node2_ID) *...
%     exp(1i * deg2rad(NodeRes.phi2(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node2_ID)));
% U2_L3_ = NodeRes.U3(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node2_ID) *...
%     exp(1i * deg2rad(NodeRes.phi3(NodeRes.ResTime == k_instant & NodeRes.Node_ID == Node2_ID)));
U1_L1_ = NodeRes.U1(k_line) *...
    exp(1i * Phi1(k_line));
U1_L2_ = NodeRes.U2(k_line) *...
    exp(1i * Phi2(k_line));
U1_L3_ = NodeRes.U3(k_line) *...
    exp(1i * Phi3(k_line));
U2_L1_ = NodeRes.U1(k_line+1) *...
    exp(1i * Phi1(k_line + 1));
U2_L2_ = NodeRes.U2(k_line+1) *...
    exp(1i * Phi2(k_line + 1));
U2_L3_ = NodeRes.U3(k_line+1) *...
    exp(1i * Phi3(k_line + 1));
BranchRes((k_instant-1)*nb_lines + k_line,1) = SinInfo.Line.Terminal1_ID(k_line);
BranchRes((k_instant-1)*nb_lines + k_line,2) = SinInfo.Line.Terminal2_ID(k_line);
I12 = abs(Y_L1L2L3((Node1_Num-1)*3+1:(Node1_Num-1)*3+3,(Node2_Num-1)*3+1:(Node2_Num-1)*3+3)...
    * ([U1_L1_;U1_L2_;U1_L3_]-[U2_L1_;U2_L2_;U2_L3_]));
BranchRes((k_instant-1)*nb_lines + k_line,3) = I12(1);
BranchRes((k_instant-1)*nb_lines + k_line,4) = I12(2);
BranchRes((k_instant-1)*nb_lines + k_line,5) = I12(3);

% BranchRes((k_instant-1)*nb_lines + 1:k_instant*nb_lines,6) = ones(nb_lines,1) * k_instant;