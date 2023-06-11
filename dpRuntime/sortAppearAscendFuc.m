function tasksInterval = sortAppearAscendFuc(TaskIneravls)

tasksInterval = [];
for i = 1:size(TaskIneravls, 2)
    taskArray = TaskIneravls{i};
    if isequal(i, 1)
        tasksInterval = [ones(size(taskArray, 1), 1), taskArray];
    else
        for j = 1:size(taskArray, 1)
            interval = taskArray(j,:);
            for k = 1:size(tasksInterval, 1)
                if interval(1) <= tasksInterval(k, 2)
                    tasksInterval = [tasksInterval(1:k-1,:); i, interval; tasksInterval(k:end,:)];
                    break
                elseif isequal(k, size(tasksInterval, 1))
                    tasksInterval = [tasksInterval; i, interval];
                end
            end
        end
    end
end