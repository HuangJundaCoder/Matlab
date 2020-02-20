function [ax,ay,az,gx,gy,gz] = get_data(testing_time_s,sampling_interval_ms)
%get data from stm32

%clear
delete(instrfindall);
%clear;

%constant
%sampling_interval_ms = 100; %sampling interval millisecond
%testing_time_s = 5; %testing time

%comm initialize
s = serial('com6','BaudRate',115200);
s.BytesAvailableFcnMode='byte';  % ��������  
s.InputBufferSize=4096;  
s.OutputBufferSize=1024;  
s.BytesAvailableFcnCount=100;  
s.ReadAsyncMode='continuous';  
s.Terminator='CR';  

%initialize
fopen(s);
Head = ' ';
End = ' ';
i = 1;
j = 1;

%Timer start
start = tic;

while(toc(start)<testing_time_s)
    %analysing
    while(Head~='S')
        Head = char(fread(s,1,'uint8')');
    end

    while(End~='E')
        End = char(fread(s,1,'uint8')');
        if(End=='E')
            %delete the last character E
            break;
        end
        data(i) = End;
        i = i+1;
    end

    %get data
    gx(j) = str2double(data(3:8));
    gy(j) = str2double(data(11:16));
    gz(j) = str2double(data(19:24));
    ax(j) = str2double(data(27:31));
    ay(j) = str2double(data(34:38));
    az(j) = str2double(data(41:45));

    %clear
    Head = ' ';
    End = ' ';
    i = 1;
    
    %loop
    j = j+1;
    
    %delay
    pause(sampling_interval_ms*0.001);
end

%plot gyro lines
figure(1);
plot(gx,'r');
hold on
plot(gy,'b');
hold on
plot(gz,'g');
xlabel(['�������� ','(���',num2str(sampling_interval_ms),'����)']);
ylabel('�Ƕ�/degree');

legend('+X����','+Y����','+Z����');
title('���ᴫ����');

%plot accelerator lines
figure(2);
plot(ax,'r');
hold on
plot(ay,'b');
hold on
plot(az,'g');
xlabel(['�������� ','(���',num2str(sampling_interval_ms),'����)']);
ylabel('���ٶ�m/s^2');
legend('+X����','+Y����','+Z����');
title('���ᴫ����');

%clear comm
fclose(s);
delete(s);
clear s;
end