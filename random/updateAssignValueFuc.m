function [Assign, value] = updateAssignValueFuc(Assign, value, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i)


for j = 1:num_server
    if ~isequal(serverHoldTaskIndex, j)
        if isequal(i, 1)
            for Cx = 1:vCPUs_server(j)
                num_gpu = GPUs_server(j);
                for k = 1:2^num_gpu % 遍历gpu的所有情况
                    Assign{1}{j}{Cx}{k} = [];
                    value{1}{j}{Cx}{k} = 0;
                end
            end
        else
            Assign{i}{j} = Assign{i-1}{j};
            value{i}{j} = value{i-1}{j};
        end
    end
end