function [Assign, value, tasksIDinServer, tasksInServer] = updateAccordingToAppearTimeFuc(Assign, value, deleteTaskIDs, tasksIDinServer)

lastLayerAssign = Assign{end};
for serverID = 1:size(tasksIDinServer, 2)
    deleteTaskIDThisServer = intersect(tasksIDinServer{serverID}, deleteTaskIDs);    
    tasksIDinServer{serverID} = setdiff(tasksIDinServer{serverID}, deleteTaskIDThisServer);
    if isempty(tasksIDinServer{serverID})
        tasksInServer(serverID) = 0;
    else
        tasksInServer(serverID) = size(tasksIDinServer{serverID}, 2);
    end
    
    for Cx = 1:size(lastLayerAssign{serverID}, 2)
        for gpuIndex = 1:size(lastLayerAssign{serverID}{Cx}, 2)
            virtualMachines = lastLayerAssign{serverID}{Cx}{gpuIndex};
            for vmIndex = 1:size(virtualMachines, 2)
                taskExecVM = virtualMachines{vmIndex};
                taskExecVMTemp = [];
                for columnTask = 1:size(taskExecVM, 1)
                    TaskOrder = taskExecVM(columnTask, 1);
                    if ~ismember(TaskOrder, deleteTaskIDThisServer)
                        taskExecVMTemp = [taskExecVMTemp; taskExecVM(columnTask, :)];
                    end
                end
                virtualMachines{vmIndex} = taskExecVMTemp;
            end
            virtualMachinesTemp = {};
            climbIndex = 1;
            for vmIndex = 1:size(virtualMachines, 2)
                if ~isempty(virtualMachines{vmIndex})
                    virtualMachinesTemp{climbIndex} = virtualMachines{vmIndex};
                    climbIndex = climbIndex+1;
                end
            end
            lastLayerAssign{serverID}{Cx}{gpuIndex} = virtualMachinesTemp;
        end
    end
end
Assign{end} = lastLayerAssign;