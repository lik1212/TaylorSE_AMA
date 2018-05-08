% For understanding permute and reshape

A = [1 2 3 4; 5 6 7 8; 9 10 11 12;13 14 15 16];
Z = [1 2; 3 4];

B = reshape(A, [2, 2, 2, 2]);
C = permute(B, [1, 2, 4, 3]); % [1,2,4,3]
D = reshape(C, [], 2);

E = D * Z;

F = reshape(E , [2, 2, 2, 2]);
G = permute(F , [1, 2, 4, 3]); % [1,2,4,3]
H = reshape(G , 4, 4);