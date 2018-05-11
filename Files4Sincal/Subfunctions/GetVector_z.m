function [z_all_data, z_all_flag] = GetVector_z(Inputs, MeasurPos)
%GETVECTOR_Z Adjust the Sincal Results to a measurement vector z
%   TOOD
%%

if Inputs.with_TR == false
    NodeRes_PathName   = [Inputs.LF_Res_Path, Inputs.NodeRes_Name   ];
    BranchRes_PathName = [Inputs.LF_Res_Path, Inputs .BranchRes_Name];
else
    NodeRes_PathName   = [Inputs.LF_Res_Path, Inputs.NodeRes_Name(1 : end - 4)   ,'_wo_TR.mat'];
    BranchRes_PathName = [Inputs.LF_Res_Path, Inputs .BranchRes_Name(1 : end - 4),'_wo_TR.mat'];
end

% if Inputs.with_TR == false
load(NodeRes_PathName  ,'NodeRes_all'  );
load(BranchRes_PathName,'BranchRes_all');

num_z_meas_inst = sum(sum((MeasurPos{:,3:end} == 1)));
num_z_pseu_inst = sum(sum((MeasurPos{:,3:end} == 2)));
num_z_virt_inst = sum(sum((MeasurPos{:,3:end} == 3)));

num_z_all_inst  = num_z_meas_inst + num_z_pseu_inst + num_z_virt_inst;

num_inst  = max(NodeRes_all.ResTime) - min(NodeRes_all.ResTime) + 1;
% num_z_all = num_z_all_inst * num_inst;

z_all_data = zeros(num_z_all_inst, num_inst);
z_all_flag = array2table(NaN(num_z_all_inst, 6), 'VariableNames',...
    {'Node1_ID','Node2_ID','Phase','Meas_Type','Accur_Type','Sigma'});

%% NodeRes for U, phi, P, Q, S and BranchRes for P, Q, S and I and for all phases
trans_z = cell2table({...
    'U1'   , 1, 1 , 0.1;...
    'U2'   , 2, 1 , 0.1;...
    'U3'   , 3, 1 , 0.1;...
    'phi1' , 1, 2 , 0.01;...
    'phi2' , 2, 2 , 0.01;...
    'phi3' , 3, 2 , 0.01;...
    'P1'   , 1, 3 , 1;...
    'P2'   , 2, 3 , 1;...
    'P3'   , 3, 3 , 1;...
    'Q1'   , 1, 4 , 1;...
    'Q2'   , 2, 4 , 1;...
    'Q3'   , 3, 4 , 1;...
    'S1'   , 1, 5 , NaN;...
    'S2'   , 2, 5 , NaN;...
    'S3'   , 3, 5 , NaN;...
    'I1'   , 1, 6 , NaN;...
    'I2'   , 2, 6 , NaN;...
    'I3'   , 3, 6 , NaN ...
    },'VariableNames',...
    {'ColName', 'Phase', 'Meas_Type', 'Sigma'}); % Translator from MeasurPos to z_all_data

%% Fill z_all_data

pos_z_1   = 1;
% pos_in_z_end = 1;
for k_Col = 1 : size(trans_z, 1)
    for k_Obj = 1 : size(MeasurPos, 1)
        if ~isnan(MeasurPos.(trans_z.ColName{k_Col})(k_Obj))
            if isnan(MeasurPos.Node2_ID(k_Obj)) % NodeRes
                new_values = NodeRes_all.(trans_z.ColName{k_Col})...
                    (NodeRes_all.Node_ID == MeasurPos.Node1_ID(k_Obj));
                if ismember(trans_z.ColName{k_Col}, {'U1', 'U2', 'U3'})
                    new_values = new_values * 10^3; % kV -> V
                end
                if ismember(trans_z.ColName{k_Col}, {'phi1', 'phi2', 'phi3'})
                    new_values = deg2rad(new_values); % deg -> rad
                end      
                if ismember(trans_z.ColName{k_Col}, {'P1', 'P2', 'P3', 'Q1', 'Q2', 'Q3'})                
                    new_values = new_values * 10^6; % MW -> W
                end
%                 pos_z_2 = pos_z_1 - 1 + numel(new_values);
%                 range   = pos_z_1 : pos_z_2;
%                 pos_z_1 = pos_z_2 + 1;
                z_all_data           (pos_z_1,:) = new_values;
                z_all_flag.Node1_ID  (pos_z_1) = MeasurPos.Node1_ID(k_Obj);
                z_all_flag.Node2_ID  (pos_z_1) = NaN;
                z_all_flag.Phase     (pos_z_1) = trans_z.Phase     (k_Col);
                z_all_flag.Meas_Type (pos_z_1) = trans_z.Meas_Type (k_Col);
                z_all_flag.Accur_Type(pos_z_1) = MeasurPos.(trans_z.ColName{k_Col})(k_Obj);
                if z_all_flag.Accur_Type(pos_z_1) == 1 % Real measurements
                    z_all_flag.Sigma (pos_z_1) = trans_z.Sigma     (k_Col);
                end
                if z_all_flag.Accur_Type(pos_z_1) == 3 % Virtual measurements
                    z_all_flag.Sigma (pos_z_1) = 0;
                end
                pos_z_1 = pos_z_1 + 1;
            else
            end 
        end
    end
end


