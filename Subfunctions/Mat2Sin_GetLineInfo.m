function LineInfo = Mat2Sin_GetLineInfo(SinInfo,LineInfoWanted,Sin_Name,Sin_Path)
% Mat2Sin_GetLineInfo - Get Line Parameters (Information) from Sincal 
%
%   LineInfo = Mat2Sin_GetLineInfo(SinInfo,LineInfoWanted,Sin_Name,Sin_Path)
%
%       SinInfo        (Required) - struct
%                                 - Information about the Sincal model
%                                 - Result of the function:
%                                 - Mat2Sin_GetSinInfo
%                                   
%       LineInfoWanted (Required) - (cell)
%                                 - Line parameters (information) wanted
%
%       Sin_Name       (Required) - String that defines the name of the
%                                   Sincal file
%
%       Sin_Path       (Optional) - String that defines the path of the
%                                   Sincal file
%                                 - (default): 'pwd' - current folder 
%       
%       LineInfo       (Result)   - (table)
%                                 - field for every line with values for
%                                   all wanted parameters
%
% RB, 2015

%% Matlab connection with the Access DB of the Sincal model 

% Set the default path if no path is given
if nargin<4
    Sin_Path = [pwd,'\'];
end

% Correct the path if necessary
if Sin_Path(end) ~= '\'
    Sin_Path = [Sin_Path,'\'];
end

% Define an object for the connection with the DB
a=struct;
% Set the DB path:
a.DB_Path = [Sin_Path,Sin_Name,'_files\database.mdb'];

% Setting of the Access COM server
% try-catch To get a message if an error occur during the Matlab connection with the DB
try
    % Server for the Matlab connection to Access
    a.conn = actxserver('ADODB.connection');
    % Define the Provider
    a.provider = 'Microsoft.ACE.OLEDB.12.0';
    % Open the connection with the Access Database
    a.conn.Open(['Provider=' a.provider ';Data Source=' a.DB_Path]);
catch
    % If an error occur during the Matlab connection with the DB:
    disp('Error during the connection of Matlab with Access.');
end

%% Check if Lines exist in the Sincal model

if isfield(SinInfo,'Line') == 0 
    % If no Lines exist stop the function
    LineInfo = 'No Lines existing';
    return;
end

%% Get Line Parameters

% SQL command: ['SELECET ', '"Column Names"', ' FROM ' '"Table Name"']
sql = ['SELECT ', 'Element_ID,', strjoin(LineInfoWanted,','), ' FROM ', 'Line'];
% Get the Recordset(ADO_rs) for the Lines
ADO_rs = invoke(a.conn,'Execute',sql);
% Get information about the Lines (Line Table)
LineTab = invoke(ADO_rs,'GetRows')';

% Create Line Info Table
LineInfo = cell2table(LineTab,'VariableNames',['Element_ID',LineInfoWanted]);
% Sort LineInfo table by Element_ID to add the line names in the LineInfo table
LineInfo = sortrows(LineInfo,'Element_ID','ascend');
% The Line Names will be taken from SinInfo, sort them by Element_ID too
SinInfo.Line =  sortrows(SinInfo.Line,'Element_ID','ascend');
% Add line names from SinInfo to the LineInfo table
LineInfo.Name = SinInfo.Line.Name;
% Sort the columns (for a better view)
LineInfo = [LineInfo(:,1),LineInfo(:,size(LineInfo,2)),LineInfo(:,2:size(LineInfo,2)-1)];
% Sort the columns by name
LineInfo = sortrows(LineInfo,'Name','ascend');

%% Close the DB connection

invoke(a.conn,'Close');

end