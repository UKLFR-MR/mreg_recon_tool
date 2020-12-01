function rotated_trajectStruct=trajectStruct_rotate(trajectStruct,alpha,axis)

R=arbRot(alpha,axis);

G_rot = R*trajectStruct.G';
K_rot = R*trajectStruct.K';

trajectStruct.G=G_rot';
%trajectStruct.G_bound = [G_rot(:,1) G_rot(:,end)]';
trajectStruct.K=K_rot';
%trajectStruct.K_bound = [K_rot(:,1) K_rot(:,end)]';
trajectStruct.direction =(R*trajectStruct.direction')';
trajectStruct.angle = alpha;

rotated_trajectStruct= trajectStruct;

end
