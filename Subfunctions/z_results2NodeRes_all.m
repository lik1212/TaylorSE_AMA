function SimData = z_results2NodeRes_all(SimResults,SinInfo,nb_instants,num_PNM_Types,num_PMN___max,num_Nodes)
%
%   TODO
%
% Author(s): P.Gassler, R. Brandalik

SinInfo.Node = sortrows(SinInfo.Node,'Node_ID');
Node_IDs     = SinInfo.Node.Node_ID;
num_Phase    = 3;

U1_pos   = false(num_PMN___max * num_PNM_Types, 1);
U2_pos   = false(num_PMN___max * num_PNM_Types, 1);
U3_pos   = false(num_PMN___max * num_PNM_Types, 1);
phi1_pos = false(num_PMN___max * num_PNM_Types, 1);
phi2_pos = false(num_PMN___max * num_PNM_Types, 1);
phi3_pos = false(num_PMN___max * num_PNM_Types, 1);
P1_pos   = false(num_PMN___max * num_PNM_Types, 1);
P2_pos   = false(num_PMN___max * num_PNM_Types, 1);
P3_pos   = false(num_PMN___max * num_PNM_Types, 1);
Q1_pos   = false(num_PMN___max * num_PNM_Types, 1);
Q2_pos   = false(num_PMN___max * num_PNM_Types, 1);
Q3_pos   = false(num_PMN___max * num_PNM_Types, 1);

schema_L1 = repmat(logical([1; 0; 0]),num_PMN___max/num_Phase,1);
schema_L2 = repmat(logical([0; 1; 0]),num_PMN___max/num_Phase,1);
schema_L3 = repmat(logical([0; 0; 1]),num_PMN___max/num_Phase,1);

U1_pos  (1                     : num_PMN___max    ) = schema_L1;
U2_pos  (1                     : num_PMN___max    ) = schema_L2;
U3_pos  (1                     : num_PMN___max    ) = schema_L3;
phi1_pos(num_PMN___max + 1     : num_PMN___max * 2) = schema_L1;
phi2_pos(num_PMN___max + 1     : num_PMN___max * 2) = schema_L2;
phi3_pos(num_PMN___max + 1     : num_PMN___max * 2) = schema_L3;
P1_pos  (num_PMN___max * 2 + 1 : num_PMN___max * 3) = schema_L1;
P2_pos  (num_PMN___max * 2 + 1 : num_PMN___max * 3) = schema_L2;
P3_pos  (num_PMN___max * 2 + 1 : num_PMN___max * 3) = schema_L3;
Q1_pos  (num_PMN___max * 3 + 1 : num_PMN___max * 4) = schema_L1;
Q2_pos  (num_PMN___max * 3 + 1 : num_PMN___max * 4) = schema_L2;
Q3_pos  (num_PMN___max * 3 + 1 : num_PMN___max * 4) = schema_L3;

% NodeRes_all_waitbar = waitbar(0,'Generating NodeRes_all','Name','AMA State Estimation','CreateCancelBtn',...
%     'setappdata(gcbf,''canceling'',1)');
% setappdata(NodeRes_all_waitbar,'canceling',0);

SimData = zeros(num_Nodes * nb_instants,19);

SimData(:,19) = repelem(1:nb_instants,1          ,num_Nodes);
SimData(:, 1) = repmat (Node_IDs     ,nb_instants,        1);
SimData(:, 2) = reshape(SimResults(U1_pos,:),[],1) * 10^-3;
SimData(:, 7) = reshape(SimResults(U2_pos,:),[],1) * 10^-3;
SimData(:,12) = reshape(SimResults(U3_pos,:),[],1) * 10^-3;
SimData(:, 3) = rad2deg(reshape(SimResults(phi1_pos,:),[],1));
SimData(:, 8) = rad2deg(reshape(SimResults(phi2_pos,:),[],1));
SimData(:,13) = rad2deg(reshape(SimResults(phi3_pos,:),[],1));
SimData(:, 4) = reshape(SimResults(P1_pos,:),[],1) * 10^-6;
SimData(:, 9) = reshape(SimResults(P2_pos,:),[],1) * 10^-6;
SimData(:,14) = reshape(SimResults(P3_pos,:),[],1) * 10^-6;
SimData(:, 5) = reshape(SimResults(Q1_pos,:),[],1) * 10^-6;
SimData(:,10) = reshape(SimResults(Q2_pos,:),[],1) * 10^-6;
SimData(:,15) = reshape(SimResults(Q3_pos,:),[],1) * 10^-6;

% calculate S with P and Q
SimData(:, 6) = sqrt(SimData(:, 5).^2 + SimData(:, 4).^2 );
SimData(:,11) = sqrt(SimData(:,10).^2 + SimData(:, 9).^2 );
SimData(:,16) = sqrt(SimData(:,15).^2 + SimData(:,14).^2 );

SimData = array2table(SimData);
SimData.Properties.VariableNames = {'Node_ID',...
    'U1','phi1','P1','Q1','S1',...
    'U2','phi2','P2','Q2','S2',...
    'U3','phi3','P3','Q3','S3',...
    'Ue','S','ResTime'};

% updateWaitbar('delete',NodeRes_all_waitbar);
end