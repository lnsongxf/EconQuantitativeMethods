%Master program for Mortensen-Pissarides model with aggregate fluctuations
%%
%REQUIRED FUNCTIONS:
%Rouwenhorst.m

%PROCEDURES:
%1. set up the environment
%2. discretize the AR(1) process log(z_t+1) = rho*log(z_t) + sigma using the Rouwenhorst's method
%3. find the roots for the nonlinear system of equations
%4. simulate a sequence from the AR(1) process and plot the results
%%
clear all; clc;
%%
%%
%Set up the environment
        delta = 0.0081;
        alpha = 0.72;
        A = 0.158;
        rho = 0.9895;
        sigma = 0.0034;
        kappa = 0.6;
        beta = 0.999;
        N = 40; %No. of grid points
%%
n = input('Enter 1 if baseline Mortensen-Pissaredes model, enter 2 if Hagedorn and Manovskii (2008) model ');
switch n
%%
    case 1
        disp('baseline Mortensen-Pissaredes model')
        mu = 0.72;
        b = 0.4;
        
%%
%================Discretize AR(1) process as a Markov Chain===============
%%
%Rouwenhorst method
        P = Rouwenhorst((1+rho)/2, (1+rho)/2, N);

        log_z_bar = 0; %mean of the AR(1) process
        log_z = linspace(log_z_bar-sigma*sqrt((N-1)/(1-rho^2)),log_z_bar+sigma*sqrt((N-1)/(1-rho^2)), N);
        log_z = reshape(log_z,[],1); %make sure z is column vector

%%
%=============Minimize residuals (solve the N equations in N unknowns)=============
%%
        fun = @(x) P*((1-mu)*(exp(log_z)-b)-kappa*mu*exp(x)+(kappa/A)*(1-delta)*exp(alpha*x))-(kappa/A*beta)*exp(alpha*x);

%built-in function: fsolve

        log_theta = zeros(N,1);
        problem.options = optimoptions('fsolve','Display','none','PlotFcns',@optimplotfirstorderopt);
        problem.objective = fun;
        problem.x0 = log_theta;
        problem.solver = 'fsolve';
        log_theta_new = fsolve(problem);

%%
        figure;
        subplot(2,1,1);
        plot(log_theta_new);
        title('Solution log(theta)');
        xlabel('grid');
        ylabel('log(theta)');

        subplot(2,1,2);
        plot(fun(log_theta_new));
        title('Residual at the solution');
        xlabel('grid');
        ylabel('residual');

%%
        figure;
        subplot(2,1,1);
        plot(exp(log_z));
        title('Market tightness at each corresponding value of productivity ');
        xlabel('grid');
        ylabel('z');

        subplot(2,1,2);
        plot(exp(log_theta_new));
        xlabel('grid');
        ylabel('theta');
%%
%=====================Find stationary distribution=========================
%%
        t= 0;
        pi0 = ones(1,N)/N;
        tol = 10^(-6);
        err = 1;
        while err>tol;
            pi = pi0*P;
            err = (pi-pi0)*(pi-pi0)' ;
            pi0 = pi;
            t = t+1;
        end;
        pi = pi';

        figure;
        plot(log_z,pi);
        title('Stationary distribution of the Markov Chain');
        ylabel('density');
        xlabel('log-productivity, log(z)');
%%
%======================Simulate from the Markov Chain======================
%%
        pi_sum = zeros(size(pi));
        for i = 1:size(pi,1);
            pi_sum(i) = sum(pi(1:i,1)); 
        end;

        M = 150; %length of simulated sequence
        log_z_t = zeros(M+1, 1);
        theta_t = zeros(M+1,1);
        log_z_t(1,1) = log_z(N/2,1); %Initialize from an ad hoc/arbitrary state z0
        log_theta_t(1,1) =log_theta_new(N/2,1);%check the notation 'theta' is right
        rng('default');

        s = linspace(1, M, M); %s stores the seed numbers
        for i = 1: M;
            rng(s(1,i)); %set seeds
            x(i) = rand;
            log_z_t(i+1,1) =  log_z(find(pi_sum >= x(i),1),1); 
            log_theta_t(i+1) = log_theta_new(find(pi_sum >= x(i),1),1);
            %find(pi_sum >= x(i),1) returns the index of the first element in
            %pi_sum that is greater than x(i)
        end;

        figure;
        subplot(2,1,1);
        plot(exp(log_z_t));
        title('A simulated sequence from the AR(1) process');
        ylabel('z');
        xlabel('Period');

        subplot(2,1,2);
        plot(exp(log_theta_t));
        ylabel('theta');
        xlabel('Time');

        figure;
        subplot(2,1,1);
        plot(log_z_t);
        title('A simulated sequence from the AR(1) process (log-transformed)');
        ylabel('log(z)');
        xlabel('Time');

        subplot(2,1,2);
        plot(log_theta_t);
        ylabel('log(theta)');
        xlabel('Time');
%%
%======================Hagedorn and Manovskii (2008) ======================
%%
    case 2
        disp('Hagedorn and Manovskii (2008) model')
        
        mu = 0.05;
        b = 0.95;
%%
%================Discretize AR(1) process as a Markov Chain===============
%
%%
%Rouwenhorst method
        P = Rouwenhorst((1+rho)/2, (1+rho)/2, N);

        log_z_bar = 0; %mean of the AR(1) process
        log_z = linspace(log_z_bar-sigma*sqrt((N-1)/(1-rho^2)),log_z_bar+sigma*sqrt((N-1)/(1-rho^2)), N);
        log_z = reshape(log_z,[],1); %make sure z is column vector

%%
%=============Minimize residuals (solve the N equations in N unknowns)=============
%%
        fun = @(x) P*((1-mu)*(exp(log_z)-b)-kappa*mu*exp(x)+(kappa/A)*(1-delta)*exp(alpha*x))-(kappa/A*beta)*exp(alpha*x);

%built-in function: fsolve

        log_theta = zeros(N,1);
        problem.options = optimoptions('fsolve','Display','none','PlotFcns',@optimplotfirstorderopt);
        problem.objective = fun;
        problem.x0 = log_theta;
        problem.solver = 'fsolve';
        log_theta_new = fsolve(problem);

%%
        figure;
        subplot(2,1,1);
        plot(log_theta_new);
        title('Solution log(theta)');
        xlabel('grid');
        ylabel('log(theta)');

        subplot(2,1,2);
        plot(fun(log_theta_new));
        title('Residual at the solution');
        xlabel('grid');
        ylabel('residual');

%%
        figure;
        subplot(2,1,1);
        plot(exp(log_z));
        title('Market tightness at each corresponding value of productivity ');
        xlabel('grid');
        ylabel('z');

        subplot(2,1,2);
        plot(exp(log_theta_new));
        xlabel('grid');
        ylabel('theta');
%%
%=====================Find stationary distribution=========================
%%
        t= 0;
        pi0 = ones(1,N)/N;
        tol = 10^(-6);
        err = 1;
        while err>tol;
            pi = pi0*P;
            err = (pi-pi0)*(pi-pi0)' ;
            pi0 = pi;
            t = t+1;
        end;
        pi = pi';

        figure;
        plot(log_z,pi);
        title('Stationary distribution of the Markov Chain');
        ylabel('density');
        xlabel('log-productivity, log(z)');
%%
%======================Simulate from the Markov Chain======================
%%
        pi_sum = zeros(size(pi));
        for i = 1:size(pi,1);
            pi_sum(i) = sum(pi(1:i,1)); 
        end;

        M = 150; %length of simulated sequence
        log_z_t = zeros(M+1, 1);
        theta_t = zeros(M+1,1);
        log_z_t(1,1) = log_z(N/2,1); %Initialize from an ad hoc/arbitrary state z0
        log_theta_t(1,1) =log_theta_new(N/2,1);%check the notation 'theta' is right
        rng('default');

        s = linspace(1, M, M); %s stores the seed numbers
        for i = 1: M;
            rng(s(1,i)); %set seeds
            x(i) = rand;
            log_z_t(i+1,1) =  log_z(find(pi_sum >= x(i),1),1); 
            log_theta_t(i+1) = log_theta_new(find(pi_sum >= x(i),1),1);
            %find(pi_sum >= x(i),1) returns the index of the first element in
            %pi_sum that is greater than x(i)
        end;

        figure;
        subplot(2,1,1);
        plot(exp(log_z_t));
        title('A simulated sequence from the AR(1) process');
        ylabel('z');
        xlabel('Period');

        subplot(2,1,2);
        plot(exp(log_theta_t));
        ylabel('theta');
        xlabel('Time');

        figure;
        subplot(2,1,1);
        plot(log_z_t);
        title('A simulated sequence from the AR(1) process (log-transformed)');
        ylabel('log(z)');
        xlabel('Time');

        subplot(2,1,2);
        plot(log_theta_t);
        ylabel('log(theta)');
        xlabel('Time');
 %%   
    otherwise
        disp('error')
end



