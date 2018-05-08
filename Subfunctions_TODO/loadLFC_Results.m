function NodeRes_all = loadLFC_Results(LP_Path,inst)
%%  Function manual:
%   This function searches for .txt-files which include node results of a
%   load flow calculation and assembles all files to one .mat file which can
%   be feeded faster to Matlab


fprintf('Subfuntion: loadLC_Results\n');% Command window output

%  Sort all files existing in LP_Path
files_in_LC_Results = struct2table(dir(LP_Path));                       % Get all file names in LP_Path
files_unsorted      = setdiff(files_in_LC_Results.name,{'.','..'});     % Delete the entries "." and ".."
files_unsorted_str  = sprintf('%s,',files_unsorted{:});                 % Create a continuous string of all file names
files_unsorted_num  = sscanf(files_unsorted_str,...                     % Get sorting numbers of node result .txt-files
    'NodeRes_Wessum-Riete_Netz_170726_5256inst_%d.txt,');
[~, sortIndex]      = sort(files_unsorted_num);                         % Sort the sorting numbers ascending
files_sorted        = files_unsorted(sortIndex);                        % Sort the file names considering their sorting numbers
files_sorted_wPath  = ...                                               % Add path to sorted file names
    strcat(repmat(LP_Path,[size(files_sorted),1]),files_sorted);

% Create one .mat file out of all .txt files
for k_file = 1:numel(files_sorted_wPath)
    NodeRes_temp = readtable(files_sorted_wPath{k_file});
    if  k_file == 1
        NodeRes_all = NodeRes_temp;
    else
        NodeRes_temp.ResTime = NodeRes_temp.ResTime+(k_file-1)*inst;
        NodeRes_all = [NodeRes_all;NodeRes_temp];
    end
end
end