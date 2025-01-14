b=bossdevice;
for i=1:1000
    b.sendPulse(1)
    pause(3+rand*1.5)
    
end
    

%%
bd=bossdevice;

Signal_Id=getsignalid(bd.tg,'alpha_window_buffer')+int32([0:249])

whos Signal_Id

Buffered_Window=getsignal(bd.tg,Signal_Id)

whos Buffered_Window
%%
b=bossdevice;
b.configure_time_port_marker([0 2 1]);
for i=1:250
    b.manualTrigger
    pause(0.5)
    
end
