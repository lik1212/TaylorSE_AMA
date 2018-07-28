function [z_all_data, z_all_flag] = GetVector_z(Inputs, MeasurPos)
%GETVECTOR_Z Adjust the Sincal Results to a measurement vector z
%   For information about z_all_flag check Description_Of_Inputs.pdf

%% Load Sincal Results

load([Inputs.LF_Res_Path, Inputs.  NodeRes_Name]  , 'NodeRes_all');
load([Inputs.LF_Res_Path, Inputs.BranchRes_Name], 'BranchRes_all'); % TODO: Yet only NodeResult used

%% Number of measurements & time instances 

num_z_meas_inst = sum(sum((MeasurPos{:, 3:end} == 1))); % Real    value
num_z_pseu_inst = sum(sum((MeasurPos{:, 3:end} == 2))); % Pseudo  value
num_z_virt_inst = sum(sum((MeasurPos{:, 3:end} == 3))); % Virtual value
num_z_all_inst  = num_z_meas_inst + num_z_pseu_inst + num_z_virt_inst;
num_inst        = max(NodeRes_all.ResTime) - min(NodeRes_all.ResTime) + 1;

%% Initial output

z_all_data = zeros(num_z_all_inst, num_inst);
z_all_flag = array2table(NaN(num_z_all_inst, 6), 'VariableNames',...
    {'Node1_ID','Node2_ID','Phase','Meas_Type','Accur_Type','Sigma'});

%% Translator from MeasurPos to z_all_data

trans_z = cell2table({...
    'U1'   , 1, 1 , 0.1     ;...
    'U2'   , 2, 1 , 0.1     ;...
    'U3'   , 3, 1 , 0.1     ;...
    'phi1' , 1, 2 , 0.01    ;...
    'phi2' , 2, 2 , 0.01    ;...
    'phi3' , 3, 2 , 0.01    ;...
    'P1'   , 1, 3 , 1       ;...
    'P2'   , 2, 3 , 1       ;...
    'P3'   , 3, 3 , 1       ;...
    'Q1'   , 1, 4 , 1       ;...
    'Q2'   , 2, 4 , 1       ;...
    'Q3'   , 3, 4 , 1       ;...
    'S1'   , 1, 5 , NaN     ;...
    'S2'   , 2, 5 , NaN     ;...
    'S3'   , 3, 5 , NaN     ;...
    'I1'   , 1, 6 , NaN     ;...
    'I2'   , 2, 6 , NaN     ;...
    'I3'   , 3, 6 , NaN      ...
    },'VariableNames',...
    {'ColName', 'Phase', 'Meas_Type', 'Sigma'}); 

%% Fill z_all_data

pos_z_1   = 1;
for k_Col = 1 : size(trans_z, 1)
    for k_Obj = 1 : size(MeasurPos, 1)
        if ~isnan(MeasurPos.(trans_z.ColName{k_Col})(k_Obj))
            if isnan(MeasurPos.Node2_ID(k_Obj)) % NodeRes
                new_values = NodeRes_all.(trans_z.ColName{k_Col})...
                    (NodeRes_all.Node_ID == MeasurPos.Node1_ID(k_Obj)); % over all time instances
                if ismember(trans_z.ColName{k_Col}, {'U1', 'U2', 'U3'})
                    new_values = new_values * 10^3; % kV -> V
                end
                if ismember(trans_z.ColName{k_Col}, {'phi1', 'phi2', 'phi3'})
                    new_values = deg2rad(new_values); % deg -> rad
                end      
                if ismember(trans_z.ColName{k_Col}, {'P1', 'P2', 'P3', 'Q1', 'Q2', 'Q3'})                
                    new_values = new_values * 10^6; % MW -> W
                end
                z_all_data           (pos_z_1,:) = new_values;
                z_all_flag.Node1_ID  (pos_z_1)   = MeasurPos.Node1_ID(k_Obj);
                z_all_flag.Node2_ID  (pos_z_1)   = NaN;
                z_all_flag.Phase     (pos_z_1)   = trans_z.Phase     (k_Col);
                z_all_flag.Meas_Type (pos_z_1)   = trans_z.Meas_Type (k_Col);
                z_all_flag.Accur_Type(pos_z_1)   = MeasurPos.(trans_z.ColName{k_Col})(k_Obj);
                if z_all_flag.Accur_Type(pos_z_1) == 1 % Real measurements
                    z_all_flag.Sigma (pos_z_1) = trans_z.Sigma     (k_Col);
                end
                if z_all_flag.Accur_Type(pos_z_1) == 3 % Virtual measurements
                    z_all_flag.Sigma (pos_z_1) = 0;
                end
                pos_z_1 = pos_z_1 + 1;
            else
                error('BranchRes not yet implemented'); % TODO
            end 
        end
    end
end


