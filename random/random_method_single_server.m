clc
clear
%% varyingTaskNumSingleServer
energyArrayRandomVaryingTaskNumSingleServer = zeros(10, 100);
succArrayRandomVaryingTaskNumSingleServer = zeros(10, 100);
comTimeArrayRandomVaryingTaskNumSingleServer = zeros(10, 100);

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
            serverOrderArray = randperm(num_server, num_server);
            for j = serverOrderArray
                valueServerJ = 0;
                if isequal(i, 1)
                    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesRandomFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
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
                    break
                end
            end
            if isequal(energyMax, inf)
                display('failure');
                succ = 0;
                break
            else
                tasksInServer(serverHoldTaskIndex) = tasksInServer(serverHoldTaskIndex) + 1;
                energyInServer(serverHoldTaskIndex) = 1/valueHoldTaskIndex;
                tasksIDinServer{serverHoldTaskIndex} = [tasksIDinServer{serverHoldTaskIndex}, i];
                [virtualMachinesInServer, valueVMs] = updateVMsValueFuc(virtualMachinesInServer, valueVMs, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);
            end
        end
        endTime = toc;
        energyArrayRandomVaryingTaskNumSingleServer(num_tasks/2, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayRandomVaryingTaskNumSingleServer(num_tasks/2, times) = succ;
        comTimeArrayRandomVaryingTaskNumSingleServer(num_tasks/2, times) = endTime;
    end
    save('energyArrayRandomVaryingTaskNumSingleServer', 'energyArrayRandomVaryingTaskNumSingleServer')
    save('succArrayRandomVaryingTaskNumSingleServer', 'succArrayRandomVaryingTaskNumSingleServer')
    save('comTimeArrayRandomVaryingTaskNumSingleServer', 'comTimeArrayRandomVaryingTaskNumSingleServer')
end

%% varyingVCPUSingleServer
clc
clear
energyArrayRandomVaryingVCPUSingleServer = zeros(10, 100);
succArrayRandomVaryingVCPUSingleServer = zeros(10, 100);
comTimeArrayRandomVaryingVCPUSingleServer = zeros(10, 100);

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
            serverOrderArray = randperm(num_server, num_server);
            for j = serverOrderArray
                valueServerJ = 0;
                if isequal(i, 1)
                    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesRandomFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
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
                    break
                end
            end
            if isequal(energyMax, inf)
                display('failure');
                succ = 0;
                break
            else
                tasksInServer(serverHoldTaskIndex) = tasksInServer(serverHoldTaskIndex) + 1;
                energyInServer(serverHoldTaskIndex) = 1/valueHoldTaskIndex;
                tasksIDinServer{serverHoldTaskIndex} = [tasksIDinServer{serverHoldTaskIndex}, i];
                [virtualMachinesInServer, valueVMs] = updateVMsValueFuc(virtualMachinesInServer, valueVMs, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);
            end
        end
        endTime = toc;
        energyArrayRandomVaryingVCPUSingleServer(VCPUs/10, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayRandomVaryingVCPUSingleServer(VCPUs/10, times) = succ;
        comTimeArrayRandomVaryingVCPUSingleServer(VCPUs/10, times) = endTime;
    end
    save('energyArrayRandomVaryingVCPUSingleServer','energyArrayRandomVaryingVCPUSingleServer')
    save('succArrayRandomVaryingVCPUSingleServer','succArrayRandomVaryingVCPUSingleServer')
    save('comTimeArrayRandomVaryingVCPUSingleServer','comTimeArrayRandomVaryingVCPUSingleServer')
end

%% varyingIntervalCountSingleServer
clc
clear
energyArrayRandomVaryingIntervalCountSingleServer = zeros(10, 100);
succArrayRandomVaryingIntervalCountSingleServer = zeros(10, 100);
comTimeArrayRandomVaryingIntervalCountSingleServer = zeros(10, 100);

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
            serverOrderArray = randperm(num_server, num_server);
            for j = serverOrderArray
                valueServerJ = 0;
                if isequal(i, 1)
                    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesRandomFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
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
                    break
                end
            end
            if isequal(energyMax, inf)
                display('failure');
                succ = 0;
                break
            else
                tasksInServer(serverHoldTaskIndex) = tasksInServer(serverHoldTaskIndex) + 1;
                energyInServer(serverHoldTaskIndex) = 1/valueHoldTaskIndex;
                tasksIDinServer{serverHoldTaskIndex} = [tasksIDinServer{serverHoldTaskIndex}, i];
                [virtualMachinesInServer, valueVMs] = updateVMsValueFuc(virtualMachinesInServer, valueVMs, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);
            end
        end
        endTime = toc;
        energyArrayRandomVaryingIntervalCountSingleServer(numInterval/10, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayRandomVaryingIntervalCountSingleServer(numInterval/10, times) = succ;
        comTimeArrayRandomVaryingIntervalCountSingleServer(numInterval/10, times) = endTime;
    end
    save('energyArrayRandomVaryingIntervalCountSingleServer','energyArrayRandomVaryingIntervalCountSingleServer')
    save('succArrayRandomVaryingIntervalCountSingleServer','succArrayRandomVaryingIntervalCountSingleServer')
    save('comTimeArrayRandomVaryingIntervalCountSingleServer','comTimeArrayRandomVaryingIntervalCountSingleServer')
end