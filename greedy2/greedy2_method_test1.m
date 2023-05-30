clc
clear
%% ��������
num_server = 2; % ����������
vCPUs_server = [4, 6]; % ����������vCPU����
GPUs_server = [2, 3]; % �����������GPU����
num_tasks = 5; % ��������
periodTasks = [2, 2, 3, 3, 5]; % ��������
totalLoadCpus = [6, 4, 3, 2, 4]; % ������CPUִ���µ�workload
loadCPU = [2, 2, 2, 1, 2]; % ��������CPU��GPU��ִͬ��ʱ����CPU���ֵ�workload
loadGPU = [1, 1, 1, 1, 1]; % ��������CPU��GPU��ִͬ��ʱ����GPU���ֵ�workload
TaskIneravls{1} = [0 3; 6 8; 9 10; 15 20]; % ����1���ڵ�����
TaskIneravls{2} = [0 2; 4 7; 8 11]; % ����2���ڵ�����
TaskIneravls{3} = [0 8; 18 25]; % ����3���ڵ�����
TaskIneravls{4} = [0 1; 4 8; 9 15; 25 28]; % ����4���ڵ�����
TaskIneravls{5} = [0 15]; % ����5���ڵ�����
lamdaMatrix = [3     1     2     1     3;
               3     3     1     2     3]'; % ����Ti�ڸ��������ϵ�ִ��Ч��
for i = 1:num_tasks % ����Ti�ڸ��������ϵ�GPUִ��Ч��
    for j = 1:num_server
        for k = 1:GPUs_server(j)
            chiMatrix{i}{j}{k} = 10 + randi(10);
        end
    end
end
alpha = [3, 5]; % ��������ִ�еĹ��ĳ���
for j = 1:num_server % ����������GPU�Ĺ��ĳ���
    for k = 1:GPUs_server(j)
        powerMatrix{j}{k} = 5 + randi(5);
    end
end

%% �㷨
virtualMachinesInServer = {};%����һ���յ�Ԫ������
valueVMs = {};

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