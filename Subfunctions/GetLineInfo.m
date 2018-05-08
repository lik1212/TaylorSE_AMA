function LineInfo = GetLineInfo(Inputs)
%GETLINEINFO Summary of this function goes here
%   Detailed explanation goes here
%% Load SinInfo

if Inputs.with_TR == false
        SimDetails         = [Inputs.LF_Res_Path, Inputs.Simulation_Details                             ];
else;   SimDetails         = [Inputs.LF_Res_Path, Inputs.Simulation_Details(1 : end - 4)   ,'_wo_TR.mat'];
end

load(SimDetails ,'SimDetails')

SinInfo = SimDetails.SinInfo;

LineInfoWanted = {'r','x','c','r0_r1','x0_x1','c0','l'};
LineInfo = Mat2Sin_GetLineInfo(SinInfo,LineInfoWanted,Inputs.Grid_Name,Inputs.Grid_Path); % TODO, replace with the SQL function!

Col2Add = {'Terminal1_ID', 'Node1_ID', 'Flag_State1', 'Terminal2_ID', 'Node2_ID', 'Flag_State2'};
LineInfo{:, Col2Add } = NaN;    % Initial

for k_Line = 1 : size(LineInfo, 1)
    LineInfo{k_Line, {'Terminal1_ID', 'Terminal2_ID', 'Node1_ID', 'Node2_ID'}} = ...
        SinInfo.Line{SinInfo.Line.Element_ID == LineInfo.Element_ID(k_Line), ({'Terminal1_ID', 'Terminal2_ID', 'Node1_ID', 'Node2_ID'})};
    LineInfo.Flag_State1(k_Line) = ...
        SinInfo.Terminal.Flag_State(SinInfo.Terminal.Terminal_ID == LineInfo.Terminal1_ID(k_Line));
    LineInfo.Flag_State2(k_Line) = ...
        SinInfo.Terminal.Flag_State(SinInfo.Terminal.Terminal_ID == LineInfo.Terminal2_ID(k_Line));
    
end
LineInfo = movevars(LineInfo, Col2Add, 'Before', 'r');
LineInfo = removevars(LineInfo, {'Element_ID', 'Terminal1_ID', 'Terminal2_ID'});

end

