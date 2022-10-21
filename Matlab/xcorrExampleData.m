

X = sin((1:100)/pi + 10);
Y = sin((1:100)/pi );

plot(X)
hold on;
plot(Y)
hold off

crosscorr(X,Y)

