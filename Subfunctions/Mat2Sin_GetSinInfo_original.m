function SinInfo = Mat2Sin_GetSinInfo(Sin_Name,Sin_Path)
%% Function manual: 
%  This function creates a connection to the MS Access database (DB) to get
%  required information about the Sincal modell of the grid that must be
%  investigated
% 
%  SinInfo = Mat2Sin_GetSinInfo(Sin_Name,Sin_Path)
%   
%       Sin_Name   (Required)   - String that defines the name of the Sincal file
%       Sin_Path   (Optional)   - String that defines the path of the Sincal file
%                               - (default): 'pwd' - current folder 
%       SinInfo    (Result)     - Struct with information about all Nodes and Elements
%
% RB, v2016_02_16

%% Matlab connection with the Access DB of the Sincal model 
    % Set the default path if no path is given
        if nargin<2
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
    % try-catch to get a message if an error occur during the Matlab connection with the DB
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

%% Create the resulting objekt SinInfo
        SinInfo = struct;
        
%% Get all nodes from the DB of the Sincal model
    % SQL command: ['SELECET ', '"Column Names"', ' FROM ' '"Table Name"']
        sql = ['SELECT ', 'Node_ID,Name', ' FROM ', 'Node'];
    % Get the Recordset(ADO_rs) for the Nodes
        ADO_rs = invoke(a.conn,'Execute',sql);
    % Get the nodes from the Recordset (Values in the current Column of the current Table
        SinNodes = invoke(ADO_rs,'GetRows')';
    % Number of Nodes
        num_of_Node = size(SinNodes,1);

    % In this loop delete the free spaces of the strings in SinNodes with "strtrim"
        for kE = 1:num_of_Node
            SinNodes{kE,2} = strtrim(SinNodes{kE,2});
        end
    % Save Nodes in SinInfo
        SinInfo.Node = cell2table(SinNodes,'VariableNames',{'Node_ID','Name'});
        SinInfo.Node = sortrows(SinInfo.Node,'Node_ID','ascend');

%% Get all terminal info from the DB of the Sincal model
    % SQL command: ['SELECET ', '"Column Names"', ' FROM ' '"Table Name"']
        sql = ['SELECT ', 'Terminal_ID,Element_ID,Node_ID,Flag_State', ' FROM ', 'Terminal'];
    % Get the Recordset(ADO_rs) for the Nodes
        ADO_rs = invoke(a.conn,'Execute',sql);
    % Get the nodes from the Recordset (Values in the current Column of the current Table
        SinTerminal = invoke(ADO_rs,'GetRows')';
    % Number of Nodes
        num_of_Terminal = size(SinTerminal,1);

    % Save Nodes in SinInfo
        SinInfo.Terminal = cell2table(SinTerminal,'VariableNames',{'Terminal_ID','Element_ID','Node_ID','Flag_State'});
        SinInfo.Terminal = sortrows(SinInfo.Terminal,'Terminal_ID','ascend');

%% Get all elements from the DB of the Sincal model
    % SQL command: ['SELECET ', '"Column Names"', ' FROM ' '"Table Name"']
        sql = ['SELECT ', 'Element_ID,ElementName,ElementType,Node_ID', ' FROM ', 'QueryTopologySinglePort'];
    % Get the Recordset(ADO_rs) for the Elements
        ADO_rs = invoke(a.conn,'Execute',sql);
    % Get the elements from the Recordset (Values in the current Column of the current Table)
        SinElement = invoke(ADO_rs,'GetRows')';
    % Number of Elements
        num_of_Element = size(SinElement,1);

    % In this loop delete the free spaces of the strings in SinElements with
    % "strtrim"
        for kE = 1:num_of_Element
            SinElement{kE,2} = strtrim(SinElement{kE,2});
            SinElement{kE,3} = strtrim(SinElement{kE,3});
        end
    % Save Elements in SinInfo
    	SinInfo.Element = cell2table(SinElement,'VariableNames',{'Element_ID','Name','Type','Node1_ID'});
        SinInfo.Element = sortrows(SinInfo.Element,'Name','ascend');

%% Get all element types from the element table in the DB and categorize them into single, two and three Port
    % All Element types
        SinElementTypes = unique(SinInfo.Element.Type);
    % Check with try if three port Elements occur
        try
        % Get the three port Elements types
            sql = ['SELECT ', 'Type', ' FROM ', 'QueryTopologyThreePort'];
        % Get the Recordset(ADO_rs) for the Three Port Elements types
            ADO_rs = invoke(a.conn,'Execute',sql);
        % Get the elements from the Recordset
            SinElementsThreePortTypes = invoke(ADO_rs,'GetRows')';
        % In this loop delete the free spaces of the strings in 
        % SinElementsThreePortTypes with "strtrim"
            for kE = 1:numel(SinElementsThreePortTypes);
                SinElementsThreePortTypes{kE} = strtrim(SinElementsThreePortTypes{kE});
            end
        catch
        % If no three port Elements occur
            SinElementsThreePortTypes = cell(0);
        end
    % Get the two port Element types
        sql = ['SELECT ', 'Type', ' FROM ', 'QueryTopologyTwoPort']; 
    % Get the Recordset(ADO_rs) for the Elements
        ADO_rs = invoke(a.conn,'Execute',sql);
    % Get the Recordset(ADO_rs) for the Two Port Elements types
        SinElementsTwoPortTypes = unique(invoke(ADO_rs,'GetRows')');
    % In this loop delete the free spaces of the strings in 
    % SinElementsTwoPortTypes with "strtrim"
        for kE = 1:numel(SinElementsTwoPortTypes);
            SinElementsTwoPortTypes{kE} = strtrim(SinElementsTwoPortTypes{kE});
        end
    % Get the Single port Element types
        SinElementsSinglePortTypes = setdiff(SinElementTypes,[SinElementsThreePortTypes,SinElementsTwoPortTypes]);
    
%% Extract all Single Port Type Elements
    % Number of single port types
        num_of_SinglePortTypes = numel(SinElementsSinglePortTypes);
        for kE = 1:num_of_SinglePortTypes 
            % Get the name of one single port type
            kE_TypeName = SinElementsSinglePortTypes{kE};
            % SQL command: ['SELECET ', '"Column Names"', ' FROM ' '"Table Name"']
            sql = ['SELECT ', 'Element_ID,ElementName,Node_ID',...
                ' FROM ', 'QueryTopologySinglePort', ' WHERE ElementType = ''' kE_TypeName '''' ];
            % Get the Recordset(ADO_rs) for the Elements
            ADO_rs = invoke(a.conn,'Execute',sql);
            % Get the elements from the Recordset (Values in the current Column of the current Table)
            SinSinglePort = invoke(ADO_rs,'GetRows')';
            % Number of Elements
            num_of_SinglePort = size(SinSinglePort,1);
            % In this loop delete the free spaces of SinSinglePort
            for kEE = 1:num_of_SinglePort
                SinSinglePort{kEE,2} = strtrim(SinSinglePort{kEE,2});
            end
            % Save SinSinglePort in SinInfo
            SinInfo.(kE_TypeName) = cell2table(SinSinglePort,'VariableNames',{'Element_ID','Name','Node1_ID'});
            SinInfo.(kE_TypeName) = sortrows(SinInfo.(kE_TypeName),'Name','ascend');
        end

%% Extract all Two Port Type Elements
    % Number of two port types
        num_of_TwoPortTypes = numel(SinElementsTwoPortTypes);
        for kE = 1:num_of_TwoPortTypes 
            % Get the name of one two port type
            kE_TypeName = SinElementsTwoPortTypes{kE};
            % SQL command: ['SELECET ', '"Column Names"', ' FROM ' '"Table Name"']
            sql = ['SELECT ', 'Element_ID,ElementName,Node_1.Node_ID,Node_2.Node_ID',...
                ' FROM ', 'QueryTopologyTwoPort', ' WHERE Type = ''' kE_TypeName '''' ];
            % Get the Recordset(ADO_rs) for the Elements
            ADO_rs = invoke(a.conn,'Execute',sql);
            % Get the elements from the Recordset (Values in the current Column of the current Table)
            SinTwoPort = invoke(ADO_rs,'GetRows')';
            % Number of Elements
            num_of_TwoPort = size(SinTwoPort,1);
            % In this loop delete the free spaces of SinTwoPort
            for kEE = 1:num_of_TwoPort
                SinTwoPort{kEE,2} = strtrim(SinTwoPort{kEE,2});
            end
            % Save SinTwoPort in SinInfo
            SinInfo.(kE_TypeName) = cell2table(SinTwoPort,'VariableNames',{'Element_ID','Name','Node1_ID','Node2_ID'});
            SinInfo.(kE_TypeName) = sortrows(SinInfo.(kE_TypeName),'Name','ascend');
        end

%% Extract all Three Port Type Elements
    % Number of three port types
        num_of_ThreePortTypes = numel(SinElementsThreePortTypes);
        for kE = 1:num_of_ThreePortTypes
            % Get the name of one three port type
            kE_TypeName = SinElementsThreePortTypes{kE};
            % SQL command: ['SELECET ', '"Column Names"', ' FROM ' '"Table Name"']
            sql = ['SELECT ', 'Element_ID,ElementName,Node_1.Node_ID,Node_2.Node_ID,Node_3.Node_ID',...
                ' FROM ', 'QueryTopologyThreePort', ' WHERE Type = ''' kE_TypeName '''' ];
            % Get the Recordset(ADO_rs) for the Elements
            ADO_rs = invoke(a.conn,'Execute',sql);
            % Get the elements from the Recordset (Values in the current Column of the current Table)
            SinThreePort = invoke(ADO_rs,'GetRows')';
            % Number of Elements
            num_of_ThreePort = size(SinThreePort,1);
            % In this loop delete the free spaces of SinThreePort
            for kEE = 1:num_of_ThreePort
                SinThreePort{kEE,2} = strtrim(SinThreePort{kEE,2});
            end
            % Save SinThreePort in SinInfo
            SinInfo.(kE_TypeName) = cell2table(SinThreePort,'VariableNames',{'Element_ID','Name','Node1_ID','Node2_ID','Node3_ID'});
            SinInfo.(kE_TypeName) = sortrows(SinInfo.(kE_TypeName),'Name','ascend');
        end

%% Close the connection with the DB
        a.conn.Close

end