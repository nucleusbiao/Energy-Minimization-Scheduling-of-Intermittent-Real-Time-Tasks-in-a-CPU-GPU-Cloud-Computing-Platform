function serverPickUpOrder = serverPrioritizeFuc(tasksIDinServer, tasksInterval, periodTasks, totalLoadCpus)

util = [];
for i = 1:size(tasksIDinServer, 2)
    taskIndexArray = tasksIDinServer{i};
    if isempty(taskIndexArray)
        util = [util, 0];
    else
        utilTemp = 0;
        for j = 1:size(taskIndexArray, 2)
            taskIndex = taskIndexArray(j);
            taskID = tasksInterval(taskIndex, 1);
            utilTemp = utilTemp + totalLoadCpus(taskID)/periodTasks(taskID);
        end
        util = [util, utilTemp];
    end
end
[result, serverPickUpOrder] = sort(util, 'ascend');