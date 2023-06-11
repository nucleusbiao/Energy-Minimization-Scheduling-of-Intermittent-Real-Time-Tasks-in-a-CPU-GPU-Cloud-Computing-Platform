function [virtualMachinesInServer, valueVMs] = assignIntoVMGreedyOneFuc(tasksInterval, taskIndex, serverIndex, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
    loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs)

virtualMachinesCur = virtualMachinesInServer{taskIndex-1}{serverIndex};
taskID = tasksInterval(taskIndex, 1);
intervalLength = tasksInterval(taskIndex, 3) - tasksInterval(taskIndex, 2);
valueVMs{taskIndex}{serverIndex} = 0;
virtualMachinesInServer{taskIndex}{serverIndex} = virtualMachinesCur;

if isempty(virtualMachinesCur)
    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesGreedyOneFuc(tasksInterval, taskIndex, serverIndex, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
else
    energyMax = inf;
    i = randi(size(virtualMachinesCur, 2)); % 考虑合并到既有虚拟机的情形
    if ~isequal(i, 1)
        error('two virtual machines exist');
    end
    vmId = i;
    taskArray = virtualMachinesCur{i};
    util = sum(taskArray(:,end-2)./taskArray(:,end-1));
    taskNum = size(taskArray, 1);
    usedvCPUs = taskArray(1, 3);
    numGPUs = GPUs_server(serverIndex);
    for gpuID = 0:1:GPUs_server(serverIndex)        
        if isequal(gpuID, 0) % 此虚拟机不占用GPU，只能用vCPU处理
            execTime = totalLoadCpus(taskID)/lamdaMatrix(taskID, serverIndex)/usedvCPUs; % 只用CPU处理的情况
            if util + execTime/periodTasks(taskID) <= (taskNum+1)*(2^(1/(taskNum+1))-1)
                power = alpha(serverIndex)*usedvCPUs;
                energy = power*intervalLength*execTime/periodTasks(taskID);
                if taskIndex > 1 && energyInServer(serverIndex) > 0
                    energy = energy + 1/valueVMs{taskIndex-1}{serverIndex};
                end
                if energy < energyMax
                    energyMax = energy;
                    gpuIndex = 2^numGPUs;
                    gpu_valid = ones(1, numGPUs);
                    newVM = [taskArray; taskIndex, serverIndex, usedvCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), 0];
                    virtualMachinesInServer{taskIndex}{serverIndex} = virtualMachinesCur;
                    virtualMachinesInServer{taskIndex}{serverIndex}{vmId} = newVM;
                    valueVMs{taskIndex}{serverIndex} = 1/energy;
                end
            end
        else
            execTime = loadCPU(taskID)/lamdaMatrix(taskID, serverIndex)/usedvCPUs + loadGPU(taskID)/chiMatrix{taskID}{serverIndex}{gpuID};
            if util + execTime/periodTasks(taskID) <= (taskNum+1)*(2^(1/(taskNum+1))-1)
                power = alpha(serverIndex)*usedvCPUs;
                power = power + powerMatrix{serverIndex}{gpuID};
                energy = power*intervalLength*execTime/periodTasks(taskID);
                if taskIndex > 1 && energyInServer(serverIndex) > 0
                    energy = energy + 1/valueVMs{taskIndex-1}{serverIndex};
                end
                if energy < energyMax
                    energyMax = energy;
                    gpuIndex = 2^numGPUs;
                    gpu_valid = ones(1, numGPUs);
                    gpu_valid(gpuID) = 1;
                    newVM = [taskArray; taskIndex, serverIndex, usedvCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), gpuID];
                    virtualMachinesInServer{taskIndex}{serverIndex} = virtualMachinesCur;
                    virtualMachinesInServer{taskIndex}{serverIndex}{vmId} = newVM;
                    valueVMs{taskIndex}{serverIndex} = 1/energy;
                end
            end
        end
    end
end