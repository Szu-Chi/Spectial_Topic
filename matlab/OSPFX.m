function [nu] = OSPFX(M, U)
[l, p] = size(M);
P_U = eye(l) - U * pinv(U);
nu = zeros(p, 1);
for k=1:p
    nu(k) = rho(P_U*M(:,k));
end