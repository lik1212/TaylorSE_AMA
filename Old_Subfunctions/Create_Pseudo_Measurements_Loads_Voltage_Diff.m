function [AAPD_P, AAPD_Q] = Create_Pseudo_Measurements_Loads_Voltage_Diff(Num_Loads, Date_Time, tan_phi)
%%
Date_Time_Winter =      Date_Time   <   datetime('21.03.2015 00:00:00','TimeZone','+02:00') |...
    Date_Time   >=  datetime('31.10.2015 00:00:00','TimeZone','+02:00');
Date_Time_Transition =  Date_Time   >=  datetime('21.03.2015 00:00:00','TimeZone','+02:00') &...
    Date_Time   <   datetime('15.05.2015 00:00:00','TimeZone','+02:00') |...
    Date_Time   >=  datetime('15.09.2015 00:00:00','TimeZone','+02:00') &...
    Date_Time   <   datetime('31.10.2015 00:00:00','TimeZone','+02:00');
Date_Time_Summer =      Date_Time   >=  datetime('15.05.2015 00:00:00','TimeZone','+02:00') &...
    Date_Time   <   datetime('15.09.2015 00:00:00','TimeZone','+02:00');

Weekday     = ismember(weekday(Date_Time),2:6);
Saturday    = ismember(weekday(Date_Time),7);
Sunday      = ismember(weekday(Date_Time),1);

if      Date_Time_Winter
    
    if      Weekday
        if      ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6])
            AAPD_logic = 5;
        elseif  ismember(hour(Date_Time),7:17)
            AAPD_logic = 6;
        elseif  ismember(hour(Date_Time),18:21)
            AAPD_logic = 7;
        end
    elseif  Saturday
        if      ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7])
            AAPD_logic = 5;
        elseif  ismember(hour(Date_Time),8:21)
            AAPD_logic = 8;
        end
    elseif  Sunday
        if      ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7,8])
            AAPD_logic = 5;
        elseif  ismember(hour(Date_Time),[9,10,11,12,13,19,20,21])
            AAPD_logic = 8;
        elseif  ismember(hour(Date_Time),14:18)
            AAPD_logic = 8;
        end
    end
    
elseif  Date_Time_Transition
    
    if      Weekday
        if      ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6])
            AAPD_logic = 9;
        elseif  ismember(hour(Date_Time),7:17)
            AAPD_logic = 10;
        elseif  ismember(hour(Date_Time),18:21)
            AAPD_logic = 11;
        end
    elseif  Saturday
        if      ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7])
            AAPD_logic = 9;
        elseif  ismember(hour(Date_Time),8:21)
            AAPD_logic = 12;
        end
    elseif  Sunday
        if      ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7,8])
            AAPD_logic = 9;
        elseif  ismember(hour(Date_Time),[9,10,11,12,13,19,20,21])
            AAPD_logic = 12;
        elseif  ismember(hour(Date_Time),14:18)
            AAPD_logic = 12;
        end
    end
    
elseif  Date_Time_Summer
    
    if      Weekday
        if      ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6])
            AAPD_logic = 1;
        elseif  ismember(hour(Date_Time),7:17)
            AAPD_logic = 2;
        elseif  ismember(hour(Date_Time),18:21)
            AAPD_logic = 3;
        end
    elseif  Saturday
        if      ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7])
            AAPD_logic = 1;
        elseif  ismember(hour(Date_Time),8:21)
            AAPD_logic = 4;
        end
    elseif  Sunday
        if      ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7,8])
            AAPD_logic = 1;
        elseif  ismember(hour(Date_Time),[9,10,11,12,13,19,20,21])
            AAPD_logic = 4;
        elseif  ismember(hour(Date_Time),14:18)
            AAPD_logic = 4;
        end
    end
end
%%
AAPD_P = zeros(Num_Loads,1);

switch AAPD_logic
    case 1
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 500*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.1*Num_Loads))        = 200*10^-6;
        last_step                                              = last_step + ceil(0.1*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.175*Num_Loads))      = 100*10^-6;
        last_step                                              = last_step + ceil(0.175*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.275*Num_Loads))      = 50*10^-6;
    case 2
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 2000*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 500*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.125*Num_Loads))      = 200*10^-6;
        last_step                                              = last_step + ceil(0.125*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 100*10^-6;
        last_step                                              = last_step + ceil(0.225*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 50*10^-6;
    case 3
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 2000*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 1000*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.05*Num_Loads))       = 500*10^-6;
        last_step                                              = last_step + ceil(0.05*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.2*Num_Loads))        = 200*10^-6;
        last_step                                              = last_step + ceil(0.2*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 100*10^-6;
        last_step                                              = last_step + ceil(0.225*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.175*Num_Loads))      = 50*10^-6;
    case 4
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 2000*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 1000*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 500*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.175*Num_Loads))      = 200*10^-6;
        last_step                                              = last_step + ceil(0.175*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 100*10^-6;
        last_step                                              = last_step + ceil(0.225*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.2*Num_Loads))        = 50*10^-6;
    case 5
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 1000*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 500*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.15*Num_Loads))       = 200*10^-6;
        last_step                                              = last_step + ceil(0.15*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.2*Num_Loads))        = 100*10^-6;
        last_step                                              = last_step + ceil(0.2*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 50*10^-6;
    case 6
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 2000*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 1000*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 500*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.175*Num_Loads))      = 200*10^-6;
        last_step                                              = last_step + ceil(0.175*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 100*10^-6;
        last_step                                              = last_step + ceil(0.225*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.175*Num_Loads))      = 50*10^-6;
    case 7
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 2000*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 1500*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 1000*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.1*Num_Loads))        = 500*10^-6;
        last_step                                              = last_step + ceil(0.1*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.275*Num_Loads))      = 200*10^-6;
        last_step                                              = last_step + ceil(0.275*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.2*Num_Loads))        = 100*10^-6;
        last_step                                              = last_step + ceil(0.2*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.125*Num_Loads))      = 50*10^-6;
    case 8
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 2000*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 1000*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.075*Num_Loads))      = 500*10^-6;
        last_step                                              = last_step + ceil(0.075*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 200*10^-6;
        last_step                                              = last_step + ceil(0.225*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 100*10^-6;
        last_step                                              = last_step + ceil(0.225*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.15*Num_Loads))       = 50*10^-6;
    case 9
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 500*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.125*Num_Loads))      = 200*10^-6;
        last_step                                              = last_step + ceil(0.125*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.2*Num_Loads))        = 100*10^-6;
        last_step                                              = last_step + ceil(0.2*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 50*10^-6;
    case 10
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 2000*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 500*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.15*Num_Loads))       = 200*10^-6;
        last_step                                              = last_step + ceil(0.15*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 100*10^-6;
        last_step                                              = last_step + ceil(0.225*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.2*Num_Loads))        = 50*10^-6;
    case 11
        AAPD_P(1:ceil(0.025*Num_Loads)) = 2000*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.025*Num_Loads))      = 1000*10^-6;
        last_step                                              = last_step + ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.075*Num_Loads))      = 500*10^-6;
        last_step                                              = last_step + ceil(0.075*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.25*Num_Loads))       = 200*10^-6;
        last_step                                              = last_step + ceil(0.25*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 100*10^-6;
        last_step                                              = last_step + ceil(0.225*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.15*Num_Loads))       = 50*10^-6;
    case 12
        AAPD_P(1:ceil(0.025*Num_Loads))                          = 2000*10^-6;
        last_step                                              = ceil(0.025*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.05*Num_Loads))       = 500*10^-6;
        last_step                                              = last_step + ceil(0.05*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.2*Num_Loads))        = 200*10^-6;
        last_step                                              = last_step + ceil(0.2*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.225*Num_Loads))      = 100*10^-6;
        last_step                                              = last_step + ceil(0.225*Num_Loads);
        AAPD_P(last_step+1:last_step+ceil(0.175*Num_Loads))      = 50*10^-6;
end

AAPD_P = AAPD_P*(-10^6);
AAPD_Q = AAPD_P.*tan_phi;
