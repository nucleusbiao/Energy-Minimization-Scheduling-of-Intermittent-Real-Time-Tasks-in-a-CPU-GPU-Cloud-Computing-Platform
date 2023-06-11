function [Assign,value] = Assign_Other_Tasks(tasksInterval, taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, periodTasks, totalLoadCpus, ...
    loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, tasksInServer, energyInServer, Assign, value)


if isempty(Assign{taskIndex-1}{serverIndex}{vCPUs}{gpuIndex}) % 若是空集，则只有创建一个全新的virutal machine这一种动作
    if isequal(tasksInServer(serverIndex), 0)
        [Assign,value] = Assign_In_Empty_New(tasksInterval, taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, periodTasks, totalLoadCpus, ...
        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, Assign,value);
    else
        Assign{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = [];
        value{taskIndex}{serverIndex}{vCPUs}{gpuIndex} = 0;
    end
else
    % 创建一个新的virtual machine
    [AssignCreateThreads,valueCreateThreads]=CreateNewVM(tasksInterval, taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, periodTasks, totalLoadCpus, ...
    loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, tasksInServer, Assign, value);

    % 插入到原有virtual machine中
    [AssignInsert,valueInsert]=InsertVM(tasksInterval, taskIndex, serverIndex, vCPUs, gpuIndex, gpu_valid, periodTasks, totalLoadCpus, ...
    loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, Assign, value);
    
    if valueCreateThreads{taskIndex}{serverIndex}{vCPUs}{gpuIndex} > valueInsert{taskIndex}{serverIndex}{vCPUs}{gpuIndex}
        Assign = AssignCreateThreads;
        value = valueCreateThreads;
    else
        Assign = AssignInsert;
        value = valueInsert;        
    end
end
   