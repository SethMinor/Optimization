% Code for steepest descent or the Newton-Raphson method (direction)
% With backtracking line search (step length)
% Also allows for optional inexact Newton methods

clear, clc, clf;
fs = 14; % font size for plots



%% Rosenbrock optimization function
MyRosenbrock =@(x1, x2) 100*(x2 - x1.^2).^2 + (1 - x1).^2;

% Define the gradient of f
Grad_f =@(x1,x2) [-400*x1.*(x2-x1.^2) - 2*(1-x1), 200*(x2-x1.^2)]';

% Define the Hessian matrix
H =@(x1,x2) [(2 - 400*x2 + 1200*x1.^2), -400*x1; -400*x1, 200];



%% Perform the optimization algorithm

% Steepest descent: unit vector in direction of negative gradient
Steepest_Pk =@(x1,x2) -Grad_f(x1,x2)./norm(Grad_f(x1,x2));
% Newton-Raphson method: -H^(-1)gradient(f)
Newton_Pk =@(x1,x2) -inv(H(x1,x2))*Grad_f(x1, x2);

% Choose descent direction (!!!)
%Direction = Steepest_Pk;
%Direction = Newton_Pk;
Direction =@(x1,x2) ConjGradCore(H(x1,x2), -Grad_f(x1,x2));


% Set the stopping criterion parameters
Stop_Value = 10^(-8);
Stop_Crit_a =@(x1, x2) norm(Grad_f(x1,x2)); % norm of the gradient
Stop_Crit_b =@(x1, x2) abs(MyRosenbrock(x1,x2)); % abs of the object fcn

% Set the stopping criterion (!!!)
Stop_Crit = Stop_Crit_a;
Max_Iterations = 25000;


% Backtracking line search parameters
alpha0 = 1;
alpha_bar = 1;
rho = 0.5; % contraction factor
c = 10^(-4);


% Initial conditions to give a whirl
x0one = [-1.2, 1];
x0two = [2.8, 4];

% Pick an initial condition (!!!)
Initial_condition = x0one;


% Initialize these sneaky counters and loop variables
k = 0;
x_k = Initial_condition;
f0 = MyRosenbrock(x_k(1), x_k(2));
P0 = Direction(x_k(1), x_k(2));
alpha_k = alpha0;


% Create history arrays to store stats of the optimization algorithm
xkHist1 = x_k(1);
xkHist2 = x_k(2);
fkHist = f0;
PkHist1 = P0(1);
PkHist2 = P0(2);
alphakHist = alpha0;

% Print status of the script to the screen
fprintf('Optimization algorithm started, using the initial values: \n');
fprintf('  (x1, x2) = (%0.1f, %0.1f) ', Initial_condition(1), Initial_condition(2));
fprintf('\n f(x1, x2) = %0.1f \n\n', f0);


% Initialize condition for while loop to continue
stop_bool = false;

% Loop over the iterations of the optimization algorithm
while (stop_bool == false)

    % Print the iteration number every n iterations
    nprint = 500;
    if (mod(k,nprint) == 0)
        fprintf('\n... Iteration: k = %1.f\n',k)
    end

    % Find the direction we're stepping in
    P_k = Direction(x_k(1), x_k(2));
    
    % Set the initial next-point-prediction for the backtracking line search
    xP = x_k + alpha_bar * P_k';

    % Set the initial alpha
    alpha_k = alpha_bar;
    
    % Armijo condition for the while loop below
    Armijo =@(alpha_k) MyRosenbrock(x_k(1), x_k(2)) + c*alpha_k*P_k'*Grad_f(x_k(1), x_k(2));
    
    % Do the backtracking line search (checking the Armijo condition)
    j = 0; % exception variable
    while (MyRosenbrock(xP(1), xP(2)) > Armijo(alpha_k))
    
        % Contract the step length
        alpha_k = alpha_k * rho;
        
        % Rewrite the next point with the new step length
        xP = x_k + alpha_k * P_k';

        % max iterations exception
        if (j >= Max_Iterations)
            fprintf('\nMax iterations reached on backtracking line search, amigo.');
            break;
        end
        
        % Update exception variable
        j = j + 1;
    
    end

    % Exception for alpha_k = 0 (to machine precision)
    if (abs(alpha_k) <= 10^(-16))
        fprintf('\nBacktracking line search exception triggered:\n');
            fprintf('    alpha_k == 0\nSheesh!\n');
        break;
    end
    
    % Use P_k to find the next iteration of the loop variables
    x_kPlusOne = x_k + alpha_k*P_k';
    f_kPlusOne = MyRosenbrock(x_kPlusOne(1), x_kPlusOne(2));
    P_kPlusOne = Direction(x_kPlusOne(1), x_kPlusOne(2));
    
    % Record the updated variables (push variables into history vector)
    xkHist1(end + 1) = x_kPlusOne(1);
    xkHist2(end + 1) = x_kPlusOne(2);
    fkHist(end + 1) = f_kPlusOne;
    PkHist1(end + 1) = P_kPlusOne(1);
    PkHist2(end + 1) = P_kPlusOne(2);
    alphakHist(end + 1) = alpha_k;

    % update the iteration number
    k = k + 1;
    
    % Check the overall stopping condition to see if we should continue
    if (Stop_Crit(x_kPlusOne(1), x_kPlusOne(2)) < Stop_Value) || (k >= Max_Iterations)
        stop_bool = true;
        fprintf('\nAlgorithm has terminated! Whoah!\n');
        break;
    end
    
    % Update the loop variables
    x_k = x_kPlusOne;
    f_k = f_kPlusOne;

end



%% Plot some stats of the algorithm

% Create a history array to store stats of the optimization algorithm
klist = 1:1:k+1;
Full_History = [klist', xkHist1', xkHist2', fkHist', PkHist1', PkHist2', alphakHist'];
FirstSix = Full_History(1:6,:);
LastSix = Full_History(end-5:end,:);

ColumnNames = {'k', 'x1', 'x2', 'f(x1,x2)', 'Px', 'Py', 'alpha'};
FirstSixTable = table(FirstSix(:,1), FirstSix(:,2), FirstSix(:,3), FirstSix(:,4), ...
    FirstSix(:,5), FirstSix(:,6), FirstSix(:,7), 'VariableNames', ColumnNames);
LastSixTable = table(LastSix(:,1), LastSix(:,2), LastSix(:,3), LastSix(:,4), ...
    LastSix(:,5), LastSix(:,6), LastSix(:,7), 'VariableNames', ColumnNames);


% Print a summary of the results of the algorithm to the screen
format long
fprintf('\nThe algorithm terminated after: %1.f iterations\n',k+1)
fprintf('The first 6 iterations of the algorithm looked like:\n')
disp(FirstSixTable)
fprintf('The last 6 iterations of the algorithm looked like:\n')
disp(LastSixTable)
fprintf('The final stopping criterion value was: %0.15f\n\n', ...
    Stop_Crit(x_kPlusOne(1), x_kPlusOne(2)))


% Make some charts of more algorithm stats
figure (1)
semilogy(klist, fkHist)
xlabel('Iteration number, $k$','Interpreter','latex','FontSize',fs)
ylabel('Objective function, $f(x_1, x_2)$','Interpreter','latex','FontSize',fs)
title("Initial condition, $(x_1, x_2)=$ (" + Initial_condition(1) + ", " ...
    + Initial_condition(2) + ")",'Interpreter','latex','FontSize',fs)
grid on


% Plot the path that the algorithm took to x* = (x1*, x2*)
figure (2)

plot3(xkHist1(1), xkHist2(1), MyRosenbrock(xkHist1(1), xkHist2(1)),...
    'ro','MarkerSize',6,'MarkerFaceColor','w')
hold on
plot3(xkHist1, xkHist2, MyRosenbrock(xkHist1, xkHist2), '-r')
hold on
plot3(xkHist1(end), xkHist2(end), MyRosenbrock(xkHist1(end), xkHist2(end)),...
    'ro','MarkerSize',6,'MarkerFaceColor','r')
hold on
dx = 0.01;
[L, R] = deal(-1.5, 1.5);
dy = 0.01;
[D, U] = deal(-2, 3);
[X1, X2] = meshgrid(L:dx:R, D:dy:U);
Z = MyRosenbrock(X1, X2);
surf(X1,X2,Z)
shading interp
hold off

legend('Starting point, $x_0$','Path taken, $\{x_k\}$','Numerical $x^{\star}$',...
    'Interpreter','Latex','FontSize',fs-2)
xlim([-1.5 1.5])
ylim([-2 3])
xlabel('$x_1$','Interpreter','latex','FontSize',fs)
ylabel('$x_2$','Interpreter','latex','FontSize',fs)
zlabel('$f(x_1, x_2)$','Interpreter','latex','FontSize',fs)
title("Initial condition, $(x_1, x_2)=$ (" + Initial_condition(1) + ", " ...
    + Initial_condition(2) + ")",'Interpreter','latex','FontSize',fs)
grid on



%% Functions for inexact Newton method

% CONJUGATE GRADIENT METHOD
% This solves Ax=b numerically
function x = ConjGradCore(A, b)

    % Specify the forcing sequence {n_k} for the algorthim
    % Superlinear convergence
    n_k =@(k) min(1E-8, sqrt(norm(b)));
    % Quadratic convergence
    %n_k =@(k) min(1E-8, norm(b));
    
    % Initial conditions
    x0 = zeros(2,1); % For a 2x2 square matrix

    % Initial residual
    r0 = A*x0 - b;

    % Inital search direction
    p0 = -r0;
    
    % Initialize counter
    k = 0;
    
    % Set iterates as initial values
    xk = x0;
    rk = r0;
    pk = p0;
    
    % Main for-loop
    while (norm(rk) > n_k(k))
    
        % Update the step length
        ak = (rk'*rk)/(pk'*A*pk);

        % Negative curvature condition
        NegCurveCond = pk'*A*pk;
        if (NegCurveCond <= 0)
            if (k == 0)
                fprintf('Negative curvature encountered! Ay caramba!')
                xk = p0;
                break
            else
                fprintf('Negative curvature encountered! Ay caramba!')
                break
            end
        end
    
        % Take a step
        xk = xk + ak*pk;
    
        % Update the residuals
        rnew = rk + ak*A*pk;
    
        % Update beta
        Bk = (rnew'*rnew)/(rk'*rk);
    
        % Update the step direction
        pnew = Bk*pk - rnew;
    
        % Update iterated variables
        rk = rnew;
        pk = pnew;
    
        % Update the counter
        k = k + 1;
    
    end

    % Return the numerical solution
    x = xk;
end
