%% 输入数据
clc
clear
num_server = 10; % 服务器数量
vCPUs_server = 20*ones(1, num_server); % 5+randi(5, 1, num_server); % 各服务器中vCPU数量
GPUs_server = 1+randi(2, 1, num_server); % 各服务器里的GPU数量
num_tasks = 50; % 任务数量
periodTasks = (50 + randi(50, 1, num_tasks))*0.001; % 任务周期
totalLoadCpus = (100 + randi(400, 1, num_tasks))*0.001; % 各任务纯CPU执行下的workload
loadCPU = totalLoadCpus./(1+randi(4, 1, num_tasks)); % 任务若在CPU和GPU共同执行时，在CPU部分的workload
loadGPU = totalLoadCpus - loadCPU; % 任务若在CPU和GPU共同执行时，在GPU部分的workload
for iInterval = 1:num_tasks
    numInterval = 10+randi(50);
    timeStamp = sort([0, randperm(3600, 2*numInterval-1)], 'ascend');
    TaskIneravls{iInterval} = [];
    for rowInterval = 1:numInterval
        TaskIneravls{iInterval} = [TaskIneravls{iInterval}; timeStamp(2*rowInterval-1), timeStamp(2*rowInterval)];
    end
end
lamdaMatrix = (10+randi(30, num_tasks, num_server))/20; % 任务Ti在各服务器上的执行效率
for i = 1:num_tasks % 任务Ti在各服务器上的GPU执行效率
    for j = 1:num_server
        for k = 1:GPUs_server(j)
            chiMatrix{i}{j}{k} = 10 + randi(10);
        end
    end
end
alpha = 10+randi(5, 1, num_server); % 各服务器执行的功耗常数
for j = 1:num_server % 各服务器里GPU的功耗常数
    for k = 1:GPUs_server(j)
        powerMatrix{j}{k} = 60 + randi(20);
    end
end
save all
%% 算法
virtualMachinesInServer = {};%创建一个空的元胞数组
valueVMs = {};

tasksInterval = sortAppearAscendFuc(TaskIneravls); % 按任务区间出现的开始时间重新排序
for i = 1:num_server
    tasksIDinServer{i} = [];
end

tasksInServer = zeros(1, num_server);
energyInServer = zeros(1, num_server);
for i = 1:size(tasksInterval, 1) % 遍历任务
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
        tasksInServer
        energyInServer
    end
end
