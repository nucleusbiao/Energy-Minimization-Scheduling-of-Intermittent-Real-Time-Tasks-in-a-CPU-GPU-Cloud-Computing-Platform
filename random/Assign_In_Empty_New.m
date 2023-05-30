function [Assign,value]=Assign_In_Empty_New(tasksInterval, taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, periodTasks, totalLoadCpus, ...
    loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, Assign, value)


value{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = 0;

taskID = tasksInterval(taskIndex, 1);
intervalLength = tasksInterval(taskIndex, 3) - tasksInterval(taskIndex, 2);
% 仅用CPU处理的情况
execTime = totalLoadCpus(taskID)/lamdaMatrix(taskID, serverIndex)/vCPUs;
if execTime < periodTasks(taskID)
    power = alpha(serverIndex)*vCPUs;
    energy = power*intervalLength*execTime/periodTasks(taskID);
    if taskIndex > 1 && energyInServer(serverIndex) > 0 
        energy = energy + 1/value{taskIndex-1}{serverIndex}{vCPUs}{gpuIndex};
    end
    valueTemp = 1/energy;
        
    Assign{taskIndex}{serverIndex}{vCPUs}{gpuIndex}{1} = [taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), 0];
else
    valueTemp = 0;
    Assign{taskIndex}{serverIndex}{vCPUs}{gpuIndex}{1} = [];
end
value{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = valueTemp;
% 采用CPU和GPU一同处理

for i = 1:size(gpu_valid, 2)
    power = alpha(serverIndex)*vCPUs;
    if isequal(gpu_valid(i), 1)
        gpuID = i;
        execTime = loadCPU(taskID)/lamdaMatrix(taskID, serverIndex)/vCPUs + loadGPU(taskID)/chiMatrix{taskID}{serverIndex}{gpuID};
        if execTime < periodTasks(taskID)
            power = power + powerMatrix{serverIndex}{gpuID};
            energy = power*intervalLength*execTime/periodTasks(taskID);
            if taskIndex > 1 && energyInServer(serverIndex) > 0 
                energy = energy + 1/value{taskIndex-1}{serverIndex}{vCPUs}{gpuIndex};
            end
            valueTemp2 = 1/energy;
            if valueTemp2 > valueTemp
                Assign{taskIndex}{serverIndex}{vCPUs}{gpuIndex}{1} = [taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), gpuID];
                valueTemp = valueTemp2;
                value{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = valueTemp;
            end
        end
    end
end

