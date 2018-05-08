function cancel = updateWaitbar(flag,hand,val,message)
% Updates the progress and message from a Waitbar or deletes a Waitbar.
% Also verifies if user aborted the process by clicking the cancel button.
%
%
% Author: P.Gassler

switch flag
    case 'update'
        waitbar(val,hand,message)
        if getappdata(hand,'canceling')
            delete(hand);
            cancel =  true;
            disp('Process stopped by User!');
        else
            cancel = false;
        end
        
    case 'delete'
        delete(hand);
        cancel = true;
end
end