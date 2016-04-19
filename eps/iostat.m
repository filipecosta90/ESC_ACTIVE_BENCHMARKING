%% tcl link colors
%% $ns color 1 red
%% $ns color 2 green
%% $ns color 3 blue
%% $ns color 4 yellow
%% $ns color 5 magenta
%% $ns color 6 brown

red = [ 255 0 0 ];
green = [ 0 255 0 ];
blue = [ 0 0 255 ];
yellow = [ 255 255 0 ];
magenta = [ 255 0 255 ];
brown = [ 165 42 42 ];

color0 = red/255;
color1 = green/255;
color2 = blue/255;
color6 = yellow/255;
color7 = magenta/255;
color8 = brown/255;


FigHandle = figure;
set(FigHandle, 'Position', [0, 0, 1024, 480]);


%%%% FILES %%%%
full = tblread('iostat_iozone_write.csv' );



%%%% KBPS %%%%
kbps = full ( :, 3); 



plot(kbps,'-','Color', color0,'LineWidth',2);
hold on;
plot( [ 0  105 ] , [476585 476585], '--','Color', color2,'LineWidth',1); 
hold on;
plot( [ 105  210 ] , [463266 463266], '--','Color', color7,'LineWidth',1); 
hold on;
ylim([0 max(kbps*1.25)]);
xlim([0 222]);


l = legend('iostat measured throughput','initial write iozone measured throughput' , 'rewrite iozone measured throughput' );

 max_write = max ( kbps ( 1 : 105 ));
 max_rewrite = max ( kbps ( 106 : 220 ));
 
set(gca,'YTickLabel',num2str(get(gca,'YTick').'));




set(l,'FontSize',12);
ylabel('Throughput  in KBytes/sec');

xlabel('Time in sec.');
str = sprintf('Assessing disk performance with the iostat command vs iozone tool\niozone command line options -+u -R -i 0 -S 20480 -s 39g  -l 1 -u 1\nPeak performance during initial write %d KBytes/sec (vs iozone measured 476585 KBytes/sec)\n Peak performance during rewrite %d KBytes/sec (vs iozone measured 463266 KBytes/sec)', max_write, max_rewrite);

title(str);


set(gca,'fontsize',12);
