function l = l2norm(z)

l = sqrt(sum(col(conj(z).*(z))));