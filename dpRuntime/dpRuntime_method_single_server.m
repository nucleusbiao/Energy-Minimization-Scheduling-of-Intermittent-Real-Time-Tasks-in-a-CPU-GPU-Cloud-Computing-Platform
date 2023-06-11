clc
clear
%% varyingTaskNumSingleServer
energyArrayDPRuntimeVaryingTaskNumSingleServer = zeros(10, 100);
succArrayDPRuntimeVaryingTaskNumSingleServer = zeros(10, 100);
comTimeArrayDPRuntimeVaryingTaskNumSingleServer = zeros(10, 100);

for num_tasks = 2:2:20
    num_tasks
    for times = 1:100
        eval(['load ..\data\varyingTaskNumSingleServer\varyingTaskNumSingleServerTasks',num2str(num_tasks),'Times',num2str(times),';']);
        times
        tic;
        succ = 1;
        
        virtualMachinesInServer = {};
        valueVMs = {};
        
        tasksInterval = sortAppearAscendFuc(TaskIneravls); 
        for i = 1:num_server
            tasksIDinServer{i} = [];
        end
        
        tasksInServer = zeros(1, num_server);
        energyInServer = zeros(1, num_server);
        for i = 1:size(tasksInterval, 1) 
            energyMax = inf;
            timeStart = tasksInterval(i,2);
            deleteTaskIDs = taskRemoveFuc(tasksInterval, timeStart);
            if ~isempty(deleteTaskIDs)
                [virtualMachinesInServer, valueVMs, tasksIDinServer, tasksInServer] = updateVirtualMachinesByTimeFuc(virtualMachinesInServer, valueVMs, deleteTaskIDs, tasksIDinServer);
            end
            for j = 1:num_server
                valueServerJ = 0;
                if isequal(i, 1)
                    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                else
                    [virtualMachinesInServer, valueVMs] = assignIntoVirtualMachinesFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                end
                if 1/valueServerJ - energyInServer(j) < energyMax
                    energyMax = 1/valueServerJ - energyInServer(j);
                    serverHoldTaskIndex = j;
                    valueHoldTaskIndex = valueServerJ;
                end
            end
            if isequal(energyMax, inf)
                display('failure');
                succ = 0;
                break
            else
                tasksInServer(serverHoldTaskIndex) = tasksInServer(serverHoldTaskIndex) + 1;
                if 1/valueHoldTaskIndex - energyInServer(serverHoldTaskIndex) < 0
                    error('problem occurs;');
                else
                    energyInServer(serverHoldTaskIndex) = 1/valueHoldTaskIndex;
                end
                tasksIDinServer{serverHoldTaskIndex} = [tasksIDinServer{serverHoldTaskIndex}, i];
                [virtualMachinesInServer, valueVMs] = updateVMsValueFuc(virtualMachinesInServer, valueVMs, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);
            end
        end
        endTime = toc;
        energyArrayDPRuntimeVaryingTaskNumSingleServer(num_tasks/2, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayDPRuntimeVaryingTaskNumSingleServer(num_tasks/2, times) = succ;
        comTimeArrayDPRuntimeVaryingTaskNumSingleServer(num_tasks/2, times) = endTime;
    end
    save('energyArrayDPRuntimeVaryingTaskNumSingleServer', 'energyArrayDPRuntimeVaryingTaskNumSingleServer')
    save('succArrayDPRuntimeVaryingTaskNumSingleServer', 'succArrayDPRuntimeVaryingTaskNumSingleServer')
    save('comTimeArrayDPRuntimeVaryingTaskNumSingleServer', 'comTimeArrayDPRuntimeVaryingTaskNumSingleServer')
end

%% varyingVCPUSingleServer
clc
clear
energyArrayDPRuntimeVaryingVCPUSingleServer = zeros(10, 100);
succArrayDPRuntimeVaryingVCPUSingleServer = zeros(10, 100);
comTimeArrayDPRuntimeVaryingVCPUSingleServer = zeros(10, 100);

for VCPUs = 10:10:100
    VCPUs
    for times = 1:100
        eval(['load ..\data\varyingVCPUSingleServer\varyingVCPUSingleServerVCPUs',num2str(VCPUs),'Times',num2str(times),';']);
        times
        tic;
        succ = 1;
        
        virtualMachinesInServer = {}; 
        valueVMs = {};
        
        tasksInterval = sortAppearAscendFuc(TaskIneravls); 
        for i = 1:num_server
            tasksIDinServer{i} = [];
        end
        
        tasksInServer = zeros(1, num_server);
        energyInServer = zeros(1, num_server);
        for i = 1:size(tasksInterval, 1) 
            energyMax = inf;
            timeStart = tasksInterval(i,2);
            deleteTaskIDs = taskRemoveFuc(tasksInterval, timeStart);
            if ~isempty(deleteTaskIDs)
                [virtualMachinesInServer, valueVMs, tasksIDinServer, tasksInServer] = updateVirtualMachinesByTimeFuc(virtualMachinesInServer, valueVMs, deleteTaskIDs, tasksIDinServer);
            end
            for j = 1:num_server
                valueServerJ = 0;
                if isequal(i, 1)
                    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                else
                    [virtualMachinesInServer, valueVMs] = assignIntoVirtualMachinesFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                end
                if 1/valueServerJ - energyInServer(j) < energyMax
                    energyMax = 1/valueServerJ - energyInServer(j);
                    serverHoldTaskIndex = j;
                    valueHoldTaskIndex = valueServerJ;
                end
            end
            if isequal(energyMax, inf)
                display('failure');
                succ = 0;
                break
            else
                tasksInServer(serverHoldTaskIndex) = tasksInServer(serverHoldTaskIndex) + 1;
                if 1/valueHoldTaskIndex - energyInServer(serverHoldTaskIndex) < 0
                    error('problem occurs;');
                else
                    energyInServer(serverHoldTaskIndex) = 1/valueHoldTaskIndex;
                end
                tasksIDinServer{serverHoldTaskIndex} = [tasksIDinServer{serverHoldTaskIndex}, i];
                [virtualMachinesInServer, valueVMs] = updateVMsValueFuc(virtualMachinesInServer, valueVMs, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);
            end
        end
        endTime = toc;
        energyArrayDPRuntimeVaryingVCPUSingleServer(VCPUs/10, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayDPRuntimeVaryingVCPUSingleServer(VCPUs/10, times) = succ;
        comTimeArrayDPRuntimeVaryingVCPUSingleServer(VCPUs/10, times) = endTime;
    end
    save('energyArrayDPRuntimeVaryingVCPUSingleServer','energyArrayDPRuntimeVaryingVCPUSingleServer')
    save('succArrayDPRuntimeVaryingVCPUSingleServer','succArrayDPRuntimeVaryingVCPUSingleServer')
    save('comTimeArrayDPRuntimeVaryingVCPUSingleServer','comTimeArrayDPRuntimeVaryingVCPUSingleServer')
end

%% varyingIntervalCountSingleServer
clc
clear
energyArrayDPRuntimeVaryingIntervalCountSingleServer = zeros(10, 100);
succArrayDPRuntimeVaryingIntervalCountSingleServer = zeros(10, 100);
comTimeArrayDPRuntimeVaryingIntervalCountSingleServer = zeros(10, 100);

for numInterval = 10:10:100
    numInterval
    for times = 1:100
        eval(['load ..\data\varyingIntervalCountSingleServer\varyingIntervalCountSingleServerInterval',num2str(numInterval),'Times',num2str(times),';']);
        times
        tic;
        succ = 1;
        
        virtualMachinesInServer = {};
        valueVMs = {};
        
        tasksInterval = sortAppearAscendFuc(TaskIneravls); 
        for i = 1:num_server
            tasksIDinServer{i} = [];
        end
        
        tasksInServer = zeros(1, num_server);
        energyInServer = zeros(1, num_server);
        for i = 1:size(tasksInterval, 1)
            energyMax = inf;
            timeStart = tasksInterval(i,2);
            deleteTaskIDs = taskRemoveFuc(tasksInterval, timeStart);
            if ~isempty(deleteTaskIDs)
                [virtualMachinesInServer, valueVMs, tasksIDinServer, tasksInServer] = updateVirtualMachinesByTimeFuc(virtualMachinesInServer, valueVMs, deleteTaskIDs, tasksIDinServer);
            end
            for j = 1:num_server
                valueServerJ = 0;
                if isequal(i, 1)
                    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                else
                    [virtualMachinesInServer, valueVMs] = assignIntoVirtualMachinesFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                end
                if 1/valueServerJ - energyInServer(j) < energyMax
                    energyMax = 1/valueServerJ - energyInServer(j);
                    serverHoldTaskIndex = j;
                    valueHoldTaskIndex = valueServerJ;
                end
            end
            if isequal(energyMax, inf)
                display('failure');
                succ = 0;
                break
            else
                tasksInServer(serverHoldTaskIndex) = tasksInServer(serverHoldTaskIndex) + 1;
                if 1/valueHoldTaskIndex - energyInServer(serverHoldTaskIndex) < 0
                    error('problem occurs;');
                else
                    energyInServer(serverHoldTaskIndex) = 1/valueHoldTaskIndex;
                end
                tasksIDinServer{serverHoldTaskIndex} = [tasksIDinServer{serverHoldTaskIndex}, i];
                [virtualMachinesInServer, valueVMs] = updateVMsValueFuc(virtualMachinesInServer, valueVMs, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);
            end
        end
        endTime = toc;
        energyArrayDPRuntimeVaryingIntervalCountSingleServer(numInterval/10, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayDPRuntimeVaryingIntervalCountSingleServer(numInterval/10, times) = succ;
        comTimeArrayDPRuntimeVaryingIntervalCountSingleServer(numInterval/10, times) = endTime;
    end
    save('energyArrayDPRuntimeVaryingIntervalCountSingleServer','energyArrayDPRuntimeVaryingIntervalCountSingleServer')
    save('succArrayDPRuntimeVaryingIntervalCountSingleServer','succArrayDPRuntimeVaryingIntervalCountSingleServer')
    save('comTimeArrayDPRuntimeVaryingIntervalCountSingleServer','comTimeArrayDPRuntimeVaryingIntervalCountSingleServer')
end