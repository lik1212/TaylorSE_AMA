function removeTR(Inputs)
%REMOVETR Summary of this function goes here
%   Detailed explanation goes here

% SincalModel.Name = Inputs.Grid_Name;    % Get sincal model Name
% SincalModel.Info = ...
%     Mat2Sin_GetSinInfo(SincalModel.Name, Inputs.Grid_Path);

%% Initial matrix of measurements


    SimDetails         = [Inputs.LF_Res_Path, Inputs.Simulation_Details];

    load(SimDetails       ,'SimDetails')
      
    SinInfo = SimDetails.SinInfo;
    
if isfield(SinInfo, 'TwoWindingTransformer')
    NodeRes_PathName   = [Inputs.LF_Res_Path, Inputs.NodeRes_Name   ];
    BranchRes_PathName = [Inputs.LF_Res_Path, Inputs.BranchRes_Name];
        
    load(NodeRes_PathName  ,'NodeRes_all'  );
    load(BranchRes_PathName,'BranchRes_all');
    % remove TR from Results
    NodeRes_all(NodeRes_all.Node_ID == SinInfo.Infeeder.Node1_ID, :) = [];
    
    Node_ID_Infeeder = SinInfo.Infeeder             {:, {'Node1_ID'            }};
    Node_IDs_TR      = SinInfo.TwoWindingTransformer{:, {'Node1_ID', 'Node2_ID'}};
    
    Element_ID_Infeeder = SinInfo.Infeeder.Element_ID;
    Element_ID_TR       = SinInfo.TwoWindingTransformer.Element_ID;
    
    Terminal_ID_Infeeder = SinInfo.Terminal.Terminal_ID(SinInfo.Terminal.Element_ID == Element_ID_Infeeder);
%     Terminal_ID_TR       = SinInfo.TwoWindingTransformer{:, {'Terminal1_ID', 'Terminal2_ID'}};
    
    Node_IDs_replace = [setdiff(Node_IDs_TR, Node_ID_Infeeder), Node_ID_Infeeder];
    
    VarNames = {'P1', 'P2', 'P3', 'Q1', 'Q2', 'Q3', 'S1', 'S2', 'S3'};
    
    for k_Var = 1 : numel(VarNames)
        NodeRes_all.(VarNames{k_Var})(NodeRes_all.Node_ID == setdiff(Node_IDs_TR, Node_ID_Infeeder)) = ...
            BranchRes_all.(VarNames{k_Var})(ismember(BranchRes_all{:, {'Node1_ID', 'Node2_ID'}}, Node_IDs_replace, 'rows'));
    end
    NodeRes_all.S(NodeRes_all.Node_ID == setdiff(Node_IDs_TR, Node_ID_Infeeder)) = NaN;
    
    BranchRes_all(ismember(BranchRes_all{:, {'Node1_ID', 'Node2_ID'}}, Node_IDs_replace, 'rows'),:) = [];
    BranchRes_all(ismember(BranchRes_all{:, {'Node2_ID', 'Node1_ID'}}, Node_IDs_replace, 'rows'),:) = [];
    
    SinInfo = rmfield(SinInfo,'TwoWindingTransformer');
    
    SinInfo.Element(SinInfo.Element.Element_ID == Element_ID_TR, :) = [];
    SinInfo.Element.Node1_ID(SinInfo.Element.Element_ID == Element_ID_Infeeder) = setdiff(Node_IDs_TR, Node_ID_Infeeder);  
    SinInfo.Element.Element_ID(SinInfo.Element.Element_ID == Element_ID_Infeeder) = Element_ID_TR;    
    
    SinInfo.Infeeder.Node1_ID   =  setdiff(Node_IDs_TR, Node_ID_Infeeder);  
    SinInfo.Infeeder.Element_ID = Element_ID_TR;    
    
    SinInfo.Terminal(SinInfo.Terminal.Node_ID == Node_ID_Infeeder, :) = [];
    SinInfo.Terminal.Terminal_ID(SinInfo.Terminal.Element_ID == Element_ID_TR) = Terminal_ID_Infeeder;
%     SinInfo.Infeeder.Element_ID = Element_ID_TR;
    % TU jos trebam Terminal_ID popraviti;
    
    SinInfo.Node(SinInfo.Node.Node_ID == Node_ID_Infeeder, :) = [];
    
    SimDetails.SinInfo = SinInfo;
end
    save([Inputs.LF_Res_Path, Inputs.NodeRes_Name(1 : end - 4) ,'_wo_TR.mat'],'NodeRes_all')
    save([Inputs.LF_Res_Path, Inputs.BranchRes_Name(1 : end - 4) '_wo_TR.mat'],'BranchRes_all')
    save([Inputs.LF_Res_Path, Inputs.Simulation_Details(1 : end - 4) ,'_wo_TR.mat'],'SimDetails')

