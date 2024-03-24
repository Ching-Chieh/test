# MATLAB 3-dim Cholesky decomposition of a correlation matrix (symbol)
clc
clear
close
syms c12 c13 c23
assume(c12>=0 & c12<=1)
assume(c13>=0 & c13<=1)
assume(c23>=0 & c23<=1)
assumptions
A = [1 c12 c13; c12 1 c23; c13 c23 1];
D = simplify(chol(A,'lower','nocheck'))
