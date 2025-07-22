conditionmatrix=[];

conditionmatrix(1:10,1)=1;
conditionmatrix(11:20,1)=2;

conditionmatrix(1:10,2)=5.7;
conditionmatrix(11:20,2)=6;
conditionmatrix

%C:\Drive\best-toolbox

save('conditionmatrix.mat','conditionmatrix');

load('conditionmatrix.mat')