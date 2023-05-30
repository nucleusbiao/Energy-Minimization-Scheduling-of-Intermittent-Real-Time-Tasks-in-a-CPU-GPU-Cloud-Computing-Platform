function [virtualMachinesInServer, valueVMs] = updateVMsValueFuc(virtualMachinesInServer, valueVMs, num_server, vCPUs_server, GPUs_server, serverHoldTaskIndex, i)

for j = 1:num_server
    if ~isequal(serverHoldTaskIndex, j)
        if isequal(i, 1)
            virtualMachinesInServer{i}{j} = [];
            valueVMs{i}{j} = 0;
        else
            virtualMachinesInServer{i}{j} = virtualMachinesInServer{i-1}{j};
            valueVMs{i}{j} = valueVMs{i-1}{j};
        end
    end
end