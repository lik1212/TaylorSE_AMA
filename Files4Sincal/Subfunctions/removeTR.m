function removeTR(Inputs)
%REMOVETR Remove the transformer (TR) of a low voltage grid in Sincal and
%keep the results in right order
%   The State Estimation as it is right now cannot work with TR.
%   For this reason the low voltage TR will be removed and the results has
%   to be adjusted.

%% Read in SinInfo from Inputs

SimDetails = [Inputs.LF_Res_Path, Inputs.Simulation_Details];
load(SimDetails, 'SimDetails')
SinInfo = SimDetails.SinInfo;

%% Move results from TR to Infeeder and then remove TR

if isfield(SinInfo, 'TwoWindingTransformer') % If TR occur
    NodeRes_PathName   = [Inputs.LF_Res_Path, Inputs.NodeRes_Name  ];   % Path of Node   Results
    BranchRes_PathName = [Inputs.LF_Res_Path, Inputs.BranchRes_Name];   % Path of Branch Results
    % Load Results
    load(NodeRes_PathName  ,'NodeRes_all'  );
    load(BranchRes_PathName,'BranchRes_all'); 
    % Remove initial infeeder from Node Results
    NodeRes_all(NodeRes_all.Node_ID == SinInfo.Infeeder.Node1_ID, :) = []; %#ok, will be saved
    % Save Node IDs of initial and new infeeder & TR
    Node_ID_Infeeder_old = SinInfo.Infeeder             {:, {'Node1_ID'            }};
    Node_IDs_TR          = SinInfo.TwoWindingTransformer{:, {'Node1_ID', 'Node2_ID'}};
    Node_ID_Infeeder_new = setdiff(Node_IDs_TR, Node_ID_Infeeder_old);
    % Variables to adjust in NodeRes
    VarNames = {'P1', 'P2', 'P3', 'Q1', 'Q2', 'Q3', 'S1', 'S2', 'S3'}; 
    % Over all variables
    for k_Var = 1 : numel(VarNames) % Set BranchRes of TR to NodeRes of Infeeder, Node IDs of TR are reversed (Node2 -> Node1)
        NodeRes_all.(VarNames{k_Var})(NodeRes_all.Node_ID == Node_ID_Infeeder_new) = ...
            BranchRes_all.(VarNames{k_Var})(ismember(BranchRes_all{:, {'Node2_ID', 'Node1_ID'}}, Node_IDs_TR, 'rows')); %#ok, will be saved
    end
    NodeRes_all.S(NodeRes_all.Node_ID == Node_ID_Infeeder_new) = NaN; % S do not occur in BranchRes so set it to NaN
    % Remove BranchRes of TR
    BranchRes_all(ismember(BranchRes_all{:, {'Node1_ID', 'Node2_ID'}}, Node_IDs_TR, 'rows'),:) = [];
    BranchRes_all(ismember(BranchRes_all{:, {'Node2_ID', 'Node1_ID'}}, Node_IDs_TR, 'rows'),:) = []; %#ok, will be saved   
    % In the next section adjust SinInfo to be correct again
    Element_ID_TR       = SinInfo.TwoWindingTransformer.Element_ID;
    Element_ID_Infeeder = SinInfo.Infeeder.Element_ID;    
    % Adjust Terminal in SinInfo
    SinInfo.Terminal           (SinInfo.Terminal.Node_ID    == Node_ID_Infeeder_old, :) = [];                   % Delete Terminal of old Dode
    SinInfo.Terminal.Element_ID(SinInfo.Terminal.Element_ID == Element_ID_TR       , :) = Element_ID_Infeeder;  % The Infeeder is now connected to the old TR Node
    % Adjust Node     in SinInfo
    SinInfo.Node               (SinInfo.Node.Node_ID        == Node_ID_Infeeder_old, :) = [];                   % Delete old Node
    % Adjust Element  in SinInfo
    SinInfo.Element            (SinInfo.Element.Element_ID  == Element_ID_TR       , :) = [];
    SinInfo.Element.Node1_ID   (SinInfo.Element.Element_ID  == Element_ID_Infeeder , :) = Node_ID_Infeeder_new;
    % Adjust Infeeder in SinInfo
    SinInfo.Infeeder.Node1_ID  (SinInfo.Infeeder.Element_ID  == Element_ID_Infeeder, :) = Node_ID_Infeeder_new;
    % Delete TwoWindingTransformer from SinInfo
    SinInfo = rmfield(SinInfo,'TwoWindingTransformer');
    % Save new SinInfo to SimDetails
    SimDetails.SinInfo = SinInfo;
end

%% Save the new data

save([Inputs.LF_Res_Path, Inputs.      NodeRes_Name(1 : end - 4) ,'_wo_TR.mat'], 'NodeRes_all'  )
save([Inputs.LF_Res_Path, Inputs.    BranchRes_Name(1 : end - 4) ,'_wo_TR.mat'], 'BranchRes_all')
save([Inputs.LF_Res_Path, Inputs.Simulation_Details(1 : end - 4) ,'_wo_TR.mat'], 'SimDetails'   )

