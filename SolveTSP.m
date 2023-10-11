function [ROIOrder] = SolveTSP(coordVec)

    % Taking coords of all ROI
    ROILon = coordVec(:,1);
    ROILat = coordVec(:,2);
    nROI = length(ROILon);
    
    % Generating list of all potential edges on the graph
    idxs = nchoosek(1:nROI,2);
    
    % Calculating distance between each node
    % This is only based on distance right now
    % But later we can make it based on our cost function?
    dist = hypot(ROILat(idxs(:,1)) - ROILat(idxs(:,2)), ...
                 ROILon(idxs(:,1)) - ROILon(idxs(:,2)));
    
    % Forcing high costs between midpoint nodes and end node and low cost
    % between start & end node
    dist(4)=0; dist(7)=99; dist(9)=99; dist(10)=99;
    
    lendist = length(dist);
    
    G = graph(idxs(:,1),idxs(:,2));
    
    Aeq = spalloc(nROI,length(idxs),nROI*(nROI-1)); % Allocate a sparse matrix
    for ii = 1:nROI
        whichIdxs = (idxs == ii); % Find the trips that include stop ii
        whichIdxs = sparse(sum(whichIdxs,2)); % Include trips where ii is at either end
        Aeq(ii,:) = whichIdxs'; % Include in the constraint matrix
    end
    beq = 2*ones(nROI,1);
    
    intcon = 1:lendist;
    lb = zeros(lendist,1);
    ub = ones(lendist,1);
    
    opts = optimoptions('intlinprog','Display','off');
    [x_tsp,costopt,exitflag,output] = intlinprog(dist,intcon,[],[],Aeq,beq,lb,ub,opts);
    
    x_tsp = logical(round(x_tsp));
    Gsol = graph(idxs(x_tsp,1),idxs(x_tsp,2),[],numnodes(G));
    
    sol_tsp = idxs(x_tsp==1,:);
    % manually add start point as first point
    ROIOrder = [1];
    
    ROICounter = 1;
    i=1;
    while length(ROIOrder)<5
        if sol_tsp(i,1) == ROICounter
            if sol_tsp(i,1) ~= nROI
                ROIOrder = [ROIOrder sol_tsp(i,1)];
                ROICounter = sol_tsp(i,2);
                sol_tsp(i,:) = [];
            end
        elseif sol_tsp(i,2) == ROICounter
            if sol_tsp(i,2) ~= nROI
                ROIOrder = [ROIOrder sol_tsp(i,2)];
                ROICounter = sol_tsp(i,1);
                sol_tsp(i,:) = [];
            end
        else
            i=i+1;
        end
    end
    
    % manually add end point as last point
    ROIOrder = [ROIOrder(2:end) nROI];

end