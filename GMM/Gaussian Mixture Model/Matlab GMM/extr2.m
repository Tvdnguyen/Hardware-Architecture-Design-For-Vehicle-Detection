%%
% Make input data for Simulation  
% Author    :Quang Trinh Viet (quang.trinhviet@icdrec.edu.vn)
%%
clear all
close all
clc
delete 'r.txt'
delete 'g.txt'
delete 'b.txt'
%% input file
name='C:\Users\This\Desktop\Thesis\Video\Cars moving\320x240.mp4';
%% processing
File = VideoReader(name);
numFrames = File.NumberOfFrames;
vidHeight = File.Height
vidWidth = File.Width
for i=1:50 % ghi 100 frame
    It.cdata = read(File,i);
    Y = rgb2gray(It.cdata);
    Y = Y';
    dlmwrite('r.txt',Y,'delimiter','\n','-append');
    dlmwrite('g.txt',Y,'delimiter','\n','-append');
    dlmwrite('b.txt',Y,'delimiter','\n','-append');
end
%% end of line