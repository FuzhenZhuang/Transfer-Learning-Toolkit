function [x,y] = swap(x,y)
tempx = x;
x = y;
y = tempx;
clear tempx;