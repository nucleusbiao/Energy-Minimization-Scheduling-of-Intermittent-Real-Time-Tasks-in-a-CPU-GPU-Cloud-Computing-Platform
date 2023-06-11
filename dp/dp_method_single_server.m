clc
clear
%% varyingTaskNumSingleServer
energyArrayDPvaryingTaskNumSingleServer = zeros(10, 100);
succArrayDPvaryingTaskNumSingleServer = zeros(10, 100);
comTimeArrayDPvaryingTaskNumSingleServer = zeros(10, 100);

for num_tasks = 2:2:20
    num_tasks
    for times = 1:100
        eval(['load ..\data\varyingTaskNumSingleServer\varyingTaskNumSingleServerTasks',num2str(num_tasks),'Times',num2str(times),';']);
        times
        tic;
        Assign = {};
        value = {};
        value_temp = [];
        succ = 1;
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
                [Assign, value, tasksIDinServer, tasksInServer] = updateAccordingToAppearTimeFuc(Assign, value, deleteTaskIDs, tasksIDinServer);
            end
            for j = 1:num_server
                valueServerJ = 0;
                for Cx = 1:vCPUs_server(j)
                    num_gpu = GPUs_server(j);
                    for k = 1:2^num_gpu 
                        gpu_valid = interpretK(k, num_gpu);
                        if isequal(i,1) 
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
                [Assign, value] = updateAssignValueFuc(Assign, value, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);
            end
        end
        endTime = toc;
        energyArrayDPvaryingTaskNumSingleServer(num_tasks/2, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayDPvaryingTaskNumSingleServer(num_tasks/2, times) = succ;
        comTimeArrayDPvaryingTaskNumSingleServer(num_tasks/2, times) = endTime;
    end
    save('energyArrayDPvaryingTaskNumSingleServer','energyArrayDPvaryingTaskNumSingleServer')
    save('succArrayDPvaryingTaskNumSingleServer','succArrayDPvaryingTaskNumSingleServer')
    save('comTimeArrayDPvaryingTaskNumSingleServer','comTimeArrayDPvaryingTaskNumSingleServer')
end

%% varyingVCPUSingleServer
clc
clear
energyArrayDPvaryingVCPUSingleServer = zeros(10, 100);
succArrayDPvaryingVCPUSingleServer = zeros(10, 100);
comTimeArrayDPvaryingVCPUSingleServer = zeros(10, 100);

for VCPUs = 10:10:100
    VCPUs
    for times = 1:100
        eval(['load ..\data\varyingVCPUSingleServer\varyingVCPUSingleServerVCPUs',num2str(VCPUs),'Times',num2str(times),';']);
        times
        tic;
        Assign = {};
        value = {};
        value_temp = [];
        succ = 1;
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
                [Assign, value, tasksIDinServer, tasksInServer] = updateAccordingToAppearTimeFuc(Assign, value, deleteTaskIDs, tasksIDinServer);
            end
            for j = 1:num_server
                valueServerJ = 0;
                for Cx = 1:vCPUs_server(j)
                    num_gpu = GPUs_server(j);
                    for k = 1:2^num_gpu 
                        gpu_valid = interpretK(k, num_gpu);
                        if isequal(i,1)
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
                [Assign, value] = updateAssignValueFuc(Assign, value, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);
            end
        end
        endTime = toc;
        energyArrayDPvaryingVCPUSingleServer(VCPUs/2, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayDPvaryingVCPUSingleServer(VCPUs/2, times) = succ;
        comTimeArrayDPvaryingVCPUSingleServer(VCPUs/2, times) = endTime;
    end
    save('energyArrayDPvaryingVCPUSingleServer','energyArrayDPvaryingVCPUSingleServer')
    save('succArrayDPvaryingVCPUSingleServer','succArrayDPvaryingVCPUSingleServer')
    save('comTimeArrayDPvaryingVCPUSingleServer','comTimeArrayDPvaryingVCPUSingleServer')
end

%% varyingIntervalCountSingleServer
clc
clear
energyArrayDPvaryingIntervalCountSingleServer = zeros(10, 100);
succArrayDPvaryingIntervalCountSingleServer = zeros(10, 100);
comTimeArrayDPvaryingIntervalCountSingleServer = zeros(10, 100);

for numInterval = 10:10:100
    numInterval
    for times = 1:100
        eval(['load ..\data\varyingIntervalCountSingleServer\varyingIntervalCountSingleServerInterval',num2str(numInterval),'Times',num2str(times),';']);
        times
        tic;
        Assign = {};
        value = {};
        value_temp = [];
        succ = 1;
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
                [Assign, value, tasksIDinServer, tasksInServer] = updateAccordingToAppearTimeFuc(Assign, value, deleteTaskIDs, tasksIDinServer);
            end
            for j = 1:num_server
                valueServerJ = 0;
                for Cx = 1:vCPUs_server(j)
                    num_gpu = GPUs_server(j);
                    for k = 1:2^num_gpu
                        gpu_valid = interpretK(k, num_gpu);
                        if isequal(i,1)
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
                [Assign, value] = updateAssignValueFuc(Assign, value, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i);
            end
        end
        endTime = toc;
        energyArrayDPvaryingIntervalCountSingleServer(numInterval/10, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayDPvaryingIntervalCountSingleServer(numInterval/10, times) = succ;
        comTimeArrayDPvaryingIntervalCountSingleServer(numInterval/10, times) = endTime;
    end
    save('energyArrayDPvaryingIntervalCountSingleServer','energyArrayDPvaryingIntervalCountSingleServer')
    save('succArrayDPvaryingIntervalCountSingleServer','succArrayDPvaryingIntervalCountSingleServer')
    save('comTimeArrayDPvaryingIntervalCountSingleServer','comTimeArrayDPvaryingIntervalCountSingleServer')
end