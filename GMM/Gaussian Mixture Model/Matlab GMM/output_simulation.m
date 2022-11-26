clc;
close all;
clear all;
data_in     = dlmread('t11_r_dut.txt');
%data_in = dlmread('r.txt');
%b = dlmread('t11_b_dut.txt');
%data_in = cat(3, r, g, b);
%data_in = reshape(Th, [7680000 3]);
length_p    = length(data_in);
r           = 240;
c           = 320;
num_f       = r*c;
j =1;
for(i=1:num_f:length_p)
    data_matrix = reshape(data_in(i:num_f+i-1),r,c);
    out(:,:,j) = data_matrix;
    figure(1);
    imshow(uint8(out(:,:,j)));
    %imwrite(uint8(out(:,:,j)));
    pause(0.5);
     j = j+1;
end


