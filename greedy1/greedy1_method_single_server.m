clc
clear
%% varyingTaskNumSingleServer
energyArrayGreedy1VaryingTaskNumSingleServer = zeros(10, 100);
succArrayGreedy1VaryingTaskNumSingleServer = zeros(10, 100);
comTimeArrayGreedy1VaryingTaskNumSingleServer = zeros(10, 100);

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
                    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesGreedyOneFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                else
                    [virtualMachinesInServer, valueVMs] = assignIntoVMGreedyOneFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
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
        energyArrayGreedy1VaryingTaskNumSingleServer(num_tasks/2, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayGreedy1VaryingTaskNumSingleServer(num_tasks/2, times) = succ;
        comTimeArrayGreedy1VaryingTaskNumSingleServer(num_tasks/2, times) = endTime;
    end
    save('energyArrayGreedy1VaryingTaskNumSingleServer', 'energyArrayGreedy1VaryingTaskNumSingleServer')
    save('succArrayGreedy1VaryingTaskNumSingleServer', 'succArrayGreedy1VaryingTaskNumSingleServer')
    save('comTimeArrayGreedy1VaryingTaskNumSingleServer', 'comTimeArrayGreedy1VaryingTaskNumSingleServer')
end

%% varyingVCPUSingleServer
clc
clear
energyArrayGreedy1VaryingVCPUSingleServer = zeros(10, 100);
succArrayGreedy1VaryingVCPUSingleServer = zeros(10, 100);
comTimeArrayGreedy1VaryingVCPUSingleServer = zeros(10, 100);

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
                    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesGreedyOneFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                else
                    [virtualMachinesInServer, valueVMs] = assignIntoVMGreedyOneFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
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
        energyArrayGreedy1VaryingVCPUSingleServer(VCPUs/10, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayGreedy1VaryingVCPUSingleServer(VCPUs/10, times) = succ;
        comTimeArrayGreedy1VaryingVCPUSingleServer(VCPUs/10, times) = endTime;
    end
    save('energyArrayGreedy1VaryingVCPUSingleServer','energyArrayGreedy1VaryingVCPUSingleServer')
    save('succArrayGreedy1VaryingVCPUSingleServer','succArrayGreedy1VaryingVCPUSingleServer')
    save('comTimeArrayGreedy1VaryingVCPUSingleServer','comTimeArrayGreedy1VaryingVCPUSingleServer')
end

%% varyingIntervalCountSingleServer
clc
clear
energyArrayGreedy1VaryingIntervalCountSingleServer = zeros(10, 100);
succArrayGreedy1VaryingIntervalCountSingleServer = zeros(10, 100);
comTimeArrayGreedy1VaryingIntervalCountSingleServer = zeros(10, 100);

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
                    [virtualMachinesInServer, valueVMs] = createNewVirtualMachinesGreedyOneFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                else
                    [virtualMachinesInServer, valueVMs] = assignIntoVMGreedyOneFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
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
        energyArrayGreedy1VaryingIntervalCountSingleServer(numInterval/10, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayGreedy1VaryingIntervalCountSingleServer(numInterval/10, times) = succ;
        comTimeArrayGreedy1VaryingIntervalCountSingleServer(numInterval/10, times) = endTime;
    end
    save('energyArrayGreedy1VaryingIntervalCountSingleServer','energyArrayGreedy1VaryingIntervalCountSingleServer')
    save('succArrayGreedy1VaryingIntervalCountSingleServer','succArrayGreedy1VaryingIntervalCountSingleServer')
    save('comTimeArrayGreedy1VaryingIntervalCountSingleServer','comTimeArrayGreedy1VaryingIntervalCountSingleServer')
end