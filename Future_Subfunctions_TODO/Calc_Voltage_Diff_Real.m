function [List_VoltDiff_real_L1L2L3] = Calc_Voltage_Diff_Real(List_Node2Node_real, NodeRes_Column_t)
%%  
    List_VoltDiff_real_L1L2L3 = struct;

    for Strand = 1:length(fieldnames(List_Node2Node_real))
        List_VoltDiff_real_L1L2L3.(sprintf('Strang_%d',Strand)) = [];
        for Line = 1:size(List_Node2Node_real.(sprintf('Strang_%d',Strand)),1)
            Node_ID_1       = double(List_Node2Node_real.(sprintf('Strang_%d',Strand))(Line,1));
            Node_ID_2       = double(List_Node2Node_real.(sprintf('Strang_%d',Strand))(Line,2));
            Logic_Voltage_1 = (NodeRes_Column_t.Node_ID == Node_ID_1);
            Logic_Voltage_2 = (NodeRes_Column_t.Node_ID == Node_ID_2);

            List_VoltDiff_real_L1L2L3.(sprintf('Strang_%d',Strand)) = [ List_VoltDiff_real_L1L2L3.(sprintf('Strang_%d',Strand));...
                                                                      [[Node_ID_1; Node_ID_1; Node_ID_1], [Node_ID_2; Node_ID_2; Node_ID_2],...
                                                                       [NodeRes_Column_t.U_abs(Logic_Voltage_1), NodeRes_Column_t.U_abs(Logic_Voltage_2)],...
                                                                        NodeRes_Column_t.U_abs(Logic_Voltage_1)-NodeRes_Column_t.U_abs(Logic_Voltage_2)]];
        end;

    end;

end