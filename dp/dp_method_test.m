clc
clear
%% inputs
num_server = 2; % number of servers
vCPUs_server = [4, 6]; % number of vCPUs in each server
GPUs_server = [2, 3]; % number of servers in each server
num_tasks = 5; % number of tasks
periodTasks = [2, 2, 3, 3, 5]; % period of tasks
totalLoadCpus = [6, 4, 3, 2, 4]; % workload of tasks processed by CPU
loadCPU = [2, 2, 2, 1, 2]; % CPU workload of tasks processed by CPU and GPU together
loadGPU = [1, 1, 1, 1, 1]; % GPU workload of tasks processed by CPU and GPU together
TaskIneravls{1} = [0 3; 6 8; 9 10; 15 20]; % intervals of task 1
TaskIneravls{2} = [0 2; 4 7; 8 11]; % intervals of task 2
TaskIneravls{3} = [0 8; 18 25]; % intervals of task 3
TaskIneravls{4} = [0 1; 4 8; 9 15; 25 28]; % intervals of task 4
TaskIneravls{5} = [0 15]; % intervals of task 5
lamdaMatrix = [3     1     2     1     3;
               3     3     1     2     3]'; % execution efficiency of task on servers
for i = 1:num_tasks % computing efficiency of a task on a GPU of a server
    for j = 1:num_server
        for k = 1:GPUs_server(j)
            chiMatrix{i}{j}{k} = 10 + randi(10);
        end
    end
end
alpha = [3, 5]; %  power constant that depends on the server
for j = 1:num_server % GPU power in each server
    for k = 1:GPUs_server(j)
        powerMatrix{j}{k} = 5 + randi(5);
    end
end

%% algorithm
Assign = {};%create an cell to store schedules
value = {};
value_temp = [];

tasksInterval = sortAppearAscendFuc(TaskIneravls); % Sort by start time of task interval occurrence
for i = 1:num_server
    tasksIDinServer{i} = [];
end

tasksInServer = zeros(1, num_server);
energyInServer = zeros(1, num_server);
for i = 1:size(tasksInterval, 1) % Traversal tasks
    energyMax = inf;
    timeStart = tasksInterval(i,2);
    deleteTaskIDs = taskRemoveFuc(tasksInterval, timeStart);
    if ~isempty(deleteTaskIDs)
        [Assign, value, tasksIDinServer, tasksInServer] = updateAccordingToAppearTimeFuc(Assign, value, deleteTaskIDs, tasksIDinServer);
    end
    for j = 1:num_server
        valueServerJ = 0;
        for Cx = 1:vCPUs_server(j)
            num_gpu = GPUs_server(j);
            for k = 1:2^num_gpu % Iterate over all cases of gpu
                gpu_valid = interpretK(k, num_gpu);
                if isequal(i,1) % the first task that needs to be scheduled
                    [Assign, value] = Assign_In_Empty_New(tasksInterval, i, j, Cx, k, gpu_valid, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, energyInServer, Assign, value);
                    valueSpecific = value{i}{j}{Cx}{k};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                else
                    [Assign,value]=Assign_Other_Tasks(tasksInterval, i, j, Cx, k, gpu_valid, periodTasks, totalLoadCpus, ...
                        loadCPU, loadGPU, alpha, lamdaMatrix, chiMatrix, powerMatrix, tasksInServer, energyInServer, Assign, value);
                    valueSpecific = value{i}{j}{Cx}{k};
                    if valueSpecific > valueServerJ
                        valueServerJ = valueSpecific;
                    end
                end
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
    else
        tasksInServer(serverHoldTaskIndex) = tasksInServer(serverHoldTaskIndex) + 1;
        energyInServer(serverHoldTaskIndex) = 1/valueHoldTaskIndex;
        tasksIDinServer{serverHoldTaskIndex} = [tasksIDinServer{serverHoldTaskIndex}, i];
        [Assign, value] = updateAssignValueFuc(Assign, value, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);  
    end
end