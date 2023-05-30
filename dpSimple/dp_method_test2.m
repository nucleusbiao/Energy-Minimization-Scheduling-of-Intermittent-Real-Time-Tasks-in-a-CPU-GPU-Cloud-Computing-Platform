%% ��������
clc
clear
num_server = 10; % ����������
vCPUs_server = 20*ones(1, num_server); % 5+randi(5, 1, num_server); % ����������vCPU����
GPUs_server = 1+randi(2, 1, num_server); % �����������GPU����
num_tasks = 50; % ��������
periodTasks = (50 + randi(50, 1, num_tasks))*0.001; % ��������
totalLoadCpus = (100 + randi(400, 1, num_tasks))*0.001; % ������CPUִ���µ�workload
loadCPU = totalLoadCpus./(1+randi(4, 1, num_tasks)); % ��������CPU��GPU��ִͬ��ʱ����CPU���ֵ�workload
loadGPU = totalLoadCpus - loadCPU; % ��������CPU��GPU��ִͬ��ʱ����GPU���ֵ�workload
for iInterval = 1:num_tasks
    numInterval = 10+randi(50);
    timeStamp = sort([0, randperm(3600, 2*numInterval-1)], 'ascend');
    TaskIneravls{iInterval} = [];
    for rowInterval = 1:numInterval
        TaskIneravls{iInterval} = [TaskIneravls{iInterval}; timeStamp(2*rowInterval-1), timeStamp(2*rowInterval)];
    end
end
lamdaMatrix = (10+randi(30, num_tasks, num_server))/20; % ����Ti�ڸ��������ϵ�ִ��Ч��
for i = 1:num_tasks % ����Ti�ڸ��������ϵ�GPUִ��Ч��
    for j = 1:num_server
        for k = 1:GPUs_server(j)
            chiMatrix{i}{j}{k} = 10 + randi(10);
        end
    end
end
alpha = 10+randi(5, 1, num_server); % ��������ִ�еĹ��ĳ���
for j = 1:num_server % ����������GPU�Ĺ��ĳ���
    for k = 1:GPUs_server(j)
        powerMatrix{j}{k} = 60 + randi(20);
    end
end

%% �㷨
Assign = {};%����һ���յ�Ԫ������
value = {};
value_temp = [];

tasksInterval = sortAppearAscendFuc(TaskIneravls); % ������������ֵĿ�ʼʱ����������
for i = 1:num_server
    tasksIDinServer{i} = [];
end

tasksInServer = zeros(1, num_server);
energyInServer = zeros(1, num_server);
for i = 1:size(tasksInterval, 1) % ��������
    energyMax = inf;
    timeStart = tasksInterval(i,2);
    deleteTaskIDs = taskRemoveFuc(tasksInterval, timeStart);
    if ~isempty(deleteTaskIDs)
        [Assign, value, tasksIDinServer, tasksInServer] = updateAccordingToAppearTimeFuc(Assign, value, deleteTaskIDs, tasksIDinServer);
    end
    serverPickUpOrder = serverPrioritizeFuc(tasksIDinServer, tasksInterval, periodTasks, totalLoadCpus);
    for j = serverPickUpOrder
        valueServerJ = 0;
        for Cx = 1:vCPUs_server(j)
            num_gpu = GPUs_server(j);
            for k = 2^num_gpu % ����gpu���������
                gpu_valid = interpretK(k, num_gpu);
                if isequal(i,1) % ���ڵ��ȵĵ�1������
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
            break
        end
    end
    if isequal(energyMax, inf)
        display('failure');
        break
    else
        if 1/valueHoldTaskIndex - energyInServer(serverHoldTaskIndex) < 0
            error('problem occurs;');
        else
            energyInServer(serverHoldTaskIndex) = 1/valueHoldTaskIndex;
        end
        tasksInServer(serverHoldTaskIndex) = tasksInServer(serverHoldTaskIndex) + 1;
        tasksIDinServer{serverHoldTaskIndex} = [tasksIDinServer{serverHoldTaskIndex}, i];
        [Assign, value] = updateAssignValueFuc(Assign, value, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);
        tasksInServer
        energyInServer
    end
end