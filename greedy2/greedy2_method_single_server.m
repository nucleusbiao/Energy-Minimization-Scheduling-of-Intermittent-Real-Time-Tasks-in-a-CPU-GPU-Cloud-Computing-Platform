clc
clear
%% varyingTaskNumSingleServer
energyArrayGreedy2VaryingTaskNumSingleServer = zeros(10, 100);
succArrayGreedy2VaryingTaskNumSingleServer = zeros(10, 100);
comTimeArrayGreedy2VaryingTaskNumSingleServer = zeros(10, 100);

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
                    [virtualMachinesInServer, valueVMs] = createVMGreedyTwoFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                else
                    [virtualMachinesInServer, valueVMs] = assignIntoVMGreedyTwoFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
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
        energyArrayGreedy2VaryingTaskNumSingleServer(num_tasks/2, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayGreedy2VaryingTaskNumSingleServer(num_tasks/2, times) = succ;
        comTimeArrayGreedy2VaryingTaskNumSingleServer(num_tasks/2, times) = endTime;
    end
    save('energyArrayGreedy2VaryingTaskNumSingleServer', 'energyArrayGreedy2VaryingTaskNumSingleServer')
    save('succArrayGreedy2VaryingTaskNumSingleServer', 'succArrayGreedy2VaryingTaskNumSingleServer')
    save('comTimeArrayGreedy2VaryingTaskNumSingleServer', 'comTimeArrayGreedy2VaryingTaskNumSingleServer')
end

%% varyingVCPUSingleServer
clc
clear
energyArrayGreedy2VaryingVCPUSingleServer = zeros(10, 100);
succArrayGreedy2VaryingVCPUSingleServer = zeros(10, 100);
comTimeArrayGreedy2VaryingVCPUSingleServer = zeros(10, 100);

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
                    [virtualMachinesInServer, valueVMs] = createVMGreedyTwoFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                else
                    [virtualMachinesInServer, valueVMs] = assignIntoVMGreedyTwoFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
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
        energyArrayGreedy2VaryingVCPUSingleServer(VCPUs/10, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayGreedy2VaryingVCPUSingleServer(VCPUs/10, times) = succ;
        comTimeArrayGreedy2VaryingVCPUSingleServer(VCPUs/10, times) = endTime;
    end
    save('energyArrayGreedy2VaryingVCPUSingleServer','energyArrayGreedy2VaryingVCPUSingleServer')
    save('succArrayGreedy2VaryingVCPUSingleServer','succArrayGreedy2VaryingVCPUSingleServer')
    save('comTimeArrayGreedy2VaryingVCPUSingleServer','comTimeArrayGreedy2VaryingVCPUSingleServer')
end


%% varyingIntervalCountSingleServer
clc
clear
energyArrayGreedy2VaryingIntervalCountSingleServer = zeros(10, 100);
succArrayGreedy2VaryingIntervalCountSingleServer = zeros(10, 100);
comTimeArrayGreedy2VaryingIntervalCountSingleServer = zeros(10, 100);

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
                    [virtualMachinesInServer, valueVMs] = createVMGreedyTwoFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, virtualMachinesInServer, valueVMs);
                    valueSpecific = valueVMs{i}{j};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                else
                    [virtualMachinesInServer, valueVMs] = assignIntoVMGreedyTwoFuc(tasksInterval, i, j, vCPUs_server, GPUs_server, periodTasks, totalLoadCpus, ...
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
        energyArrayGreedy2VaryingIntervalCountSingleServer(numInterval/10, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayGreedy2VaryingIntervalCountSingleServer(numInterval/10, times) = succ;
        comTimeArrayGreedy2VaryingIntervalCountSingleServer(numInterval/10, times) = endTime;
    end
    save('energyArrayGreedy2VaryingIntervalCountSingleServer','energyArrayGreedy2VaryingIntervalCountSingleServer')
    save('succArrayGreedy2VaryingIntervalCountSingleServer','succArrayGreedy2VaryingIntervalCountSingleServer')
    save('comTimeArrayGreedy2VaryingIntervalCountSingleServer','comTimeArrayGreedy2VaryingIntervalCountSingleServer')
end