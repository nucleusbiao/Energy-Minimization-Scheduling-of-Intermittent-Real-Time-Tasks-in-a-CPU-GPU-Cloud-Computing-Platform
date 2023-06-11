function deleteTaskIDs = taskRemoveFuc(tasksInterval, timeStart)
deleteTaskIDs = [];
for i = 1:size(tasksInterval, 1)
    if timeStart >= tasksInterval(i,end)
        deleteTaskIDs = [deleteTaskIDs, i];
    end
end