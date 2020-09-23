%{
combine some of the COLOR vars so I can use logicals like gridOn and
gridLocked to index the color

turn initialCheck() into a function that can check 'r,c' or everything at
the start of a new game

sanitize the text boxes' inputs
- swap the row,col size or at least label it

give target product as an option?
- probably gets large quickly
- there are so many places I rely on sum() as well

'Reset' button should not have to delete and redefine graphics objects
- should just turn everything on and unlock

Proper resizing
- mostly font sizes
- give a little buffer so objects aren't cut off slightly
- most ui objects are in 'pixels'. 'normalize' might be better

end the game after the puzzle is complete

center the winning checkmark
- also replace it with the good one

play around with how many numbers should be on
- between 25%-75% ?
- at least 2 from each row/col?

include some preset number ranges
- 2:3
- -9:9
--- related, add a method to enter specific numbers? eg '1 3 5 7 9'

generally improve the visuals
- target's correct sum indicator is hard to see
- more pleasant colors would be nice
- helpers and targets should have visual differences to prevent confusion
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
	gridLocked = [];
	gridTargetsCol = [];
	gridTargetsRow = [];
	helpersPopup = [];
	
	board = [];
	targetsTop = [];
	targetsLeft = [];
	helpersBot = [];
	helpersRight = [];
	
	onColor = [1 1 1];
	offColor = [0.5 0.5 0.5];
	lockColor = [1 1 0];
	unlockColor = [0.94 0.94 0.94];
	sumColor = lockColor;
	unsumColor = [1 1 1];
% 	t = text;
	
	figureSetup()
	
	newGame();
	
	% handles resizing the ui when the user resizes the figure
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

	% starts a new game
	function [] = newGame(~,~)
		randGen(str2num(gridWidth.String),str2num(gridHeight.String),str2num(gridRangeMin.String):str2num(gridRangeMax.String));
% 		textDisplay(grid, gridLog) % print to command window for debugging
		gameSetup();
% 		t = text(0,0,' '); % for debugging only, used in mouseClick
		checkTargets(-1,-1);
	end
	
	% checks if any targets are already met when the game starts
	% only turns on, needs to turn off as well now
	function [] = checkTargets(rows,cols)
		if rows == -1
			rows = 1:size(grid,1);
		end
		if cols == -1
			cols = 1:size(grid,2);
		end
		for r = rows
			% check row
			if sum(grid(r,:).*gridOn(r,:)) == gridTargetsRow(r)
				targetsLeft(r).EdgeColor = sumColor;
				helpersRight(r).EdgeColor = sumColor;
			else
				targetsLeft(r).EdgeColor = unsumColor;
				helpersRight(r).EdgeColor = unsumColor;
			end
		end
		for c = cols
			% check col
			if sum(grid(:,c).*gridOn(:,c)) == gridTargetsCol(c)
				targetsTop(c).EdgeColor = sumColor;
				helpersBot(c).EdgeColor = sumColor;
			else
				targetsTop(c).EdgeColor = unsumColor;
				helpersBot(c).EdgeColor = unsumColor;
			end
		end
	end
	
	% checks if the puzzle has been completed
	function [win] = wincheck()
		win = false;
		w = size(grid,2);
		h = size(grid,1);

		s = 0;
		for i=1:h
			if targetsLeft(i,1).EdgeColor == sumColor
				s = s + 1;
			end
		end
		for i=1:w
			if targetsTop(1, i).EdgeColor == sumColor
				s = s + 1;
			end
		end
		if s == w+h
			win = true;
			x = 3*[-12.04 -6.38 2.78 -6.35 -12.04]+12.5*w;
			y = -3*[0.98 -0.98 7.75 -2.35 0.98]+10*h;
			patch(x,y,[0 .8 0]);
		end
	end
	
	% called when clicking the tiles or targets
	function [] = mouseClick(~,~, type, row, col)
		%f.SelectionType
		w = size(grid,2);
		h = size(grid,1);
% 		t.String = sprintf('%s  %d  %d',type, row, col);
		
		% determine what is clicked
		if strcmp(type, 'board')
			if strcmp(f.SelectionType,'alt')
				gridLocked(row,col) = ~gridLocked(row,col);
				if gridLocked(row,col)
					board(row,col).EdgeColor = lockColor;
				else
					board(row,col).EdgeColor = unlockColor;
				end
			else
				if ~gridLocked(row,col)
					gridOn(row, col) = ~gridOn(row, col);
					if gridOn(row,col)
						board(row, col).FaceColor = onColor;
					else
						board(row, col).FaceColor = offColor;
					end
					% check if row/col sum is (un)met and change sum indicator as needed
					checkTargets(row,col);
					wincheck();
				end
				
			end
			changeHelpers(0,0,row,col);
		elseif strcmp(type, 'target')
			if row==0 || row==h+1 % clicking vertical targets
				summed = (targetsTop(1,col).EdgeColor==sumColor);
			else % horz targets
				summed = (targetsLeft(row,1).EdgeColor==sumColor);
			end
			if summed
				if row == 0 || row == h+1
					ind = sub2ind([h w], 1:h, col*ones(1,h));
				else % col == 0 || col == w+1
					ind = sub2ind([h w], row*ones(1,w), 1:w);
				end

				ind2 = ind;
				for i = 1:length(ind)
					if gridLocked(ind(i))
						ind(i) = 0;
					end
				end
				if nnz(ind) == 0
					for i = 1:length(ind2)
						gridLocked(ind2(i)) = false;
						board(ind2(i)).EdgeColor = unlockColor;
					end
				else
					ind = nonzeros(ind);
					for i = 1:length(ind)
						gridLocked(ind(i)) = true;
						board(ind(i)).EdgeColor = lockColor;
					end
				end
				if row == 0 || row == h+1
					changeHelpers(0,0,-1,col);
				else % col == 0 || col == l+1
					changeHelpers(0,0,row,-1);
				end
				
			end
		end
		
	end

	% creates the gui objects in the axes
	function [] = gameSetup(~,~)
		cla
		board = gobjects(size(grid));
		w = size(grid,2);
		h = size(grid,1);
		targetsTop = gobjects(1,w);
		targetsLeft = gobjects(h,1);
		helpersBot = gobjects(1,w);
		helpersRight = gobjects(h,1);
		
			
		
		g = grid.*gridLog;
		gridTargetsCol = sum(g); % vertical sums
		gridTargetsRow = sum(g,2); % horizontal sums
		gridOn = ones(size(grid)); % all start on
		gridLocked = 0*gridOn; % all start unlocked
		
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
			targetsTop(i) = patch(x+i*r2, y, [1 1 1], 'ButtonDownFcn', {@mouseClick, 'target', 0, i}, 'EdgeColor', unsumColor);
			text(i*r2, 0, num2str(gridTargetsCol(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			
			helpersBot(i) = patch(x+i*r2, y+r2*(h+1), [1 1 1], 'ButtonDownFcn', {@mouseClick, 'target', h+1, i}, 'EdgeColor', unsumColor);
			helpersBot(i).UserData.text = text(i*r2, r2*(h+1), num2str(gridTargetsCol(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
		end
		for i = 1:h
			targetsLeft(i) = patch(x, y+i*r2, [1 1 1], 'ButtonDownFcn', {@mouseClick, 'target', i, 0}, 'EdgeColor', unsumColor);
			text(0, i*r2, num2str(gridTargetsRow(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			
			helpersRight(i) = patch(x+r2*(w+1), y+i*r2, [1 1 1], 'ButtonDownFcn', {@mouseClick, 'target', i, w+1}, 'EdgeColor', unsumColor);
			helpersRight(i).UserData.text = text(r2*(w+1), i*r2, num2str(gridTargetsRow(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
		end
		changeHelpers();
% 		grid
% 		gridOn
% 		gridLocked
% 		targetsTop
% 		helpersBot
% 		targetsLeft
% 		helpersRight
	end
	
	% changes the squares on the right and bottom to match what's selected
	% in the helpersPopup list
	function [] = changeHelpers(~,~,rows,cols)
		if nargin < 3
			rows = 1:size(grid,1);
			cols = 1:size(grid,2);
		else
			if rows == -1
				rows = 1:size(grid,1);
			end
			if cols == -1
				cols = 1:size(grid,2);
			end
		end
		p = {'+',''};
		% {'Target';'Current Sum';'Difference';'Locked Sum';'Locked Difference'}
		switch helpersPopup.Value
			case 1 % target
				for i = cols
					helpersBot(i).UserData.text.String = num2str(gridTargetsCol(i));
				end
				for i = rows
					helpersRight(i).UserData.text.String = num2str(gridTargetsRow(i));
				end
			case 2 % current sum
				for i = cols
					helpersBot(i).UserData.text.String = num2str(sum(grid(:,i).*gridOn(:,i)));
				end
				for i = rows
					helpersRight(i).UserData.text.String = num2str(sum(grid(i,:).*gridOn(i,:)));
				end
			case 3 % difference
				for i = cols
% 					n = ;
					helpersBot(i).UserData.text.String = sprintf('%+d',-sum(grid(:,i).*gridOn(:,i)) + gridTargetsCol(i));
				end
				for i = rows
					helpersRight(i).UserData.text.String = sprintf('%+d',-sum(grid(i,:).*gridOn(i,:)) + gridTargetsRow(i));
				end
			case 4 % locked sum
				for i = cols
					helpersBot(i).UserData.text.String = num2str(sum(grid(:,i).*gridOn(:,i).*gridLocked(:,i)));
				end
				for i = rows
					helpersRight(i).UserData.text.String = num2str(sum(grid(i,:).*gridOn(i,:).*gridLocked(i,:)));
				end
			case 5 % locked difference
				for i = cols
					helpersBot(i).UserData.text.String = sprintf('%+d',-sum(grid(:,i).*gridOn(:,i).*gridLocked(:,i)) + gridTargetsCol(i));
				end
				for i = rows
					helpersRight(i).UserData.text.String = sprintf('%+d',-sum(grid(i,:).*gridOn(i,:).*gridLocked(i,:)) + gridTargetsRow(i));
				end
		end
% 		helperPopup.Value
% 		src.Value
	end
	
	% creates the figure and gui objects in the figure
	function [] = figureSetup()
		f = figure(1);
		clf('reset')
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
		
		helpersPopup = uicontrol('Parent',f,...
			'Style','popupmenu',...
			'String',{'Target';'Current Sum';'Difference';'Locked Sum';'Locked Difference'},...
			'FontSize',10,...
			'Callback',@changeHelpers,...
			'Units','pixels',...
			'Position',[425 15, 150 70],...
			'Tag','50');
	end
	
	% generates the grid of random numbers and which ones should be 'on' to
	% determine the target values
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



















