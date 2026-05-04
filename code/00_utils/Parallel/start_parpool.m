function start_parpool(nw)

    %   START_PARPOOL Start or restart a parallel pool.
    %   The function starts a parallel pool with the requested number of workers,
    %   capped at the number of physical cores available on the machine.
    %
    %   If the local cluster profile allows fewer workers than requested, the
    %   function updates and saves the profile limit before starting the pool.
    %   If no parallel pool is currently open, a new one is started. If a pool is
    %   already open, it is deleted and restarted with the requested number of
    %   workers.
    %
    %   Input:
    %       nw  Requested number of parallel workers
    
    %% function
    
    nw = min(nw, feature('numcores'));
    c = parcluster('Processes');
    if c.NumWorkers < nw
        c.NumWorkers = nw;
        saveProfile(c);
    end
    if isempty(gcp('nocreate'))
        parpool(nw);
    else
        delete(gcp('nocreate'));
        parpool(nw);
    end
end
