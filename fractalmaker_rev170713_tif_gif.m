% ------------------------------------------
%    fractalmaker.m
%      by Shinya Yamamoto
%      last modified on 08/30/11 at AIST
%      Modified by HFK in SKKU, 2017/7/14 for tiff orignal tiff export
% ------------------------------------------
clc; clear all; close all;

fractaldirectory='/Users/prof.f/Documents/Fractal';

disp('=======================================================')
disp('                 Fractal Maker                         ')
disp('=======================================================')
disp(' ')
cd('/Users/prof.f/Documents/Fractal')
[s, mess, messid] = mkdir('fractals');
cd('rev_fractals');
%rand('twister',sum(100*clock))
rng(sum(100*clock),'twister') %seeding


for series=[1:10] % make 10 series
    cd(fractaldirectory);
    dirname=['series' num2str(series)];
    [s, mess, messid] = mkdir(dirname);
    cd(dirname);

    for stno=[0:999]
   
        kuikomisize=2;
        dekoboko=0.8;
        for typenum=[1:12] % 12 objects in one set
            ok='n';
            while ok=='n'
                numofsuperimp=4;
                fill([15,-15,-15,15],[15,15,-15,-15],[0,0,0]) %black background
                hold on
                datamat=[];
                for sup=[1:numofsuperimp]
                    numofedge= 4+round(rand*6);
                    edgesize=numofsuperimp-sup+rand;
                    numofrecursion= 2+round(rand*3);
                    fracx=edgesize*cos(2*pi*[1:numofedge]/numofedge);
                    fracy=edgesize*sin(2*pi*[1:numofedge]/numofedge);
                    GAmat=[];
                    for k=[1:1:numofrecursion]
                        mx=(fracx([2:end 1])+fracx)/2;
                        my=(fracy([2:end 1])+fracy)/2;
                        dx= fracx([2:end 1])-fracx;
                        dy= fracy([2:end 1])-fracy;
                        theta=atan(dy./dx);
                        theta(find(dx<0))=theta(find(dx<0))+pi;
                        GA=kuikomisize*(rand-dekoboko);
                        fracx2=mx+GA*sin(theta);
                        fracy2=my-GA*cos(theta);
                        fracx=[fracx;fracx2];
                        fracx=fracx(:);
                        fracx=fracx';
                        fracy=[fracy;fracy2];
                        fracy=fracy(:);
                        fracy=fracy';
                        GAmat=[GAmat;GA];
                    end
                    col=rand(1,3);
                    fill(fracx([1:end 1]),fracy([1:end 1]),col)
                    hold on
                    plot(fracx([1:end 1]),fracy([1:end 1]),'Color',col)
                    axis square
                    axis([-numofsuperimp-1 numofsuperimp+1 -numofsuperimp-1 numofsuperimp+1])
                    datamat(sup).numofedge=numofedge;
                    datamat(sup).edgesize=edgesize;
                    datamat(sup).numofrecursion=numofrecursion;
                    datamat(sup).col=col;
                    datamat(sup).GA=GAmat;
                end
                axis([-5,5 -5,5])
                %T = get(gca,'tightinset');
                %set(gca,'position',[T(1) T(2) 1-T(1)-T(3) 1-T(2)-T(4)]);
                axis off
                set(gca,'position',[0 0 1 1],'units','normalized')
                %f = gcf;
                %f.Position = [100 100 500 500]
                %ok=input('ok? (y or n)','s');
                ok='y';
            end
            %filename=['i' num2str(typenum) stimnum '.tif'];
           
            % filenames
            if stno<10
                if typenum > 9
                    stimnum=['0' num2str(stno)];
                else
                    stimnum=['00' num2str(stno)];
                end
            elseif stno<100
                stimnum=['' num2str(stno)];
            else
                stimnum=num2str(stno);
            end     
            filename=['i' num2str(typenum) stimnum '.tif'];
            filename
            
            %export large size original images
            cd(fractaldirectory)
            cd(dirname);
            [s2, mess2, messid2] = mkdir('image');
            cd('image')
            fig = gcf;
            fig.PaperUnits = 'centimeter';
            fig.PaperPosition = [0 0 20 20]; %figure size: centimeter
            print('-dtiffn','-r150',filename) %150dpi orignal tiff file
           
            %export small size tiff images
            cd(fractaldirectory)
            cd(dirname);
            [s2, mess2, messid2] = mkdir('image_small_tiff');
            cd('image_small_tiff')
            fig = gcf;
            fig.PaperUnits = 'centimeter';
            fig.PaperPosition = [0 0 2 2]; %figure size: centimeter
            print('-dtiffn','-r150',filename) %150dpi orignal tiff file
           
            %export small size images
            cd(fractaldirectory)
            cd(dirname);
            [s2, mess2, messid2] = mkdir('image_small_gif');
            cd('image_small_gif')
            fig = gcf;
            fig.PaperUnits = 'centimeter';
            fig.PaperPosition = [0 0 10 10]; %figure size: centimeter
            printgif(filename) %make the small size of gif transparent images
            
            
            % export matlab data file
            filename2=['i' num2str(typenum) stimnum];
            
            cd(fractaldirectory)
            cd(dirname);
            [s3, mess3, messid3] = mkdir('data');
            cd('data')
            eval(['save ' filename2 ' datamat stimnum typenum numofsuperimp']);
            close all
            disp(['series' num2str(series) ', set:' stimnum ', obj:' num2str(typenum)])
        end
        disp('-------------------------')
    end
end


