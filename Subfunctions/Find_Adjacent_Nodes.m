function [List_Node2Node_real] = Find_Adjacent_Nodes(SincalModel, logic_Node_z_real, start_nodes_name, end_nodes_name, middle_nodes_name)
% clearvars -except SincalModel logic_Node_z_real

%%  Function finds adjacent nodes with real measurements and creates a list which contains all the adjecent nodes
start_nodes_name_ID  = table(start_nodes_name,  zeros(size(start_nodes_name,1),1),  'VariableNames',{'Name', 'Node_ID'});
end_nodes_name_ID    = table(end_nodes_name,    zeros(size(end_nodes_name,1),1),    'VariableNames',{'Name', 'Node_ID'});
middle_nodes_name_ID = table(middle_nodes_name, zeros(size(middle_nodes_name,1),1), 'VariableNames',{'Name', 'Node_ID'});

%%
for control_elimination = 1:size(start_nodes_name_ID,1)
    row                         = strmatch(start_nodes_name_ID{control_elimination,1}, SincalModel.Info.Node.Name);
    start_nodes_name_ID{control_elimination,2}    = SincalModel.Info.Node.Node_ID(row,1);
end
start_nodes_name_ID = sortrows(start_nodes_name_ID,'Node_ID','ascend');

for control_elimination = 1:size(end_nodes_name_ID,1)
    row                         = strmatch(end_nodes_name_ID{control_elimination,1}, SincalModel.Info.Node.Name);
    end_nodes_name_ID{control_elimination,2}      = SincalModel.Info.Node.Node_ID(row,1);
end
end_nodes_name_ID   = sortrows(end_nodes_name_ID,'Node_ID','ascend');

for control_elimination = 1:size(middle_nodes_name_ID,1)
    row                         = strmatch(middle_nodes_name_ID{control_elimination,1}, SincalModel.Info.Node.Name);
    middle_nodes_name_ID{control_elimination,2}   = SincalModel.Info.Node.Node_ID(row,1);
end
middle_nodes_name_ID   = sortrows(middle_nodes_name_ID,'Node_ID','ascend');

%%
Node_ID_real        = SincalModel.Info.Node.Node_ID(logic_Node_z_real);
Node_ID_real        = sort(Node_ID_real, 'ascend');

%%  Find open circuit breaker, so lines which are opened can be eliminated
open_line_name      = SincalModel.Info.Terminal.Element_ID(SincalModel.Info.Terminal.Flag_State==0);
logic_open_line     = true(size(SincalModel.Info.Line.Element_ID,1),1);

for num_open_line = 1:size(open_line_name,1)
    logic_open_line(SincalModel.Info.Line.Element_ID == open_line_name(num_open_line),1) = false;
end

%%
Line_Node_ID_all            = table(zeros(size(logic_open_line,1)-size(open_line_name,1),1), zeros(size(logic_open_line,1)-size(open_line_name,1),1), 'VariableNames',{'Node1_ID', 'Node2_ID'});
Line_Node_ID_all.Node1_ID   = SincalModel.Info.Line.Node1_ID(logic_open_line);
Line_Node_ID_all.Node2_ID   = SincalModel.Info.Line.Node2_ID(logic_open_line);

%%
for start_node = 1:size(start_nodes_name_ID,1)
    current_Node_ID     = start_nodes_name_ID.Node_ID(start_node);
    Line_Node_ID        = table( 0,  0, 'VariableNames',{'Node1_ID', 'Node2_ID'});
    List_Line           = table([], [], 'VariableNames',{'Node1_ID', 'Node2_ID'});
    List_Elimination    = [];
    counter             = 0;
    
    while   all(current_Node_ID ~= end_nodes_name_ID.Node_ID(:))
        counter                 = counter + 1;
        
        logic_Line_Node_ID_1    = (Line_Node_ID_all.Node1_ID == current_Node_ID);
        logic_Line_Node_ID_2    = (Line_Node_ID_all.Node2_ID == current_Node_ID);
        
        Line_Node_ID            = [Line_Node_ID_all(logic_Line_Node_ID_1,:); Line_Node_ID_all(logic_Line_Node_ID_2,:)];
        
        control_elimination = 0;
        size_Line_Node_ID = size(Line_Node_ID,1);
        while control_elimination ~= size_Line_Node_ID
            control_elimination = control_elimination+1;
            if  ~isempty(List_Elimination) && any(any(Line_Node_ID{control_elimination,:} == List_Elimination))
                Line_Node_ID(control_elimination,:)   = [];
                size_Line_Node_ID                     = size(Line_Node_ID,1);
                control_elimination                   = control_elimination-1;
            end
        end
        
        for num_Line_Node_ID = 1:size(Line_Node_ID,1)
            if  Line_Node_ID.Node1_ID(num_Line_Node_ID) ~= current_Node_ID
                Line_Node_ID(num_Line_Node_ID,:) = [Line_Node_ID(num_Line_Node_ID,2), Line_Node_ID(num_Line_Node_ID,1)];
            end
        end
        
        if ~isempty(Line_Node_ID)
            %%
            List_Elimination    = [List_Elimination; Line_Node_ID.Node1_ID(1)];
        end
        
        if any(Line_Node_ID.Node1_ID(:) == 237 & Line_Node_ID.Node2_ID(:) == 305) || any(Line_Node_ID.Node1_ID(:) == 237 & Line_Node_ID.Node2_ID(:) == 238)
            Line_Node_ID((Line_Node_ID.Node1_ID(:) == 237 & Line_Node_ID.Node2_ID(:) == 305),:) = [];
            Line_Node_ID((Line_Node_ID.Node1_ID(:) == 237 & Line_Node_ID.Node2_ID(:) == 238),:) = [];
        end
        
        List_Line               = [List_Line; Line_Node_ID];
        current_Node_ID         = List_Line.Node2_ID(counter);
    end
    
    logic_Node2_ID_real = ismember(List_Line.Node2_ID, Node_ID_real);
    
    List_Node2Node_real.(sprintf('Strang_%d',start_node)) = [List_Line.Node1_ID(1,1);List_Line.Node2_ID(logic_Node2_ID_real)];
    List_Node2Node_real.(sprintf('Strang_%d',start_node)) = [List_Node2Node_real.(sprintf('Strang_%d',start_node))(1:end-1,1), List_Node2Node_real.(sprintf('Strang_%d',start_node))(2:end,1)];
    
end;
end
