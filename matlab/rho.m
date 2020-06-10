function [r] = rho(arr)
n=numel(arr);
sum=0;
for i=1:n
    sum=sum+arr(i)^2;
end
r=sum^0.5;