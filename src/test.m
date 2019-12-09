home = [
    0
    0
    0
    0
    0
];

% Symbolic variables
syms a0 a1 a2 a3 a4 a5 t0 tf;

% Initial and final time matrix
M = [
    1, t0, t0^2, t0^3, t0^4, t0^5
    0, 1, 2*t0, 3*t0^2, 4*t0^3, 5*t0^4
    0, 0, 2, 6*t0, 12*t0^2, 20*t0^3
    1, tf, tf^2, tf^3, tf^4, tf^5
    0, 1, 2*tf, 3*tf^2, 4*tf^3, 5*tf^4
    0, 0, 2, 6*tf, 12*tf^2, 20*tf^3
];

% Movement constants
H = [
    a0
    a1
    a2
    a3
    a4
    a5
];

% 30 62 -57  0 30
% 30 52 -80 22 30
% -35 32 -105 160 0

% Positions of each movement
P = [
    0        0         0          0        0        0
    0.523599 1.0821   -0.994838   0        0.523599 3.55
    0.523599 0.785398 -1.36136    0.558505 0.523599 3.55
    0.523599 0.785398 -1.36136    0.558505 0.523599 2
    0.523599 0.907571 -1.30899694 0.436332 0.523599 2
   -0.610865 0.558505 -1.8326     2.79253  0        2
   -0.610865 0.558505 -1.8326     2.79253  0        3.55
];

% Matrix of initial and final times
% Each column is one movement
T = [
    0 3 5   5.5 6 9
    3 5 5.5 6.5 9 10
] .* 1000;

% Start at home position
% L5goto(P(7, :) + [0 1 0 0 0 0], 0);
% java.lang.Thread.sleep(1000);
L5goto(home, 0);

moves = {};
grips = {};

for i = 2:size(P, 1)
    time = T(:, i-1);
    t1 = time(1);
    t2 = time(2);
    steps = (t2 - t1)/50;
    Q = zeros(6, steps + 1);

    for j = 1:size(P, 2)
        q0 = P(i - 1, j);
        qf = P(i, j);

        m = subs(M, [t0 tf], [time(1) time(2)]);
        [b0, b1, b2, b3, b4, b5] = solve(m * H == [q0 0 0 qf 0 0]');

        q = @(t) b0 + b1*t + b2*t^2 + b3*t^3 + b4*t^4 + b5*t^5;
        Q(j, :) = double(arrayfun(q, t1:(t2-t1)/steps:t2));
    end
    
    moves{i-1} = Q(1:5, :);
    grips{i-1} = Q(6, :);
end

for i = 1:length(moves)
    L5trajectory(moves{i}, grips{i});
end