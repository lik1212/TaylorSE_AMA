function NodeRes_mod = insert_PV_PseudoValues(NodeRes_all,SinInfo,LPs,type,list_name)
%% 
%
%
%
% Author(s): P.Gassler

if nargin<4 || nargin>5
    error('Wrong argument input');
end

switch type
    case 'list'
        nb_GInfs = size(SinInfo.DCInfeeder,1);
%         nb_GLs_3p = nb_GLs / 3;
%         Node_IDs = SinInfo.Load.Node1_ID;
%         Node_IDs = unique(Node_IDs);
        LP2GL_Pv = readtable(list_name,'Delimiter',';');
        nb_GInfs_assign = size(LP2GL_Pv,1);
        num_Nodes = size(SinInfo.Node,1);
        if nb_GInfs_assign ~= nb_GInfs
            warning('Some PV Loads in the Grid will not become a Load Profil assigned!')
        end
        for k = 1 : nb_GInfs_assign
            Phase = LP2GL_Pv.Grid_Load{k}(end-1:end);
            Node_ID_k = SinInfo.DCInfeeder.Node1_ID(ismember(SinInfo.DCInfeeder.Name, LP2GL_Pv.Grid_Load(k)));
            if ~isempty(Node_ID_k)
                Node_k_Time_1_Pos = find(NodeRes_all.Node_ID(1:num_Nodes) == Node_ID_k);    % Assuming first sort according to Node_ID than ResTime
                NodePos           = Node_k_Time_1_Pos : num_Nodes : size(NodeRes_all,1);
                switch Phase
                    case 'L1'
                        NodeRes_all.    P1(NodePos) = ...
                            NodeRes_all.P1(NodePos) + ...
                            LPs.(LP2GL_Pv.Load_Profile{k}).P * 10^(-3);
                        NodeRes_all.    Q1(NodePos) = ...
                            NodeRes_all.Q1(NodePos) + ...
                            LPs.(LP2GL_Pv.Load_Profile{k}).Q * 10^(-3);
                    case 'L2'
                        NodeRes_all.    P2(NodePos) = ...
                            NodeRes_all.P2(NodePos) + ...
                            LPs.(LP2GL_Pv.Load_Profile{k}).P * 10^(-3);
                        NodeRes_all.    Q2(NodePos) = ...
                            NodeRes_all.Q2(NodePos) + ...
                            LPs.(LP2GL_Pv.Load_Profile{k}).Q * 10^(-3);
                    case 'L3'
                        NodeRes_all.    P3(NodePos) = ...
                            NodeRes_all.P3(NodePos) + ...
                            LPs.(LP2GL_Pv.Load_Profile{k}).P * 10^(-3);
                        NodeRes_all.    Q3(NodePos) = ...
                            NodeRes_all.Q3(NodePos) + ...
                            LPs.(LP2GL_Pv.Load_Profile{k}).Q * 10^(-3);
                end
            else
                warning('You want to assign a Load Profile to a Load in the Grid that doesn''t exist')
            end
        end   
    case 'random'
        
%         nb_GInfs = size(SinInfo.DCInfeeder,1);
%         nb_GInfs_3p = nb_GInfs / 3;
%         Node_IDs = SinInfo.DCInfeeder.Node1_ID;
%         Node_IDs = unique(Node_IDs);
%         
%         fieldname_LPs = fieldnames(LPs);
%         nb_LPs = numel(fieldname_LPs);
%         nb_LPs_3p = nb_LPs / 3;
%         nb_k = ceil(nb_GInfs_3p/nb_LPs_3p);
%         for k = 1 : nb_k
%             perm = ((randperm(nb_LPs_3p) - 1) * 3) + 1;
%             if k == nb_k
%                 for k_GL = 1 + (k-1)*nb_LPs_3p : nb_GInfs_3p
%                     NodeRes_all.P1(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ... 
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p)}).P * 10^(-3) * (-1);
%                     NodeRes_all.P2(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p) + 1}).P * 10^(-3) * (-1);
%                     NodeRes_all.P3(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p) + 2}).P * 10^(-3) * (-1);
%                     NodeRes_all.Q1(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p)}).Q * 10^(-3) * (-1);
%                     NodeRes_all.Q2(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p) + 1}).Q * 10^(-3) * (-1);
%                     NodeRes_all.Q3(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p) + 2}).Q * 10^(-3) * (-1);
%                 end
%             else
%                 for k_GL = 1 + (k-1)*nb_LPs_3p : nb_LPs_3p * k
%                     NodeRes_all.P1(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p)}).P * 10^(-3) * (-1);
%                     NodeRes_all.P2(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p) + 1}).P * 10^(-3) * (-1);
%                     NodeRes_all.P3(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p) + 2}).P * 10^(-3) * (-1);
%                     NodeRes_all.Q1(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p)}).Q * 10^(-3) * (-1);
%                     NodeRes_all.Q2(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p) + 1}).Q * 10^(-3) * (-1);
%                     NodeRes_all.Q3(NodeRes_all.Node_ID == Node_IDs(k_GL)) = ...
%                         LPs.(fieldname_LPs{perm(k_GL - (k-1)*nb_LPs_3p) + 2}).Q * 10^(-3) * (-1);
%                 end
%             end
%         end
                
    case 'mean_P'
        
    otherwise
        error('Not recognised distribution type');
end

NodeRes_mod = NodeRes_all;


end