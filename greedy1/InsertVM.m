function [assignInsert, valueInsert]=InsertVM(tasksInterval, taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, periodTasks, totalLoadCpus, ...
    loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, Assign, value)


valueInsert = value;
valueInsert{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = value{taskIndex-1}{serverIndex}{vCPUs}{gpuIndex};

assignInsert = Assign;
assignInsert{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = Assign{taskIndex-1}{serverIndex}{vCPUs}{gpuIndex};

taskID = tasksInterval(taskIndex, 1);
intervalLength = tasksInterval(taskIndex, 3) - tasksInterval(taskIndex, 2);

virtualMachines = assignInsert{taskIndex}{serverIndex}{vCPUs}{gpuIndex};
valueMax = 0;
passFlag = 0;
for i = 1:size(virtualMachines, 2)
    tasksArray = virtualMachines{i};
    if ~isempty(tasksArray)            
        util = sum(tasksArray(:,end-2)./tasksArray(:,end-1));
        taskNum = size(tasksArray, 1);
        if isequal(tasksArray(1,end), 0) % 只用CPU处理的情况
            execTime = totalLoadCpus(taskID)/lamdaMatrix(taskID, serverIndex)/tasksArray(1,3);            
            if util + execTime/periodTasks(taskID) <= (taskNum+1)*(2^(1/(taskNum+1))-1)
                power = alpha(serverIndex)*tasksArray(1,3);
                energy = power*intervalLength*execTime/periodTasks(taskID);
                energy = energy + 1/value{taskIndex-1}{serverIndex}{vCPUs}{gpuIndex};
                valueTemp = 1/energy;
                if valueTemp > valueMax
                    valueMax = valueTemp;
                    tasksArray = [tasksArray; taskIndex, serverIndex, tasksArray(1,3), gpuIndex, gpu_valid, execTime, periodTasks(taskID), 0];
                    virtualMachinesTemp = virtualMachines;
                    virtualMachinesTemp{i} = tasksArray;
                    assignInsert{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = virtualMachinesTemp;
                    valueInsert{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = valueTemp;
                    passFlag = 1;
                end
            end
        else  % 用CPU和GPU共同处理的情
            for gpuIndexi = 1:size(gpu_valid, 2)
                if isequal(gpu_valid(gpuIndexi), 1)
                    tasksArray = virtualMachines{i};
                    gpuID = gpuIndexi;                                
                    execTime = loadCPU(taskID)/lamdaMatrix(taskID, serverIndex)/tasksArray(1,3) + loadGPU(taskID)/chiMatrix{taskID}{serverIndex}{gpuID};
                    if util + execTime/periodTasks(taskID) <= (taskNum+1)*(2^(1/(taskNum+1))-1)
                        power = alpha(serverIndex)*tasksArray(1,3) + powerMatrix{serverIndex}{gpuID};
                        energy = power*intervalLength*execTime/periodTasks(taskID);
                        energy = energy + 1/value{taskIndex-1}{serverIndex}{vCPUs}{gpuIndex};
                        valueTemp = 1/energy;
                        if valueTemp > valueMax
                            valueMax = valueTemp;
                            tasksArray = [tasksArray; taskIndex, serverIndex, tasksArray(1,3), gpuIndex, gpu_valid, execTime, periodTasks(taskID), gpuID];
                            virtualMachinesTemp = virtualMachines;
                            virtualMachinesTemp{i} = tasksArray;
                            assignInsert{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = virtualMachinesTemp;
                            valueInsert{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = valueTemp;
                            passFlag = 1;
                        end
                    end
                end
            end
        end
    end
end

if ~passFlag
    assignInsert{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = [];
    valueInsert{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = 0;
end