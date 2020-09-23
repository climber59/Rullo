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
	
	tileRadius = 5; % tile radius
	tileSpacing = 15; % gap between tile centers
	

	
	figureSetup();
	newGame();
	
	% handles resizing the ui when the user resizes the figure
	function [] = resize(~,~)
		
	end

	% starts a new game
	function [] = newGame(~,~)
		gameOver = false;
		randGen(str2num(gridWidth.String),str2num(gridHeight.String),str2num(gridRangeMin.String):str2num(gridRangeMax.String));
		gameSetup();
		updateHelpers();
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
		for i = 1:h
			if targetsLeft(i,1).EdgeColor == colorOffOnTarget(2,:)
				s = s + 1;
			end
		end
		for i = 1:w
			if targetsTop(1, i).EdgeColor == colorOffOnTarget(2,:)
				s = s + 1;
			end
		end
		if s == w + h
			win = true;
			checkmark.Visible = 'on';
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
			updateHelpers(0,0,row,col);
		elseif strcmp(type, 'target')
			if row == 0 || row == h+1 % clicking vertical targets
				summed = (targetsTop(1,col).EdgeColor==colorOffOnTarget(2,:));
			else % horz targets
				summed = (targetsLeft(row,1).EdgeColor==colorOffOnTarget(2,:));
			end
			if summed % target met
				if row == 0 || row == h+1
					ind = sub2ind([h w], 1:h, col*ones(1,h));
				else % col == 0 || col == w+1
					ind = sub2ind([h w], row*ones(1,w), 1:w);
				end
				ind2 = ind; % indices of whole row/col
				ind = ind.*~gridLocked(ind); % where locked, set that ind to 0
				
				if nnz(ind) == 0 % all locked already
					gridLocked(ind2) = false;
					for i = ind2
						board(i).EdgeColor = colorUnlockLock(1,:); % unlock them
					end
				else
					ind = nonzeros(ind)';
					gridLocked(ind) = true;
					for i = ind
						board(i).EdgeColor = colorUnlockLock(2,:); % lock them
					end
				end
				% update helpers in case uisng 'Locked Sum' or 'Locked
				% Difference'
				if row == 0 || row == h+1
					updateHelpers(0,0,-1,col);
				else % col == 0 || col == w+1
					updateHelpers(0,0,row,-1);
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
		gridOn = ones(h,w); % all start on
		gridLocked = zeros(h,w); % all start unlocked
		
		x = tileRadius*cos(linspace(0, 2*pi, 48));
		y = tileRadius*sin(linspace(0, 2*pi, 48));
		for i = 1:h
			for j = 1:w
				board(i,j) = patch(x + j*tileSpacing, y + i*tileSpacing,colorOffOn(2,:), 'ButtonDownFcn', {@mouseClick, 'board', i, j}, 'EdgeColor', colorUnlockLock(1,:), 'LineWidth', 3);
				board(i,j).UserData.text = text(j*tileSpacing, i*tileSpacing, num2str(grid(i,j)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			end
		end
		
		x = [-tileRadius -tileRadius tileRadius tileRadius];
		y = [-tileRadius tileRadius tileRadius -tileRadius];
		color = [colorHelperFace; colorTargetFace];
		color = color(1 + (helpersPopup.Value == 1),:);
		for i = 1:w
			targetsTop(i) = patch(x + i*tileSpacing, y, colorTargetFace, 'ButtonDownFcn', {@mouseClick, 'target', 0, i}, 'EdgeColor', colorOffOnTarget(1,:),'LineWidth',4);
			targetsTop(i).UserData.text = text(i*tileSpacing, 0, num2str(gridTargetsCol(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			
			helpersBot(i) = patch(x + i*tileSpacing, y + tileSpacing*(h+1), color, 'ButtonDownFcn', {@mouseClick, 'target', h+1, i}, 'EdgeColor', colorOffOnTarget(1,:),'LineWidth',4);
			helpersBot(i).UserData.text = text(i*tileSpacing, tileSpacing*(h+1), num2str(gridTargetsCol(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
		end
		for i = 1:h
			targetsLeft(i) = patch(x, y + i*tileSpacing, colorTargetFace, 'ButtonDownFcn', {@mouseClick, 'target', i, 0}, 'EdgeColor', colorOffOnTarget(1,:),'LineWidth',4);
			targetsLeft(i).UserData.text = text(0, i*tileSpacing, num2str(gridTargetsRow(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
			
			helpersRight(i) = patch(x + tileSpacing*(w + 1), y + i*tileSpacing, color, 'ButtonDownFcn', {@mouseClick, 'target', i, w+1}, 'EdgeColor', colorOffOnTarget(1,:),'LineWidth',4);
			helpersRight(i).UserData.text = text(tileSpacing*(w + 1), i*tileSpacing, num2str(gridTargetsRow(i)), 'PickableParts','none', 'HorizontalAlignment', 'center', 'FontSize', 20);
		end
		s = (min([w,h]) - 1)*tileSpacing + 2*tileRadius; % checkmark scale
		checkmark = patch((1 + (w > h)*abs(w - h)/2)*tileSpacing - tileRadius + s*[0 9 37 87 100 42]/100, (1 + (h > w)*abs(w - h)/2)*tileSpacing - tileRadius + s*[72 59 78 3 12 100]/100,[0 1 0],'FaceAlpha',0.5,'EdgeColor','none','Visible','off');
		ax.XLim = [-1.4*tileRadius, (w + 1)*tileSpacing + 1.4*tileRadius]; % 0.4*tileRadius gives a buffer to the board
		ax.YLim = [-1.4*tileRadius, (h + 1)*tileSpacing + 1.4*tileRadius];
	end
	
	% called by pressing the Reset button
	function [] = reset(~,~)
		gameOver = false;
		checkmark.Visible = 'off';
		gridOn = ones(size(grid));
		gridLocked = zeros(size(grid));
		
		for i = 1:size(grid,1)
			for j = 1:size(grid,2)
				board(i,j).FaceColor = colorOffOn(2,:); % turn on all tiles
				board(i,j).EdgeColor = colorUnlockLock(1,:); % unlock all tiles
			end
		end
		
		updateHelpers(); % update helpers
		checkTargets(-1,-1); % check if any of the targets are met
	end
	
	% changes the squares on the right and bottom to match what's selected
	% in the helpersPopup list
	function [] = updateHelpers(~,~,rows,cols)
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
		% recolor the helpers when helpersPopup is changed from or to 'Target'
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
		f.SizeChangedFcn = @resize;
		
		
		ax = axes('Parent',f);
		ax.Units = 'normalized';
		ax.Position = [0 1/7 1 6/7];
		ax.XTick = [];
		ax.YTick = [];
		ax.Box = 'on';
		ax.YDir = 'reverse';
		axis equal
		ax.Color = f.Color;
		
		
		uicontrol(f,'Style','pushbutton',...
			'String','Reset',...
			'FontSize',20,...
			'Callback',@reset,...
			'Units','normalized',...
			'Position',[1/14 3/140, 1/6, 1/10]);
		
		uicontrol(f,'Style','pushbutton',...
			'String','New',...
			'FontSize',20,...
			'Callback',@newGame,...
			'Units','normalized',...
			'Position',[2/7 3/140, 1/6 1/10]);
		
		uicontrol(f,'Style','text',...
			'Units','normalized',...
			'Position',[61/120 3/42 3/40 1/28],...
			'String', 'Grid Size');
		gridHeight = uicontrol(f,'Style','edit',...
			'Units','normalized',...
			'Position',[7/12 3/42 1/24 1/28],...
			'String','5',...
			'ToolTip','# Rows');
		gridWidth = uicontrol(f,'Style','edit',...
			'Units','normalized',...
			'Position',[5/8 3/42 1/24 1/28],...
			'String','5',...
			'ToolTip','# Columns');
		
		
		uicontrol(f,'Style','text',...
			'Units','normalized',...
			'Position',[61/120 1/42 3/40 1/28],...
			'String', 'Number Range');
		gridRangeMin = uicontrol(f,'Style','edit',...
			'Units','normalized',...
			'Position',[7/12 1/42 1/24 1/28],...
			'String','1',...
			'ToolTip','Lowest Number');		
		gridRangeMax = uicontrol(f,'Style','edit',...
			'Units','normalized',...
			'Position',[5/8 1/42 1/24 1/28],...
			'String','9',...
			'ToolTip','Highest Number');
		
		uicontrol(f,'Style','text',...
			'Units','normalized',...
			'Position',[11/16 3/42, 1/4 1/21],...
			'String', 'Helpers:',...
			'FontSize',12);
		helpersPopup = uicontrol('Parent',f,...
			'Style','popupmenu',...
			'String',{'Target';'Current Sum';'Difference';'Locked Sum';'Locked Difference'},...
			'FontSize',10,...
			'Callback',@updateHelpers,...
			'Units','normalized',...
			'Position',[11/16 1/42, 1/4 1/21],...
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
		
		gridLog = randi(2,h,w) - 1;
	end
end



















