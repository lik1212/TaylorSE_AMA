function BranchRes = NodeRes2BranchRes(NodeRes, SinInfo, Y_L1L2L3)
%NodeRes2BranchRes - Sincal NodeRes to BranchRes, Y_L1L2L3 (admittance
%matrix in conductor quantity) can be get with the functions GetLineInfo,
%LineInfo2Y_012 & Y_012_to_Y_L1L2L3
%
% Author(s): P.Gassler, R. Brandalik

%% Initial preperation

num_Nodes       = numel(SinInfo.Node.Node_ID   );
num_Lines       = numel(SinInfo.Line.Element_ID);
num_instants    = numel(NodeRes.ResTime)/num_Nodes;
BranchRes_12    = zeros(num_instants * num_Lines,6); % Initial branches in one direction
BranchRes_21    = zeros(num_instants * num_Lines,6); % Initial branches in the other direction
SinInfo.Line    = sortrows(SinInfo.Line, 'Element_ID'); % Sort Lines by Element_ID, TODO: Needed?
SinInfo.Node    = sortrows(SinInfo.Node, 'Node_ID'   ); % Sord Nodes by Node_ID   , TODO: Needed?
NodeRes.U1_comp = NodeRes.U1 .* exp(1i * deg2rad(NodeRes.phi1)); % comp - Complex voltage
NodeRes.U2_comp = NodeRes.U2 .* exp(1i * deg2rad(NodeRes.phi2));
NodeRes.U3_comp = NodeRes.U3 .* exp(1i * deg2rad(NodeRes.phi3));

%% NodeRes to BranchRes

for k_Line = 1 : num_Lines % over all lines
    Node1_ID  = SinInfo.Line.Node1_ID(k_Line); % Node1_ID of Line
    Node2_ID  = SinInfo.Line.Node2_ID(k_Line); % Node2_ID of Line
    Node1_Num = find(ismember(SinInfo.Node.Node_ID, Node1_ID));
    Node2_Num = find(ismember(SinInfo.Node.Node_ID, Node2_ID));
    k_U1 = reshape([...
        NodeRes.U1_comp(NodeRes.Node_ID == Node1_ID),...
        NodeRes.U2_comp(NodeRes.Node_ID == Node1_ID),...
        NodeRes.U3_comp(NodeRes.Node_ID == Node1_ID) ...
        ].',[],1); % Voltage one Node of Line
    k_U2 = reshape([...
        NodeRes.U1_comp(NodeRes.Node_ID == Node2_ID),...
        NodeRes.U2_comp(NodeRes.Node_ID == Node2_ID),...
        NodeRes.U3_comp(NodeRes.Node_ID == Node2_ID) ...
        ].',[],1); % Voltage other Node of Line
    U12 = k_U1 - k_U2; % Voltage difference in one direction
    U21 = k_U2 - k_U1; % Voltage difference in the other direction
    k_U1_NodeOrder = [...
        NodeRes.U1_comp(NodeRes.Node_ID == Node1_ID);...
        NodeRes.U2_comp(NodeRes.Node_ID == Node1_ID);...
        NodeRes.U3_comp(NodeRes.Node_ID == Node1_ID) ...
        ];
    k_U2_NodeOrder = [...
        NodeRes.U1_comp(NodeRes.Node_ID == Node2_ID);...
        NodeRes.U2_comp(NodeRes.Node_ID == Node2_ID);...
        NodeRes.U3_comp(NodeRes.Node_ID == Node2_ID) ...
        ];    
    Y_k_Line = Y_L1L2L3(...
        (Node1_Num - 1) * 3 + 1 : (Node1_Num - 1) * 3 + 3, ...
        (Node2_Num - 1) * 3 + 1 : (Node2_Num - 1) * 3 + 3); % Line admittance
    % Currents in both directions
    I12(:,1) = sum(reshape(repmat(Y_k_Line,num_instants,1) .* U12,3,[])); % Order is: [L1 all instances, L2 all instances, L3 ...]
    I21(:,1) = sum(reshape(repmat(Y_k_Line,num_instants,1) .* U21,3,[])); % Order is: [L1 all instances, L2 all instances, L3 ...]
    S12 = k_U1_NodeOrder .* conj(I12);
    S21 = k_U2_NodeOrder .* conj(I21);
    % One diretcion
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 1) = repmat(SinInfo.Line.Terminal1_ID(k_Line),num_instants,1); % Terminal1_ID
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 2) = repmat(SinInfo.Line.Terminal2_ID(k_Line),num_instants,1); % Terminal2_ID
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 3) = real(S12(                   1 : num_instants    ));       % P1
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 4) = imag(S12(                   1 : num_instants    ));       % Q1
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 5) = abs (S12(                   1 : num_instants    ));       % S1    
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 6) = abs (I12(                   1 : num_instants    ));       % I1
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 7) = real(S12(    num_instants + 1 : num_instants * 2));       % P2
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 8) = imag(S12(    num_instants + 1 : num_instants * 2));       % Q2
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 9) = abs (S12(    num_instants + 1 : num_instants * 2));       % S2    
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants,10) = abs (I12(    num_instants + 1 : num_instants * 2));       % I2
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants,11) = real(S12(2 * num_instants + 1 : num_instants * 3));       % P3
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants,12) = imag(S12(2 * num_instants + 1 : num_instants * 3));       % Q3
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants,13) = abs (S12(2 * num_instants + 1 : num_instants * 3));       % S3    
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants,14) = abs (I12(2 * num_instants + 1 : num_instants * 3));       % I3
    BranchRes_12((k_Line - 1) * num_instants + 1 : k_Line * num_instants,15) = 1 : num_instants;                                         % ResTime
    % Other direction
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 1) = repmat(SinInfo.Line.Terminal2_ID(k_Line),num_instants,1); % Terminal1_ID
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 2) = repmat(SinInfo.Line.Terminal1_ID(k_Line),num_instants,1); % Terminal2_ID
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 3) = real(S21(                   1 : num_instants    ));       % P1
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 4) = imag(S21(                   1 : num_instants    ));       % Q1
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 5) = abs (S21(                   1 : num_instants    ));       % S1
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 6) = abs (I21(                   1 : num_instants    ));       % I1
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 7) = real(S21(    num_instants + 1 : num_instants * 2));       % P2
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 8) = imag(S21(    num_instants + 1 : num_instants * 2));       % Q2
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants, 9) = abs (S21(    num_instants + 1 : num_instants * 2));       % S2
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants,10) = abs (I21(    num_instants + 1 : num_instants * 2));       % I2
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants,11) = real(S21(2 * num_instants + 1 : num_instants * 3));       % P3
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants,12) = imag(S21(2 * num_instants + 1 : num_instants * 3));       % Q3
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants,13) = abs (S21(2 * num_instants + 1 : num_instants * 3));       % S3    
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants,14) = abs (I21(2 * num_instants + 1 : num_instants * 3));       % I3  
    BranchRes_21((k_Line - 1) * num_instants + 1 : k_Line * num_instants,15) = 1 : num_instants;                                         % ResTime
end

clear NodeRes
BranchRes = [BranchRes_12; BranchRes_21];
clear BranchRes_12 BranchRes21
BranchRes = array2table(BranchRes, 'VariableNames', {'Terminal1_ID','Terminal2_ID',...
    'P1','Q1','S1','I1', ...
    'P2','Q2','S2','I2', ...
    'P3','Q3','S3','I3', ...
    'ResTime'});

BranchRes = sortrows(BranchRes, 'Terminal1_ID', 'ascend');
BranchRes = sortrows(BranchRes, 'ResTime',      'ascend');
