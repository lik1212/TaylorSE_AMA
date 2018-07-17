function [Weight_L1, Weight_L2, Weight_L3] = Median_Neighbor_Method(List_Neighbors, NodeRes_Column_t)
%%
clearvars -except NodeRes_Column_t List_Neighbors
%%
for Strand = 1:length(fieldnames(List_Neighbors))
    List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand)) = [];
    List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand)) = [];
    List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand)) = [];
    for Neighbor_Pair = 1:size(List_Neighbors.(sprintf('Strang_%d',Strand)),1)
        Node_ID_1               = double(List_Neighbors.(sprintf('Strang_%d',Strand))(Neighbor_Pair,1));
        Node_ID_2               = double(List_Neighbors.(sprintf('Strang_%d',Strand))(Neighbor_Pair,2));
        Logic_Voltage_1         = (NodeRes_Column_t.Node_ID == Node_ID_1);
        Logic_Voltage_2         = (NodeRes_Column_t.Node_ID == Node_ID_2);
        Voltages_Node_1_L1L2L3  = NodeRes_Column_t.U_abs(Logic_Voltage_1);
        Voltages_Node_2_L1L2L3  = NodeRes_Column_t.U_abs(Logic_Voltage_2);
        
        List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand)) = [ List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand));...
            Node_ID_1, Node_ID_2, Voltages_Node_1_L1L2L3(1:3:end), Voltages_Node_2_L1L2L3(1:3:end)];
        List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand)) = [ List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand));...
            Node_ID_1, Node_ID_2, Voltages_Node_1_L1L2L3(2:3:end), Voltages_Node_2_L1L2L3(2:3:end)];
        List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand)) = [ List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand));...
            Node_ID_1, Node_ID_2, Voltages_Node_1_L1L2L3(3:3:end), Voltages_Node_2_L1L2L3(3:3:end)];
    end
end

for Strand = 1:length(fieldnames(List_Neighbors))
    Median.(sprintf('Strang_%d_L1',Strand)) = median(List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand))(:,3));
    Median.(sprintf('Strang_%d_L2',Strand)) = median(List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand))(:,3));
    Median.(sprintf('Strang_%d_L3',Strand)) = median(List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand))(:,3));
    
    Diff2Median.(sprintf('Strang_%d_L1',Strand)) = Median.(sprintf('Strang_%d_L1',Strand)) - List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand))(:,3);
    Diff2Median.(sprintf('Strang_%d_L2',Strand)) = Median.(sprintf('Strang_%d_L2',Strand)) - List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand))(:,3);
    Diff2Median.(sprintf('Strang_%d_L3',Strand)) = Median.(sprintf('Strang_%d_L3',Strand)) - List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand))(:,3);
    
    Strand_Weight_Factor.(sprintf('Strang_%d_L1',Strand)) = NodeRes_Column_t.U_abs(1,1)/Median.(sprintf('Strang_%d_L1',Strand));
    Strand_Weight_Factor.(sprintf('Strang_%d_L2',Strand)) = NodeRes_Column_t.U_abs(2,1)/Median.(sprintf('Strang_%d_L2',Strand));
    Strand_Weight_Factor.(sprintf('Strang_%d_L3',Strand)) = NodeRes_Column_t.U_abs(3,1)/Median.(sprintf('Strang_%d_L3',Strand));
    
    for Node = 1:size(List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand)),1)
        if  Node == 1
            Diff2Neighbor.(sprintf('Strang_%d_L1',Strand))(Node,2)  = List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand))(Node,4)   - List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand))(Node,3);
            Diff2Neighbor.(sprintf('Strang_%d_L2',Strand))(Node,2)  = List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand))(Node,4)   - List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand))(Node,3);
            Diff2Neighbor.(sprintf('Strang_%d_L3',Strand))(Node,2)  = List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand))(Node,4)   - List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand))(Node,3);
            Absolute_Min.(sprintf('Strang_%d_L1',Strand))(Node,1)   = min(complex(Diff2Neighbor.(sprintf('Strang_%d_L1',Strand))(Node,2)));
            Absolute_Min.(sprintf('Strang_%d_L2',Strand))(Node,1)   = min(complex(Diff2Neighbor.(sprintf('Strang_%d_L2',Strand))(Node,2)));
            Absolute_Min.(sprintf('Strang_%d_L3',Strand))(Node,1)   = min(complex(Diff2Neighbor.(sprintf('Strang_%d_L3',Strand))(Node,2)));
            Weight.(sprintf('Strang_%d_L1',Strand))(Node,1)         = (Median.(sprintf('Strang_%d_L1',Strand)) - List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand))(Node,3)) + Absolute_Min.(sprintf('Strang_%d_L1',Strand))(Node,1);
            Weight.(sprintf('Strang_%d_L2',Strand))(Node,1)         = (Median.(sprintf('Strang_%d_L2',Strand)) - List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand))(Node,3)) + Absolute_Min.(sprintf('Strang_%d_L2',Strand))(Node,1);
            Weight.(sprintf('Strang_%d_L3',Strand))(Node,1)         = (Median.(sprintf('Strang_%d_L3',Strand)) - List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand))(Node,3)) + Absolute_Min.(sprintf('Strang_%d_L3',Strand))(Node,1);
        else
            Diff2Neighbor.(sprintf('Strang_%d_L1',Strand))(Node,1)  = List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand))(Node-1,3) - List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand))(Node,3);
            Diff2Neighbor.(sprintf('Strang_%d_L2',Strand))(Node,1)  = List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand))(Node-1,3) - List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand))(Node,3);
            Diff2Neighbor.(sprintf('Strang_%d_L3',Strand))(Node,1)  = List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand))(Node-1,3) - List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand))(Node,3);
            Diff2Neighbor.(sprintf('Strang_%d_L1',Strand))(Node,2)  = List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand))(Node,4)   - List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand))(Node,3);
            Diff2Neighbor.(sprintf('Strang_%d_L2',Strand))(Node,2)  = List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand))(Node,4)   - List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand))(Node,3);
            Diff2Neighbor.(sprintf('Strang_%d_L3',Strand))(Node,2)  = List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand))(Node,4)   - List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand))(Node,3);
            Absolute_Min.(sprintf('Strang_%d_L1',Strand))(Node,1)   = min(complex([Diff2Neighbor.(sprintf('Strang_%d_L1',Strand))(Node,1),Diff2Neighbor.(sprintf('Strang_%d_L1',Strand))(Node,2)]));
            Absolute_Min.(sprintf('Strang_%d_L2',Strand))(Node,1)   = min(complex([Diff2Neighbor.(sprintf('Strang_%d_L2',Strand))(Node,1),Diff2Neighbor.(sprintf('Strang_%d_L2',Strand))(Node,2)]));
            Absolute_Min.(sprintf('Strang_%d_L3',Strand))(Node,1)   = min(complex([Diff2Neighbor.(sprintf('Strang_%d_L3',Strand))(Node,1),Diff2Neighbor.(sprintf('Strang_%d_L3',Strand))(Node,2)]));
            Weight.(sprintf('Strang_%d_L1',Strand))(Node,1)         = (Median.(sprintf('Strang_%d_L1',Strand)) - List_Neighbors_Voltages.(sprintf('Strang_%d_L1',Strand))(Node,3)) + Absolute_Min.(sprintf('Strang_%d_L1',Strand))(Node,1);
            Weight.(sprintf('Strang_%d_L2',Strand))(Node,1)         = (Median.(sprintf('Strang_%d_L2',Strand)) - List_Neighbors_Voltages.(sprintf('Strang_%d_L2',Strand))(Node,3)) + Absolute_Min.(sprintf('Strang_%d_L2',Strand))(Node,1);
            Weight.(sprintf('Strang_%d_L3',Strand))(Node,1)         = (Median.(sprintf('Strang_%d_L3',Strand)) - List_Neighbors_Voltages.(sprintf('Strang_%d_L3',Strand))(Node,3)) + Absolute_Min.(sprintf('Strang_%d_L3',Strand))(Node,1);
        end
    end
end

Weight_L1 = [];
Weight_L2 = [];
Weight_L3 = [];
for Strand = 1:length(fieldnames(List_Neighbors))
    Weight_L1 = [Weight_L1; [double(List_Neighbors.(sprintf('Strang_%d',Strand))(:,1)), Weight.(sprintf('Strang_%d_L1',Strand))]];
    Weight_L2 = [Weight_L2; [double(List_Neighbors.(sprintf('Strang_%d',Strand))(:,1)), Weight.(sprintf('Strang_%d_L2',Strand))]];
    Weight_L3 = [Weight_L3; [double(List_Neighbors.(sprintf('Strang_%d',Strand))(:,1)), Weight.(sprintf('Strang_%d_L3',Strand))]];
end
[~, sort_index] = unique(Weight_L1(:,1));
Weight_L1       = Weight_L1(sort_index,:);
[~, sort_index] = unique(Weight_L2(:,1));
Weight_L2       = Weight_L2(sort_index,:);
[~, sort_index] = unique(Weight_L3(:,1));
Weight_L3       = Weight_L3(sort_index,:);
[~, sort_index] = sort(Weight_L1(:,2));
Weight_L1       = Weight_L1(sort_index,:);
[~, sort_index] = sort(Weight_L2(:,2));
Weight_L2       = Weight_L2(sort_index,:);
[~, sort_index] = sort(Weight_L3(:,2));
Weight_L3       = Weight_L3(sort_index,:);