function l = dotprod(z1,z2)

l = sum(col(conj(z1).*(z2)));