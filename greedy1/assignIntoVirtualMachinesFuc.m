function [virtualMachinesInServer, valueVMs] = assignIntoVirtualMachinesFuc(tasksInterval, taskIndex, serverIndex, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
    loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs)


virtualMachinesCur = virtualMachinesInServer{taskIndex-1}{serverIndex};
taskID = tasksInterval(taskIndex, 1);
intervalLength = tasksInterval(taskIndex, 3) - tasksInterval(taskIndex, 2);
valueVMs{taskIndex}{serverIndex} = 0;
virtualMachinesInServer{taskIndex}{serverIndex} = virtualMachinesCur;

if isempty(virtualMachinesCur)
    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesFuc(tasksInterval, taskIndex, serverIndex, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
else
    energyMax = inf;
    occupiedvCPUs = 0;
    occupiedGPU = zeros(1, GPUs_server(serverIndex));
    for i = 1:size(virtualMachinesCur, 2)
        taskArray = virtualMachinesCur{i};
        occupiedvCPUs = occupiedvCPUs + taskArray(1,3);
        occupiedGPUTemp = taskArray(1, 5:end-3);
        occupiedGPU = or(occupiedGPU, occupiedGPUTemp);
    end
    leftvCPUs = vCPUs_server(serverIndex) - occupiedvCPUs;
    freeGPU = not(occupiedGPU);
    if isequal(sum(freeGPU), 0)
        useCPUonly = 1;
    else
        useCPUonly = randi(2) - 1;
    end
    if leftvCPUs < 0 % 出错
        error('vCPUs overflow');
    elseif isequal(leftvCPUs, 0) % 无多余vCPU, 无法创建新的虚拟机
        valueVMs{taskIndex}{serverIndex} = 0;
        virtualMachinesInServer{taskIndex}{serverIndex} = virtualMachinesInServer{taskIndex-1}{serverIndex};
    elseif leftvCPUs > 0 % 考虑建立新的虚拟机
        usedvCPUs = randi(leftvCPUs);
        createAnewVM = randi(2)-1;
        if createAnewVM
            if useCPUonly
                execTime = totalLoadCpus(taskID)/lamdaMatrix(taskID, serverIndex)/usedvCPUs; % 只用CPU处理的情况
                if execTime < periodTasks(taskID)
                    power = alpha(serverIndex)*usedvCPUs;
                    energy = power*intervalLength*execTime/periodTasks(taskID);
                    if taskIndex > 1 && energyInServer(serverIndex) > 0
                        energy = energy + 1/valueVMs{taskIndex-1}{serverIndex};
                    end
                    if energy < energyMax
                        energyMax = energy;
                        gpuIndex = 1;
                        gpu_valid = zeros(1, GPUs_server(serverIndex));
                        newVM = [taskIndex, serverIndex, usedvCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), 0];
                        virtualMachinesInServer{taskIndex}{serverIndex} = virtualMachinesCur;
                        virtualMachinesInServer{taskIndex}{serverIndex}{size(virtualMachinesCur, 2)+1} = newVM;
                        valueVMs{taskIndex}{serverIndex} = 1/energy;
                    end
                end
            else
                for j = 1:size(freeGPU, 2)
                    if isequal(freeGPU(j), 1)
                        gpuID = j;
                        execTime = loadCPU(taskID)/lamdaMatrix(taskID, serverIndex)/usedvCPUs + loadGPU(taskID)/chiMatrix{taskID}{serverIndex}{gpuID};
                        if execTime < periodTasks(taskID)
                            power = alpha(serverIndex)*usedvCPUs;
                            power = power + powerMatrix{serverIndex}{gpuID};
                            energy = power*intervalLength*execTime/periodTasks(taskID);
                            if taskIndex > 1 && energyInServer(serverIndex) > 0
                                energy = energy + 1/valueVMs{taskIndex-1}{serverIndex};
                            end
                            if energy < energyMax
                                energyMax = energy;
                                gpuIndex = 2^(j-1)+1;
                                gpu_valid = zeros(1, GPUs_server(serverIndex));
                                gpu_valid(j) = 1;
                                newVM = [taskIndex, serverIndex, usedvCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), gpuID];
                                virtualMachinesInServer{taskIndex}{serverIndex} = virtualMachinesCur;
                                virtualMachinesInServer{taskIndex}{serverIndex}{size(virtualMachinesCur, 2)+1} = newVM;
                                valueVMs{taskIndex}{serverIndex} = 1/energy;
                            end
                        end
                        break
                    end
                end
            end
        else
            i = randi(size(virtualMachinesCur, 2)); % 考虑合并到既有虚拟机的情形
            vmId = i;
            taskArray = virtualMachinesCur{i};
            util = sum(taskArray(:,end-2)./taskArray(:,end-1));
            taskNum = size(taskArray, 1);
            gpuID = taskArray(1, end);
            usedvCPUs = taskArray(1, 3);
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
                        gpuIndex = 1;
                        gpu_valid = zeros(1, GPUs_server(serverIndex));
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
                        gpuIndex = 2^(gpuID-1)+1;
                        gpu_valid = zeros(1, GPUs_server(serverIndex));
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
end
end