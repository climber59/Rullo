%{
sanitize the text boxes' inputs
- swap the row,col size or at least label it

give target product as an option?
- probably gets large quickly
- there are so many places I rely on sum() as well

play around with how many numbers should be on
- between 25%-75% ?
- at least X from each row/col?

include some preset number ranges
- 2:3
- -9:9
--- related, add a method to enter specific numbers? eg '1 3 5 7 9'

generally improve the visuals
- target's correct sum indicator is hard to see
- more pleasant colors would be nice
- helpers and targets should have visual differences to prevent confusion

Proper resizing
- mostly font sizes
- give a little buffer so objects aren't cut off slightly
- most ui objects are in 'pixels'. 'normalize' might be better
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
	
	gameOver = [];
	board = [];
	targetsTop = [];
	targetsLeft = [];
	helpersBot = [];
	helpersRight = [];
	checkmark = [];
	
	colorOffOn = [0.5 0.5 0.5; 1 1 1]; % tile off;on color
	colorUnlockLock = [0.94 0.94 0.94; 1 1 0]; % tile unlocked;locked color
	colorOffOnTarget = [0.94 0.94 0.94; 1 1 0]; % target unmet;met color
	colorTargetFace = [150 200 255]/255;%[68, 117, 237]/255; %41 115 214
	colorHelperFace = [237 161 100]/255; %[237, 141, 68]/255; %250 172 47
	

	
	figureSetup();
	newGame();
	
	% handles resizing the ui when the user resizes the figure
	function [] = resize(~,~)
		ax.Position(3) = f.Position(3)-2;
		ax.Position(4) = f.Position(4)-100;
		axis equal
% 		ax.XLim = ax.XLim + [-1 1];
% 		ax.YLim = ax.YLim + [-1 1];
% 		axis equal
		
% 		c = f.Children;
% 		for i = 1:length(c)-1
% 			c(i).Position(1) = str2num(c(i).Tag)*f.Position(3)/600;
% % 			c(i).Position(1) = str2num(c(i).Tag)*f.Position(3)/600;
% 			
% 		end
	end

	% starts a new game
	function [] = newGame(~,~)
		gameOver = false;
		randGen(str2num(gridWidth.String),str2num(gridHeight.String),str2num(gridRangeMin.String):str2num(gridRangeMax.String));
		gameSetup();
		changeHelpers();
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
			c = colorOffOnTarget(1 + (sum(grid(r,:).*gridOn(r,:)) == gridTargetsRow(r)),:);
			targetsLeft(r).EdgeColor = c;
			helpersRight(r).EdgeColor = c;
		end
		for c = cols
			% check col
			color = colorOffOnTarget(1 + (sum(grid(:,c).*gridOn(:,c)) == gridTargetsCol(c)),:);
			targetsTop(c).EdgeColor = color;
			helpersBot(c).EdgeColor = color;
		end
	end
	
	% checks if the puzzle has been completed
	function [win] = wincheck()
		win = false;
		w = size(grid,2);
		h = size(grid,1);

		s = 0;
		for i=1:h
			if targetsLeft(i,1).EdgeColor == colorOffOnTarget(2,:)
				s = s + 1;
			end
		end
		for i=1:w
			if targetsTop(1, i).EdgeColor == colorOffOnTarget(2,:)
				s = s + 1;
			end
		end
		if s == w+h
			win = true;
			checkmark.Visible = 'on';
% 			x = 3*[-12.04 -6.38 2.78 -6.35 -12.04]+12.5*w;
% 			y = -3*[0.98 -0.98 7.75 -2.35 0.98]+10*h;
% 			patch(x,y,[0 .8 0]);
		end
	end
	
	% called when clicking the tiles or targets
	function [] = mouseClick(~,~, type, row, col)
		if gameOver
			return
		end
		w = size(grid,2);
		h = size(grid,1);
		
		% determine what is clicked
		if strcmp(type, 'board')
			if strcmp(f.SelectionType,'alt')
				gridLocked(row,col) = ~gridLocked(row,col);
				board(row,col).EdgeColor = colorUnlockLock(1 + gridLocked(row,col),:);
			else
				if ~gridLocked(row,col)
					gridOn(row, col) = ~gridOn(row, col);
					board(row, col).FaceColor = colorOffOn(1 + gridOn(row,col),:);
					% check if row/col sum is (un)met and change sum indicator as needed
					checkTargets(row,col);
					gameOver = wincheck();
				end
			end
			changeHelpers(0,0,row,col);
		elseif strcmp(type, 'target')
			if row==0 || row==h+1 % clicking vertical targets
				summed = (targetsTop(1,col).EdgeColor==colorOffOnTarget(2,:));
			else % horz targets
				summed = (targetsLeft(row,1).EdgeColor==colorOffOnTarget(2,:));
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
						board(ind2(i)).EdgeColor = colorUnlockLock(1,:);
					end
				else
					ind = nonzeros(ind);
					for i = 1:length(ind)
						gridLocked(ind(i)) = true;
						board(ind(i)).EdgeColor = colorUnlockLock(2,:);
					end
				end
				if row == 0 || row == h+1
					changeHelpers(0,0,-1,col);
				else % col == 0 || col == w+1
					changeHelpers(0,0,row,-1);
				end
			end
		end
		
	end

	% creates the gui objects in the axes
	function [] = gameSetup(~,~)
		cla
		w = size(grid,2);
		h = size(grid,1);
		board = gobjects(h,w);
		targetsTop = gobjects(1,w);
		targetsLeft = gobjects(h,1);
		helpersBot = gobjects(1,w);
		helpersRight = gobjects(h,1);			
		
		g = grid.*gridLog;
		gridTargetsCol = sum(g); % vertical sums
		gridTargetsRow = sum(g,2); % horizontal sums
		gridOn = ones(size(grid)); % all start on
		gridLocked = 0*gridOn; % all start unlocked
		
		r = 5; % tile radius
		r2 = 15; % gap between tile centers
		x = r*cos(linspace(0, 2*pi, 48));
		y = r*sin(linspace(0, 2*pi, 48));
		for i = 1:h
			for j = 1:w
				board(i,j) = patch(x+j*r2,y+i*r2,colorOffOn(2,:), 'ButtonDownFcn', {@mouseClick, 'board', i, j}, 'EdgeColor', colorUnlockLock(1,:), 'LineWidth', 3);
				board(i,j).UserData.text = text(j*r2, i*r2, num2str(grid(i,j)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			end
		end
		
		x = [-r -r r r];
		y = [-r r r -r];
		color = [colorHelperFace; colorTargetFace];
		color = color(1 + (helpersPopup.Value == 1),:);
		for i = 1:w
			targetsTop(i) = patch(x+i*r2, y, colorTargetFace, 'ButtonDownFcn', {@mouseClick, 'target', 0, i}, 'EdgeColor', colorOffOnTarget(1,:),'LineWidth',4);
			targetsTop(i).UserData.text = text(i*r2, 0, num2str(gridTargetsCol(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			
			helpersBot(i) = patch(x+i*r2, y+r2*(h+1), color, 'ButtonDownFcn', {@mouseClick, 'target', h+1, i}, 'EdgeColor', colorOffOnTarget(1,:),'LineWidth',4);
			helpersBot(i).UserData.text = text(i*r2, r2*(h+1), num2str(gridTargetsCol(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
		end
		for i = 1:h
			targetsLeft(i) = patch(x, y+i*r2, colorTargetFace, 'ButtonDownFcn', {@mouseClick, 'target', i, 0}, 'EdgeColor', colorOffOnTarget(1,:),'LineWidth',4);
			targetsLeft(i).UserData.text = text(0, i*r2, num2str(gridTargetsRow(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			
			helpersRight(i) = patch(x+r2*(w+1), y+i*r2, color, 'ButtonDownFcn', {@mouseClick, 'target', i, w+1}, 'EdgeColor', colorOffOnTarget(1,:),'LineWidth',4);
			helpersRight(i).UserData.text = text(r2*(w+1), i*r2, num2str(gridTargetsRow(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
		end
		s = (min([w,h]) - 1)*r2 + 2*r;
		checkmark = patch((1 + (w>h)*abs(w-h)/2)*r2 - r + s*[0 9 37 87 100 42]/100, (1 + (h>w)*abs(w-h)/2)*r2 - r + s*[72 59 78 3 12 100]/100,[0 1 0],'FaceAlpha',0.5,'EdgeColor','none','Visible','off');
		ax.XLim = [-1.4*r, (w + 1)*r2 + 1.4*r];
		ax.YLim = [-1.4*r, (h + 1)*r2 + 1.4*r];
	end
	
	% called by pressing the Reset button
	function [] = reset(~,~)
% 		board
		gameOver = false;
		checkmark.Visible = 'off';
		gridOn = ones(size(grid));
		gridLocked = zeros(size(grid));
		
		for i = 1:size(grid,1)
			for j = 1:size(grid,2)
				targetsTop(j).EdgeColor = colorOffOnTarget(1,:);
				helpersBot(j).EdgeColor = colorOffOnTarget(1,:);
				
				board(i,j).FaceColor = colorOffOn(2,:);
				board(i,j).EdgeColor = colorUnlockLock(1,:);
			end
			targetsLeft(i).EdgeColor = colorOffOnTarget(1,:);
			helpersRight(i).EdgeColor = colorOffOnTarget(1,:);
		end
		
		changeHelpers();
		checkTargets(-1,-1);
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
		% recolor the helpers when helpersPopup changed from or to 'Target'
		if helpersPopup.Value ~= helpersPopup.UserData.oldValue && (helpersPopup.Value == 1 || helpersPopup.UserData.oldValue == 1)
			color = [colorHelperFace; colorTargetFace];
			color = color(1 + (helpersPopup.Value == 1),:);
			for i = cols
				helpersBot(i).FaceColor = color;
			end
			for i = rows
				helpersRight(i).FaceColor = color;
			end
		end
		helpersPopup.UserData.oldValue = helpersPopup.Value;
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
			'Callback',@reset,...
			'Units','pixels',...
			'Position',[50 15, 100 70],...
			'Tag','50');		
		
		uicontrol(f,'Style','text',...
			'Position',[305 70 45 25],...
			'String', 'Grid Size',...
			'Tag','305');
		gridHeight = uicontrol(f,'Style','edit',...
			'Position',[350 70 25 25],...
			'String','5',...
			'Tag','350');
		gridWidth = uicontrol(f,'Style','edit',...
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
			'Tag','425',...
			'UserData',struct('oldValue',1));
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
		gridLog = randi(2,h,w) - 1;
% 		while sum(sum(gridLog))<s^2/3 || sum(sum(gridLog))>s^2*19/25
% 			for i = 1:w*h
% 				gridLog(i) = randi(2)-1;
% 			end
% 		end
	end
end



















