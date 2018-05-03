function [Y_012, Y_012_index] = Mat2Sin_GetY_012_withC(Sin_Name,Sin_Path)
%%  Function manual:
%   

% v2016_02_16

%%

SinInfo = Mat2Sin_GetSinInfo(Sin_Name,Sin_Path);

%% Trafo raus

NodeID_TR     = [SinInfo.TwoWindingTransformer.Node1_ID,SinInfo.TwoWindingTransformer.Node2_ID];
TerminalID_TR = [SinInfo.TwoWindingTransformer.Terminal1_ID,SinInfo.TwoWindingTransformer.Terminal2_ID];
Node_ID_Infeeder = SinInfo.Infeeder.Node1_ID;
TerminalID_Infeeder = SinInfo.Terminal.Terminal_ID(SinInfo.Terminal.Element_ID == SinInfo.Infeeder.Element_ID);

SinInfo.Infeeder.Node1_ID = NodeID_TR(NodeID_TR ~= Node_ID_Infeeder);
SinInfo.Infeeder.Element_ID = SinInfo.TwoWindingTransformer.Element_ID;  
TerminalID_TR(NodeID_TR == Node_ID_Infeeder);
SinInfo.Terminal(ismember(SinInfo.Terminal.Terminal_ID,[TerminalID_TR(NodeID_TR == Node_ID_Infeeder), TerminalID_Infeeder]),:) = [];
SinInfo = rmfield(SinInfo,'TwoWindingTransformer');

SinInfo.Node(SinInfo.Node.Node_ID == Node_ID_Infeeder,:) = [];

%%

LineInfoWanted = {'r','x','c','r0_r1','x0_x1','c0','l'};
LineInfo = Mat2Sin_GetLineInfo(SinInfo,LineInfoWanted,Sin_Name,Sin_Path);

% Number of nodes
Node_num = size(SinInfo.Node,1);
% Initial 
Y_012 = zeros(3*Node_num,3*Node_num);
Y_012_index = cell(3*Node_num,1);

for k_Node = 1:Node_num
    Y_012_index(3*k_Node-2:3*k_Node) = SinInfo.Node.Name(k_Node);
end

for Y_KAM_i = 1:(3*Node_num)
    Node_Name_i = Y_012_index{Y_KAM_i};
    Node_ID_i = ...
        SinInfo.Node.Node_ID(strcmp(SinInfo.Node.Name,Node_Name_i));
    for Y_KAM_j = 1:(3*Node_num)
        Node_Name_j = Y_012_index{Y_KAM_j};
        Node_ID_j = ...
            SinInfo.Node.Node_ID(strcmp(SinInfo.Node.Name,Node_Name_j)); 
        if mod(Y_KAM_i,3) == 1 && mod(Y_KAM_j,3) == 1 % zero component
            if Y_KAM_j == Y_KAM_i % diagonal
                LineConn_wNode = ...
                    SinInfo.Line.Name(SinInfo.Line.Node1_ID == Node_ID_i |...
                    SinInfo.Line.Node2_ID == Node_ID_i);
                for k_LineConn = 1:numel(LineConn_wNode)
                    % check if switch on
                    k_Line_EleID = LineInfo.Element_ID(strcmp(LineInfo.Name,LineConn_wNode{k_LineConn}));
                    k_Line_Flag_State = ...
                        SinInfo.Terminal.Flag_State(SinInfo.Terminal.Element_ID == k_Line_EleID);
                    % if connected on both ends
                    if sum(k_Line_Flag_State) == 2
                        k_LineConn_logic = ...
                            strcmp(LineInfo.Name,LineConn_wNode{k_LineConn});
                        Z_lineConn = ...
                            (LineInfo.r(k_LineConn_logic)*LineInfo.r0_r1(k_LineConn_logic) + ...
                            1i*(LineInfo.x(k_LineConn_logic)*LineInfo.x0_x1(k_LineConn_logic)))*...
                            LineInfo.l(k_LineConn_logic); 
                        Y_C = LineInfo.c0(k_LineConn_logic) * LineInfo.l(k_LineConn_logic)*10^-9; % nF -> F
                        Y_012(Y_KAM_i,Y_KAM_j) = Y_012(Y_KAM_i,Y_KAM_j) + Z_lineConn^-1 + Y_C/2;  
                    end
                end
            else % not diagonal
                % check if connected (bouth directions)
                LineConn_wNode = ...
                    SinInfo.Line.Name(...
                    (SinInfo.Line.Node1_ID == Node_ID_i & SinInfo.Line.Node2_ID == Node_ID_j) | ...
                    (SinInfo.Line.Node2_ID == Node_ID_i & SinInfo.Line.Node1_ID == Node_ID_j)); 
                if isempty(LineConn_wNode) == false
                    % check if switch on
                    k_Line_EleID = LineInfo.Element_ID(strcmp(LineInfo.Name,LineConn_wNode));
                    k_Line_Flag_State = ...
                        SinInfo.Terminal.Flag_State(SinInfo.Terminal.Element_ID == k_Line_EleID);
                    % if connected on both ends
                    if sum(k_Line_Flag_State) == 2
                        k_LineConn_logic = ...
                            strcmp(LineInfo.Name,LineConn_wNode);
                        Z_lineConn = ...
                            (LineInfo.r(k_LineConn_logic)*LineInfo.r0_r1(k_LineConn_logic) + ...
                            1i*(LineInfo.x(k_LineConn_logic)*LineInfo.x0_x1(k_LineConn_logic)))*...
                            LineInfo.l(k_LineConn_logic);
                        Y_012(Y_KAM_i,Y_KAM_j) = Y_012(Y_KAM_i,Y_KAM_j) - Z_lineConn^-1;
                    end
                end
            end                   
        end
        if mod(Y_KAM_i,3) == 2 && mod(Y_KAM_j,3) == 2 % direct component
            if Y_KAM_j == Y_KAM_i % diagonal
                LineConn_wNode = ...
                    SinInfo.Line.Name(SinInfo.Line.Node1_ID == Node_ID_i |...
                    SinInfo.Line.Node2_ID == Node_ID_i);
                for k_LineConn = 1:numel(LineConn_wNode)
                    % check if switch on
                    k_Line_EleID = LineInfo.Element_ID(strcmp(LineInfo.Name,LineConn_wNode{k_LineConn}));
                    k_Line_Flag_State = ...
                        SinInfo.Terminal.Flag_State(SinInfo.Terminal.Element_ID == k_Line_EleID);
                    % if connected on both ends
                    if sum(k_Line_Flag_State) == 2
                        k_LineConn_logic = ...
                            strcmp(LineInfo.Name,LineConn_wNode{k_LineConn});
                        Z_lineConn = ...
                            (LineInfo.r(k_LineConn_logic) + ...
                            1i*(LineInfo.x(k_LineConn_logic)))*...
                            LineInfo.l(k_LineConn_logic);
                        Y_C = LineInfo.c(k_LineConn_logic) * LineInfo.l(k_LineConn_logic)*10^-9; % nF -> F                        
                        Y_012(Y_KAM_i,Y_KAM_j) = Y_012(Y_KAM_i,Y_KAM_j) + Z_lineConn^-1 + Y_C/2;    
                    end
                end
            else % not diagonal
                % check if connected (bouth directions)
                LineConn_wNode = ...
                    SinInfo.Line.Name(...
                    (SinInfo.Line.Node1_ID == Node_ID_i & SinInfo.Line.Node2_ID == Node_ID_j) | ...
                    (SinInfo.Line.Node2_ID == Node_ID_i & SinInfo.Line.Node1_ID == Node_ID_j)); 
                if isempty(LineConn_wNode) == false
                    % check if switch on
                    k_Line_EleID = LineInfo.Element_ID(strcmp(LineInfo.Name,LineConn_wNode));
                    k_Line_Flag_State = ...
                        SinInfo.Terminal.Flag_State(SinInfo.Terminal.Element_ID == k_Line_EleID);
                    % if connected on both ends
                    if sum(k_Line_Flag_State) == 2
                        k_LineConn_logic = ...
                            strcmp(LineInfo.Name,LineConn_wNode);
                        Z_lineConn = ...
                            (LineInfo.r(k_LineConn_logic) + ...
                            1i*(LineInfo.x(k_LineConn_logic)))*...
                            LineInfo.l(k_LineConn_logic);
                        Y_012(Y_KAM_i,Y_KAM_j) = Y_012(Y_KAM_i,Y_KAM_j) - Z_lineConn^-1; 
                    end
                end
            end                   
        end     
        if mod(Y_KAM_i,3) == 0 && mod(Y_KAM_j,3) == 0 % inverse component
            if Y_KAM_j == Y_KAM_i % diagonal
                LineConn_wNode = ...
                    SinInfo.Line.Name(SinInfo.Line.Node1_ID == Node_ID_i |...
                    SinInfo.Line.Node2_ID == Node_ID_i);
                for k_LineConn = 1:numel(LineConn_wNode)
                    % check if switch on
                    k_Line_EleID = LineInfo.Element_ID(strcmp(LineInfo.Name,LineConn_wNode{k_LineConn}));
                    k_Line_Flag_State = ...
                        SinInfo.Terminal.Flag_State(SinInfo.Terminal.Element_ID == k_Line_EleID);
                    % if connected on both ends
                    if sum(k_Line_Flag_State) == 2
                        k_LineConn_logic = ...
                            strcmp(LineInfo.Name,LineConn_wNode{k_LineConn});
                        Z_lineConn = ...
                            (LineInfo.r(k_LineConn_logic) + ...
                            1i*(LineInfo.x(k_LineConn_logic)))*...
                            LineInfo.l(k_LineConn_logic);
                        Y_C = LineInfo.c(k_LineConn_logic) * LineInfo.l(k_LineConn_logic)*10^-9; % nF -> F    
                        Y_012(Y_KAM_i,Y_KAM_j) = Y_012(Y_KAM_i,Y_KAM_j) + Z_lineConn^-1 + Y_C/2; 
                    end
                end
            else % not diagonal
                % check if connected (bouth directions)
                LineConn_wNode = ...
                    SinInfo.Line.Name(...
                    (SinInfo.Line.Node1_ID == Node_ID_i & SinInfo.Line.Node2_ID == Node_ID_j) | ...
                    (SinInfo.Line.Node2_ID == Node_ID_i & SinInfo.Line.Node1_ID == Node_ID_j)); 
                if isempty(LineConn_wNode) == false
                    % check if switch on
                    k_Line_EleID = LineInfo.Element_ID(strcmp(LineInfo.Name,LineConn_wNode));
                    k_Line_Flag_State = ...
                        SinInfo.Terminal.Flag_State(SinInfo.Terminal.Element_ID == k_Line_EleID);
                    % if connected on both ends
                    if sum(k_Line_Flag_State) == 2
                        k_LineConn_logic = ...
                            strcmp(LineInfo.Name,LineConn_wNode);
                        Z_lineConn = ...
                            (LineInfo.r(k_LineConn_logic) + ...
                            1i*(LineInfo.x(k_LineConn_logic)))*...
                            LineInfo.l(k_LineConn_logic);
                        Y_012(Y_KAM_i,Y_KAM_j) = Y_012(Y_KAM_i,Y_KAM_j) - Z_lineConn^-1; 
                    end
                end
            end                   
        end            
    end
end
end