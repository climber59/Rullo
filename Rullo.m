%{
math helpers:
All at once would be too much, maybe a selector to change what's shown. An
option to show each or none. Display using the left/bottom sums, or extra
ui elements
-current sum
-difference
-locked sum 
-???locked difference

idiot proof the text boxes

Proper resizing

stop doing things after winnning

make it look less like crap

play around with how many numbers should be on
%}
function [ ] = Rullo( )
	clc
	
	f = [];
	ax = [];
	gridWidth = []; %uicontrol;
	gridHeight = [];
	gridRangeMin = []; %uicontrol;
	gridRangeMax = []; %uicontrol;
	grid =[];
	gridLog = [];
	gridOn = [];
	gridSumTB = [];
	gridSumLR = [];
	board = gobjects;
	sumsTB = gobjects;
	sumsLR = gobjects;
	lockMode = false;
	
	onColor = [1 1 1];
	offColor = [0.5 0.5 0.5];
	lockColor = [1 1 0];
	unlockColor = [0.94 0.94 0.94];
	sumColor = lockColor;
	unsumColor = [1 1 1];
% 	t = text;
	
	figureSetup()
	
	newGame();
	
	function [] = resize(~,~)
		ax.Position(3) = f.Position(3)-2;
		ax.Position(4) = f.Position(4)-100;
		axis equal
		
% 		c = f.Children;
% 		for i = 1:length(c)-1
% 			c(i).Position(1) = str2num(c(i).Tag)*f.Position(3)/600;
% % 			c(i).Position(1) = str2num(c(i).Tag)*f.Position(3)/600;
% 			
% 		end
	end

	function [] = newGame(~,~)
		randGen(str2num(gridWidth.String),str2num(gridHeight.String),str2num(gridRangeMin.String):str2num(gridRangeMax.String));
% 		textDisplay(grid, gridLog) % print to command window for debugging
		gameSetup();
% 		t = text(0,0,' '); % for debugging only, used in mouseClick
		initialCheck();
	end
	
	function [] = initialCheck()
		w = size(grid,2);
		h = size(grid,1);
		
		for row=1:h
			% check row
			s = 0;
			for i=1:w
				if board(row,i).FaceColor == onColor
					s = s + grid(row,i);
				end
			end
			if s == gridSumLR(row)
				sumsLR(row,1).EdgeColor = sumColor;
				sumsLR(row,2).EdgeColor = sumColor;
			end
		end
		for col=1:w
			% check col
			s = 0;
			for i=1:h
				if board(i,col).FaceColor == onColor
					s = s + grid(i,col);
				end
			end
			if s == gridSumTB(col)
				sumsTB(1, col).EdgeColor = sumColor;
				sumsTB(2, col).EdgeColor = sumColor;
			end
		end
	end
	
	function [] = wincheck()
		w = size(grid,2);
		h = size(grid,1);

		s = 0;
		for i=1:h
			if sumsLR(i,1).EdgeColor == sumColor
				s = s + 1;
			end
		end
		for i=1:w
			if sumsTB(1, i).EdgeColor == sumColor
				s = s + 1;
			end
		end
		if s == w+h
% 			disp('win')
			x = 3*[-12.04 -6.38 2.78 -6.35 -12.04]+12.5*w;
			y = -3*[0.98 -0.98 7.75 -2.35 0.98]+10*h;
			patch(x,y,[0 .8 0]);
		end
	end
	
	function [] = mouseClick(~,~, type, row, col)
		%f.SelectionType
		w = size(grid,2);
		h = size(grid,1);
% 		t.String = sprintf('%s  %d  %d',type, row, col);
		
		% determine what is clicked
		if strcmp(type, 'board')
			if lockMode || strcmp(f.SelectionType,'alt')
				if board(row,col).EdgeColor == unlockColor
					board(row,col).EdgeColor = lockColor;
				else
					board(row,col).EdgeColor = unlockColor;
				end
			else
				if board(row, col).EdgeColor == unlockColor
					if board(row, col).FaceColor == onColor
						board(row, col).FaceColor = offColor;
					else
						board(row, col).FaceColor = onColor;
					end
				end
				% check if row/col sum is (un)met an change sum indicator as needed
				
				% check row
				s = 0;
				for i=1:w
					if board(row,i).FaceColor == onColor
						s = s + grid(row,i);
					end
				end
				if s == gridSumLR(row)
					sumsLR(row,1).EdgeColor = sumColor;
					sumsLR(row,2).EdgeColor = sumColor;
					wincheck();
				else
					sumsLR(row,1).EdgeColor = unsumColor;
					sumsLR(row,2).EdgeColor = unsumColor;
				end
				
				% check col
				s = 0;
				for i=1:h
					if board(i,col).FaceColor == onColor
						s = s + grid(i,col);
					end
				end
				if s == gridSumTB(col)
					sumsTB(1, col).EdgeColor = sumColor;
					sumsTB(2, col).EdgeColor = sumColor;
					wincheck();
				else
					sumsTB(1, col).EdgeColor = unsumColor;
					sumsTB(2, col).EdgeColor = unsumColor;
				end
			end
		elseif strcmp(type, 'sum')
			if row==0 || row==h+1
				summed = (sumsTB(1,col).EdgeColor==sumColor);
			else
				summed = (sumsLR(row,1).EdgeColor==sumColor);
			end
			if summed
				if row == 0 || row == h+1
					ind = sub2ind([h w], 1:h, col*ones(1,h));
				else % col == 0 || col == l+1
					ind = sub2ind([h w], row*ones(1,w), 1:w);
				end

				ind2 = ind;
				for i=1:length(ind)
					if board(ind(i)).EdgeColor == lockColor
						ind(i) = 0;
					end
				end
				if nnz(ind) == 0
					for i=1:length(ind2)
						board(ind2(i)).EdgeColor = unlockColor;
					end
				else
					ind = nonzeros(ind);
					for i=1:length(ind)
						board(ind(i)).EdgeColor = lockColor;
					end
				end
			end
		end
		
	end

	function [] = gameSetup(~,~)
		
		board = patch;
		sumsTB = patch;
		sumsLR = patch;
		
		cla		
		w = size(grid,2);
		h = size(grid,1);
		gridOn = grid.*gridLog;
		gridSumTB = sum(gridOn); %vertical sum
		gridSumLR = sum(gridOn,2); % horizontal sum, (2,1) is first row
		
		r = 5;
		r2 = 15;
		x = r*cos(linspace(0, 2*pi, 48));
		y = r*sin(linspace(0, 2*pi, 48));
		for i = 1:h
			for j = 1:w
				board(i,j) = patch(x+j*r2,y+i*r2,onColor, 'ButtonDownFcn', {@mouseClick, 'board', i, j}, 'EdgeColor', unlockColor, 'LineWidth', 3);
				text(j*r2, i*r2, num2str(grid(i,j)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			end
		end
		
		x = [-r -r r r];
		y = [-r r r -r];
		for i = 1:w
			sumsTB(1,i) = patch(x+i*r2, y, [1 1 1], 'ButtonDownFcn', {@mouseClick, 'sum', 0, i}, 'EdgeColor', unsumColor);
			text(i*r2, 0, num2str(gridSumTB(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			sumsTB(2,i) = patch(x+i*r2, y+r2*(h+1), [1 1 1], 'ButtonDownFcn', {@mouseClick, 'sum', h+1, i}, 'EdgeColor', unsumColor);
			text(i*r2, r2*(h+1), num2str(gridSumTB(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
		end
		for i = 1:h
			sumsLR(i,1) = patch(x, y+i*r2, [1 1 1], 'ButtonDownFcn', {@mouseClick, 'sum', i, 0}, 'EdgeColor', unsumColor);
			text(0, i*r2, num2str(gridSumLR(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			sumsLR(i,2) = patch(x+r2*(w+1), y+i*r2, [1 1 1], 'ButtonDownFcn', {@mouseClick, 'sum', i, w+1}, 'EdgeColor', unsumColor);
			text(r2*(w+1), i*r2, num2str(gridSumLR(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
		end
	end
	
	function [] = lockSwitch(src,~)
		lockMode = ~lockMode;
		if lockMode
			src.String = 'Lock: on';
		else
			src.String = 'Lock: off';
		end
	end

	function [] = figureSetup()
		f = figure(1);
		clf
		f.MenuBar = 'none';
		f.Name = 'Rullo';
		f.NumberTitle = 'off';
		s = get(0,'ScreenSize');
		h = 700;
		w = 600;
		f.Position = [(s(3)-w)/2 (s(4)-h)/2, w h];
		f.Resize = 'on';
		f.SizeChangedFcn = @resize;
		
		
		ax = axes('Parent',f);
		cla
		ax.Units = 'pixels';
		ax.Position = [2 h-w, w-2 w];
		ax.XTick = [];
		ax.YTick = [];
		ax.Box = 'on';
		ax.YDir = 'reverse';
		axis equal
		hold on
		ax.Color = f.Color;
		
		
		uicontrol(f,'Style','pushbutton',...
			'String','New',...
			'FontSize',20,...
			'Callback',@newGame,...
			'Units','pixels',...
			'Position',[200 15, 100 70],...
			'Tag','200');
		
		uicontrol(f,'Style','pushbutton',...
			'String','Reset',...
			'FontSize',20,...
			'Callback',@gameSetup,...
			'Units','pixels',...
			'Position',[50 15, 100 70],...
			'Tag','50');
		
		uicontrol(f,'Style','pushbutton',...
			'String','Lock: off',...
			'FontSize',20,...
			'Callback',@lockSwitch,...
			'Units','pixels',...
			'Position',[450 15, 130 70],...
			'Tag','450');
		
		
		uicontrol(f,'Style','text',...
			'Position',[305 70 45 25],...
			'String', 'Grid Size',...
			'Tag','305');
		gridWidth = uicontrol(f,'Style','edit',...
			'Position',[350 70 25 25],...
			'String','5',...
			'Tag','350');
		gridHeight = uicontrol(f,'Style','edit',...
			'Position',[375 70 25 25],...
			'String','5',...
			'Tag','375');
		
		uicontrol(f,'Style','text',...
			'Position',[305 40 45 25],...
			'String', 'Number Range',...
			'Tag','305');
		gridRangeMin = uicontrol(f,'Style','edit',...
			'Position',[350 40 25 25],...
			'String','1',...
			'Tag','350');		
		gridRangeMax = uicontrol(f,'Style','edit',...
			'Position',[375 40 25 25],...
			'String','9',...
			'Tag','375');
	end

	function [ ] = randGen( w, h, r )
		grid = zeros(h,w);
		gridLog = zeros(h,w);
		for i = 1:w*h
			grid(i) = r(randi(length(r)));
		end
		
		% adding the while loop could force conditions - ie at least half the grid must be on 
% 		while sum(sum(gridLog))<s^2/3 || sum(sum(gridLog))>s^2*19/25
			for i = 1:w*h
				gridLog(i) = randi(2)-1;
			end
% 		end
	end
end

% function for debugging only
function [] = textDisplay( grid, gridLog )
	clc
	gridOn = grid.*gridLog
	sum(sum(gridLog))
	w = size(grid,2);
	h = size(grid,1);
	fprintf('     ')
	for i = 1:w
		fprintf('%3.0f ', sum(gridOn(:,i)))
	end
	fprintf('    \n\n')
	
	for i = 1:h
		fprintf('%3.0f  ', sum(gridOn(i,:)));
		for j=1:w
			fprintf('%3.0f ', grid(i,j));
		end
		fprintf(' %3.0f \n', sum(gridOn(i,:)));
	end
	
	fprintf('\n     ')
	for i = 1:w
		fprintf('%3.0f ', sum(gridOn(:,i)))
	end
	fprintf('    \n')
end



















