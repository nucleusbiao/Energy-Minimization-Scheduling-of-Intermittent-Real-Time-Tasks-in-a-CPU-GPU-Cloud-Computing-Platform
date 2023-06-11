%% varyingServers
clc
clear
energyArrayGreedyTwoVaryingServers = zeros(10, 100);
succArrayGreedyTwoVaryingServers = zeros(10, 100);
comTimeArrayGreedyTwoVaryingServers = zeros(10, 100);

for num_server = 1:10
    num_server
    for times = 1:100
        eval(['load ..\data\varyingServersCount\varyingServersCount', num2str(num_server),'Times',num2str(times),';']);
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
        energyArrayGreedyTwoVaryingServers(num_server, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayGreedyTwoVaryingServers(num_server, times) = succ;
        comTimeArrayGreedyTwoVaryingServers(num_server, times) = endTime;
    end
    save('energyArrayGreedyTwoVaryingServers','energyArrayGreedyTwoVaryingServers')
    save('succArrayGreedyTwoVaryingServers','succArrayGreedyTwoVaryingServers')
    save('comTimeArrayGreedyTwoVaryingServers','comTimeArrayGreedyTwoVaryingServers')
end