function [virtualMachinesInServer, valueVMs] = createVMGreedyTwoFuc(tasksInterval, taskIndex, serverIndex, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
    loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs)


valueServerJ = 0;
passFlag = 0;
for Cx = 1:vCPUs_server(serverIndex)
    vCPUs = Cx;
    num_gpu = GPUs_server(serverIndex);    
    for k = 0:1:num_gpu % 遍历gpu的所有情况
        gpu_valid = zeros(1, num_gpu);
        if k > 0            
            gpu_valid(k) = 1;
            gpuIndex = 2^(k-1)+1;
        else
            gpuIndex = 1;
        end
        taskID = tasksInterval(taskIndex, 1);
        intervalLength = tasksInterval(taskIndex, 3) - tasksInterval(taskIndex, 2);
        
        % 仅用CPU处理的情况
        execTime = totalLoadCpus(taskID)/lamdaMatrix(taskID, serverIndex)/vCPUs;
        if execTime < periodTasks(taskID)
            power = alpha(serverIndex)*vCPUs;
            energy = power*intervalLength*execTime/periodTasks(taskID);
            if taskIndex > 1 && energyInServer(serverIndex) > 0 
                energy = energy + 1/valueVMs{taskIndex-1}{serverIndex};
            end
            valueTemp = 1/energy;
            virtualMachine = [taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), 0];
        else
            valueTemp = 0;
            virtualMachine = [];
        end
        if valueTemp > valueServerJ
            valueServerJ = valueTemp;
            valueVMs{taskIndex}{serverIndex} = valueServerJ; 
            if isempty(virtualMachine)
                virtualMachinesInServer{taskIndex}{serverIndex} = virtualMachine;
            else
                virtualMachinesInServer{taskIndex}{serverIndex}{1} = virtualMachine;
            end
            passFlag = 1;
            break
        end
        
        % 采用CPU和GPU一同处理
        if ~passFlag
            for i = 1:size(gpu_valid, 2)
                power = alpha(serverIndex)*vCPUs;
                if isequal(gpu_valid(i), 1)
                    gpuID = i;
                    execTime = loadCPU(taskID)/lamdaMatrix(taskID, serverIndex)/vCPUs + loadGPU(taskID)/chiMatrix{taskID}{serverIndex}{gpuID};
                    if execTime < periodTasks(taskID)
                        power = power + powerMatrix{serverIndex}{gpuID};
                        energy = power*intervalLength*execTime/periodTasks(taskID);
                        if taskIndex > 1 && energyInServer(serverIndex) > 0 
                            energy = energy + 1/valueVMs{taskIndex-1}{serverIndex};
                        end
                        valueTemp = 1/energy;
                        if valueTemp > valueServerJ
                            valueServerJ = valueTemp;
                            valueVMs{taskIndex}{serverIndex} = valueServerJ; 
                            virtualMachinesInServer{taskIndex}{serverIndex}{1} = [taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), gpuID];
                            passFlag = 1;
                            break
                        end
                    end
                end
            end
        end
    end
    if passFlag
        break
    end
end