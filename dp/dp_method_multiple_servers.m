%% varyingServers
clc
clear
energyArrayDPvaryingServers = zeros(10, 100);
succArrayDPvaryingServers = zeros(10, 100);
comTimeArrayDPvaryingServers = zeros(10, 100);

for num_server = 1:10
    num_server
    for times = 1:100
        eval(['load ..\data\varyingServersCount\varyingServersCount', num2str(num_server),'Times',num2str(times),';']);
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
        energyArrayDPvaryingServers(num_server, times) = sum(power_static_servers*3600) + sum(energyInServer);
        succArrayDPvaryingServers(num_server, times) = succ;
        comTimeArrayDPvaryingServers(num_server, times) = endTime;
    end
    save('energyArrayDPvaryingServers','energyArrayDPvaryingServers')
    save('succArrayDPvaryingServers','succArrayDPvaryingServers')
    save('comTimeArrayDPvaryingServers','comTimeArrayDPvaryingServers')
end