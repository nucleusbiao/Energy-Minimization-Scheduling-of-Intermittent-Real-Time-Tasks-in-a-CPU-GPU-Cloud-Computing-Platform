clc
clear
%% 输入数据
num_server = 2; % 服务器数量
vCPUs_server = [4, 6]; % 各服务器中vCPU数量
GPUs_server = [2, 3]; % 各服务器里的GPU数量
num_tasks = 5; % 任务数量
periodTasks = [2, 2, 3, 3, 5]; % 任务周期
totalLoadCpus = [6, 4, 3, 2, 4]; % 各任务纯CPU执行下的workload
loadCPU = [2, 2, 2, 1, 2]; % 任务若在CPU和GPU共同执行时，在CPU部分的workload
loadGPU = [1, 1, 1, 1, 1]; % 任务若在CPU和GPU共同执行时，在GPU部分的workload
TaskIneravls{1} = [0 3; 6 8; 9 10; 15 20]; % 任务1存在的区间
TaskIneravls{2} = [0 2; 4 7; 8 11]; % 任务2存在的区间
TaskIneravls{3} = [0 8; 18 25]; % 任务3存在的区间
TaskIneravls{4} = [0 1; 4 8; 9 15; 25 28]; % 任务4存在的区间
TaskIneravls{5} = [0 15]; % 任务5存在的区间
lamdaMatrix = [3     1     2     1     3;
               3     3     1     2     3]'; % 任务Ti在各服务器上的执行效率
for i = 1:num_tasks % 任务Ti在各服务器上的GPU执行效率
    for j = 1:num_server
        for k = 1:GPUs_server(j)
            chiMatrix{i}{j}{k} = 10 + randi(10);
        end
    end
end
alpha = [3, 5]; % 各服务器执行的功耗常数
for j = 1:num_server % 各服务器里GPU的功耗常数
    for k = 1:GPUs_server(j)
        powerMatrix{j}{k} = 5 + randi(5);
    end
end

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
    else
        tasksInServer(serverHoldTaskIndex) = tasksInServer(serverHoldTaskIndex) + 1;
        energyInServer(serverHoldTaskIndex) = 1/valueHoldTaskIndex;
        tasksIDinServer{serverHoldTaskIndex} = [tasksIDinServer{serverHoldTaskIndex}, i];
        [virtualMachinesInServer, valueVMs] = updateVMsValueFuc(virtualMachinesInServer, valueVMs, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);  
        tasksInServer
        energyInServer
    end
end