function [assignCreateNewVM, valueCreateNewVM]=CreateNewVM(tasksInterval, taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, periodTasks, totalLoadCpus, ...
    loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, tasksInServer, Assign, value)

valueCreateNewVM = value;
valueCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = 0;
assignCreateNewVM = Assign;
assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = Assign{taskIndex-1}{serverIndex}{vCPUs}{gpuIndex};

taskID = tasksInterval(taskIndex, 1);
intervalLength = tasksInterval(taskIndex, 3) - tasksInterval(taskIndex, 2);

% 仅用CPU处理的情况
valueMax = 0;
passFlag = 0;
for usedCPUs = 1:vCPUs
    execTime = totalLoadCpus(taskID)/lamdaMatrix(taskID, serverIndex)/usedCPUs;
    if execTime < periodTasks(taskID)
        power = alpha(serverIndex)*usedCPUs;
        energy = power*intervalLength*execTime/periodTasks(taskID);
        if vCPUs-usedCPUs > 0
            energy = energy + 1/value{taskIndex-1}{serverIndex}{vCPUs-usedCPUs}{gpuIndex};
        end
        valueTemp = 1/energy;
        if valueTemp > valueMax            
            if vCPUs-usedCPUs > 0
                assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = Assign{taskIndex-1}{serverIndex}{vCPUs-usedCPUs}{gpuIndex};
                sizeVM = size(assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex}, 2);
                taskSizeVM = 0;
                for iSizeVM = 1:sizeVM
                    arraryTempSizeVM = assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex}{iSizeVM};
                    taskSizeVM = taskSizeVM + size(arraryTempSizeVM, 1);
                end
                if isequal(taskSizeVM, tasksInServer(serverIndex))
                    assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex}{sizeVM+1} = [taskIndex, serverIndex, usedCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), 0];
                    valueCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = valueTemp;
                    valueMax = valueTemp;
                    passFlag = 1;
                else
                    assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = [];
                    valueCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = 0;
                end
            elseif isequal(tasksInServer(serverIndex), 0)
                assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex}{1} = [taskIndex, serverIndex, usedCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), 0];
                valueCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = valueTemp;
                passFlag = 1;
                valueMax = valueTemp;
            elseif ~passFlag
                assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = [];
                valueCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = 0;
            end
            
        end
    end
end

% 采用CPU和GPU一同处理
passFlag = 0;
for i = 1:size(gpu_valid, 2)    
    if isequal(gpu_valid(i), 1)
        gpuID = i;
        gpu_valid_inverse = gpu_valid;
        gpu_valid_inverse(i) = 0;
        gpuIndexInverse = 1;
        
        for ii = 1:size(gpu_valid_inverse, 2) % 计算占用gpuID后剩下的gpu集合对应的gpu指数
            gpuIndexInverse = gpuIndexInverse + 2^(ii-1)*gpu_valid_inverse(ii);
        end
        
        for usedCPUs = 1:vCPUs
            power = alpha(serverIndex)*usedCPUs;
            execTime = loadCPU(taskID)/lamdaMatrix(taskID, serverIndex)/usedCPUs + loadGPU(taskID)/chiMatrix{taskID}{serverIndex}{gpuID};
            if execTime < periodTasks(taskID)
                power = power + powerMatrix{serverIndex}{gpuID};
                energy = power*intervalLength*execTime/periodTasks(taskID);
                if usedCPUs < vCPUs
                    energy = energy + 1/value{taskIndex-1}{serverIndex}{vCPUs-usedCPUs}{gpuIndexInverse};
                end
                valueTemp = 1/energy;
                if valueTemp > valueMax
                    valueMax = valueTemp;
                    if vCPUs-usedCPUs > 0
                        assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = Assign{taskIndex-1}{serverIndex}{vCPUs-usedCPUs}{gpuIndex};
                        sizeVM = size(assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex}, 2);
                        taskSizeVM = 0;
                        for iSizeVM = 1:sizeVM
                            arraryTempSizeVM = assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex}{iSizeVM};
                            taskSizeVM = taskSizeVM + size(arraryTempSizeVM, 1);
                        end
                        if isequal(taskSizeVM, tasksInServer(serverIndex))
                            assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex}{sizeVM+1} = [taskIndex, serverIndex, usedCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), i];
                            valueCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = valueTemp;
                            passFlag = 1;
                            valueMax = valueTemp;
                        else
                            assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = [];
                            valueCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = 0;
                        end
                    elseif isequal(tasksInServer(serverIndex), 0)
                        assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex}{1} = [taskIndex, serverIndex, usedCPUs, gpuIndex, gpu_valid, execTime, periodTasks(taskID), i];
                        valueCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = valueTemp;
                        passFlag = 1;
                        valueMax = valueTemp;
                    elseif ~passFlag
                        assignCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = [];
                        valueCreateNewVM{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = 0;
                    end
                end
            end
        end
    end
end