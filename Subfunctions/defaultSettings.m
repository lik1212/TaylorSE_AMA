function Settings = defaultSettings(Inputs)
% defaultSettings checks the content of Inputs and based on it define the
% Settings. If some optional field do not occur in "Inputs" set the default
% values for it.
%
% Author(s): R. Brandalik

%% Transfer main info from "Inputs

Settings = Inputs;

%% Default setting if the inputs do not occur in the variable "Inputs"

default_Options = {...
    'pseudo'       , false ;... % TODO later (integration of pseudo-values)
    'LP_DB_name'   , ''    ;...
    'PV_DB_name'   , ''    ;...
    'LP_dist_name' , ''    ;...
    'PV_dist_name' , ''    ;...
    };

for k_Opt = 1 : size(default_Options,1)
    if ~isfield(Inputs, default_Options{k_Opt,1})
        Settings.(default_Options{k_Opt,1}) = default_Options{k_Opt,2};
    end
end

% Timestamp
Settings.Timestamp = char(datetime('now','Format','yyMMdd_HH_mm_ss'));
