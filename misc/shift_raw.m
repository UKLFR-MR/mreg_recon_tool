function raw = shift_raw(raw,trajectory,shift)

    traj = trajectory.trajectory;
    Ni = length(traj);
    for i = 1:Ni
        raw(1:length(traj{i}),:,i:Ni:end) = raw(1:length(traj{i}),:,i:Ni:end) .* repmat(exp(1i*traj{i}(:,[2 1 3])*shift'), [1 size(raw, 2) size(raw(:,:,i:Ni:end), 3)]);
    end
    
end