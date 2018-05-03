function BranchRes = NodeRes2BranchRes(NodeRes,SinInfo,Y_L1L2L3)
% This function calculates the currents I from the voltage deltaU and the
% angle Phi (TODO)
%
%
% Author(s): P.Gassler, R. Brandalik

nb_nodes        = size(SinInfo.Node.Node_ID,1);
nb_lines        = size(SinInfo.Line.Element_ID,1);
nb_instants     = size(NodeRes.ResTime,1)/nb_nodes;
BranchRes_12    = zeros(nb_instants * nb_lines,6);
BranchRes_21    = zeros(nb_instants * nb_lines,6);
SinInfo.Line    = sortrows(SinInfo.Line,'Element_ID');
SinInfo.Node    = sortrows(SinInfo.Node,'Node_ID');
NodeRes.U1_comp = NodeRes.U1 .* exp(1i * deg2rad(NodeRes.phi1));
NodeRes.U2_comp = NodeRes.U2 .* exp(1i * deg2rad(NodeRes.phi2));
NodeRes.U3_comp = NodeRes.U3 .* exp(1i * deg2rad(NodeRes.phi3));
BranchRes_all_waitbar = waitbar(0,'Generating BranchRes_all','Name','AMA State Estimation','CreateCancelBtn',...
    'setappdata(gcbf,''canceling'',1)');
setappdata(BranchRes_all_waitbar,'canceling',0);

for k_line = 1 : nb_lines
    Node1_ID = SinInfo.Line.Node1_ID(k_line);
    Node2_ID = SinInfo.Line.Node2_ID(k_line);
    [~,Node1_Num] = ismember(Node1_ID,SinInfo.Node.Node_ID);
    [~,Node2_Num] = ismember(Node2_ID,SinInfo.Node.Node_ID);
    U12 = reshape([...
        NodeRes.U1_comp(NodeRes.Node_ID == Node1_ID) -  NodeRes.U1_comp(NodeRes.Node_ID == Node2_ID),...
        NodeRes.U2_comp(NodeRes.Node_ID == Node1_ID) -  NodeRes.U2_comp(NodeRes.Node_ID == Node2_ID),...
        NodeRes.U3_comp(NodeRes.Node_ID == Node1_ID) -  NodeRes.U3_comp(NodeRes.Node_ID == Node2_ID) ...
        ].',[],1);
    U21 = reshape([...
        NodeRes.U1_comp(NodeRes.Node_ID == Node2_ID) -  NodeRes.U1_comp(NodeRes.Node_ID == Node1_ID),...
        NodeRes.U2_comp(NodeRes.Node_ID == Node2_ID) -  NodeRes.U2_comp(NodeRes.Node_ID == Node1_ID),...
        NodeRes.U3_comp(NodeRes.Node_ID == Node2_ID) -  NodeRes.U3_comp(NodeRes.Node_ID == Node1_ID) ...
        ].',[],1);
    Y_temp = Y_L1L2L3((Node1_Num-1)*3+1:(Node1_Num-1)*3+3,(Node2_Num-1)*3+1:(Node2_Num-1)*3+3);
    I12 = abs(sum(reshape(repmat(Y_temp,nb_instants,1) .* U12,3,[])));
    I21 = abs(sum(reshape(repmat(Y_temp,nb_instants,1) .* U21,3,[])));
    BranchRes_12((k_line-1) * nb_instants + 1 : k_line * nb_instants,1) = repmat(SinInfo.Line.Terminal1_ID(k_line),nb_instants,1);
    BranchRes_12((k_line-1) * nb_instants + 1 : k_line * nb_instants,2) = repmat(SinInfo.Line.Terminal2_ID(k_line),nb_instants,1);
    BranchRes_12((k_line-1) * nb_instants + 1 : k_line * nb_instants,3) = I12(1:nb_instants);
    BranchRes_12((k_line-1) * nb_instants + 1 : k_line * nb_instants,4) = I12(nb_instants + 1:nb_instants * 2);
    BranchRes_12((k_line-1) * nb_instants + 1 : k_line * nb_instants,5) = I12(2 * nb_instants + 1:nb_instants *3);
    BranchRes_12((k_line-1) * nb_instants + 1 : k_line * nb_instants,6) = 1:nb_instants;
    BranchRes_21((k_line-1) * nb_instants + 1 : k_line * nb_instants,1) = repmat(SinInfo.Line.Terminal2_ID(k_line),nb_instants,1);
    BranchRes_21((k_line-1) * nb_instants + 1 : k_line * nb_instants,2) = repmat(SinInfo.Line.Terminal1_ID(k_line),nb_instants,1);
    BranchRes_21((k_line-1) * nb_instants + 1 : k_line * nb_instants,3) = I21(1:nb_instants);
    BranchRes_21((k_line-1) * nb_instants + 1 : k_line * nb_instants,4) = I21(nb_instants + 1:nb_instants * 2);
    BranchRes_21((k_line-1) * nb_instants + 1 : k_line * nb_instants,5) = I21(2 * nb_instants + 1:nb_instants *3);
    BranchRes_21((k_line-1) * nb_instants + 1 : k_line * nb_instants,6) = 1:nb_instants;
    if updateWaitbar('update',BranchRes_all_waitbar,k_line/nb_lines,'Generating BranchRes_all')
        return
    end
end
clear NodeRes 
BranchRes = [BranchRes_12;BranchRes_21];
clear BranchRes_12 BranchRes21
BranchRes = array2table(BranchRes);
BranchRes.Properties.VariableNames = {'Terminal1_ID','Terminal2_ID','I1','I2','I3','ResTime'};
BranchRes = sortrows(BranchRes,'Terminal1_ID','ascend');
BranchRes = sortrows(BranchRes,'ResTime','ascend');
updateWaitbar('delete',BranchRes_all_waitbar);
end