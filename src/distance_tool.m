 
%% Measure Distances in an Image
% This example shows how to draw line ROIs on an image and calibrate the
% measurements using a known distance.

% Copyright 2018 The MathWorks, Inc.

%% Display Image
% Display the image on which we will take measurements. We want to allow
% the user to seamlessly add, edit, and remove measurements without needing
% to enter into any specific drawing mode. To accomplish this, we will add 
% a callback to the ButtonDownFcn on the image and pass in the handle to
% the axes and some data we will use later with each line ROI.
im = imread('./../data/interim/20210408-190706_sensor-orbit_100RPM/screengrab.png');

% Get size of the image
sz = size(im);

% Gather data to be stored with each ROI
myData.Units = 'pixels';
myData.MaxValue = hypot(sz(1),sz(2));
myData.Colormap = colormap('hot');
myData.ScaleFactor = 1;

% Display image in the axes
hIm = imshow(im);

% Set the ButtonDownFcn on the image to create and start drawing ROI
hIm.ButtonDownFcn = @(~,~) startDrawing(hIm.Parent,myData);

%% Callback to Start Drawing ROI
% This is the callback function we added to the ButtonDownFcn of the image.
% Everytime the user clicks on the image (as opposed to, for example, other
% ROIs), we want to create a new line ROI, set listeners to react to clicks
% and movement, add a custom context menu, and begin drawing.
%
% This example uses the formal interface for the line ROI. This interface
% is designed to give the user additional control over the ROI. User the
% formal interface to instantiate the object, then call a method to begin
% interactive placement. In this case, we want to begin drawing whenever
% the user clicks on the image. In this callback, the user has already
% clicked and we want to use that click as the first location when drawing.
% We get the current click location from the CurrentPoint property of the
% axes, then we pass the relevant [x,y] location into the
% beginDrawingFromPoint method to allow the user to draw the ROI. These
% steps give the end user a seamless drawing and editing experience.
function startDrawing(hAx,myData)

% Create line ROI
h = images.roi.Line('Color',[0, 0, 0.5625],'UserData',myData);

% Listen to movement to update the line label
addlistener(h,'MovingROI',@updateLabel);

% Listen for clicks on the line
addlistener(h,'ROIClicked',@updateUnits);

% Get the current mouse location on the axes
cp = hAx.CurrentPoint;
cp = [cp(1,1) cp(1,2)];

% The user has already clicked on the image at the (x,y) location
% specified by cp. Begin drawing the ROI from that location.
h.beginDrawingFromPoint(cp);

% After drawing has completed, add a custom item to the context menu to
% delete all line ROIs
c = h.UIContextMenu;
uimenu(c,'Label','Delete All','Callback',@deleteAll);

end

%%
%
% <<../drawROIs.gif>>
%

%% Callback to Update ROI Label and Color
% This function is called whenever the ROI is moving. We want to update the
% ROI Color and Label based on the length of the line. This function is
% called frequently as the ROI is moving because we set a listener to
% listen to the 'MovingROI' event. If we want to update the ROI only once
% the movement has finished, we could listen to the 'ROIMoved' event.
function updateLabel(src,evt)

% Get the current line position
pos = evt.Source.Position;

% Determine the length of the line
diffPos = diff(pos);
mag = hypot(diffPos(1),diffPos(2));

% Choose a color from the color map based on the length of the line. The
% line will change color as it gets longer or shorter.
color = src.UserData.Colormap(ceil(64*(mag/src.UserData.MaxValue)),:);

% Apply scale factor to line length to convert pixels to the specified
% units
mag = mag*src.UserData.ScaleFactor;

% Update the label
set(src,'Label',[num2str(mag,'%30.1f') ' ' src.UserData.Units],'Color',color);

end

%% Callback to Update Measurement Units
% This function is called whenever the ROI is clicked. We want to allow
% users to double click on the label and enter information into a popup
% dialog. We can accomplish this by listening to the 'ROIClicked' event and
% using the event data to check the type of click and the part of the ROI
% that was clicked.
%
% The dialog will prompt the user to enter a known distance and units for
% this ROI. With this information, we can find all the other line ROIs in
% the axes and scale their distances accordingly. We can also package this
% new scale factor with the ROI UserData and reset the image's
% ButtonDownFcn so that new ROIs will also be scaled correctly.
function updateUnits(src,evt)

% If user double clicks on label, open input dialog to specify known
% distance to scale all line measurements
if strcmp(evt.SelectionType,'double') && strcmp(evt.SelectedPart,'label')
    
    % Display dialog box
    answer = inputdlg({'Known distance','Distance units'},...
        'Specify known distance',[1 20],{'10','meters'});
    
    % Determine the scale factor based on dialog inputs
    num = str2double(answer{1});
    
    % Get current line length
    pos = src.Position;
    diffPos = diff(pos);
    mag = hypot(diffPos(1),diffPos(2));
    
    % The scale factor is the known value divided by the current length in
    % pixels
    scale = num/mag;
    
    % Gather data to be stored with each ROI
    myData.Units = answer{2};
    myData.MaxValue = src.UserData.MaxValue;
    myData.Colormap = src.UserData.Colormap;
    myData.ScaleFactor = scale;
    
    % Find all line ROIs in the axes and reset the data stored in the
    % UserData property
    hAx = src.Parent;
    hROIs = findobj(hAx,'Type','images.roi.Line');
    set(hROIs,'UserData',myData);
    
    % For each line ROI, update the label based on the result from the
    % input dialog
    for i = 1:numel(hROIs)
        
        pos = hROIs(i).Position;
        diffPos = diff(pos);
        mag = hypot(diffPos(1),diffPos(2));
        
        set(hROIs(i),'Label',[num2str(mag*scale,'%30.1f') ' ' answer{2}]);
        
    end
    
    % Reset ButtonDownFcn with current user data
    hIm = findobj(hAx,'Type','image');
    hIm.ButtonDownFcn = @(~,~) startDrawing(hAx,myData);
    
end

end

%%
%
% <<../setUnits.gif>>
%

%% Callback to Delete All ROIs
% In this example, we added a custom context menu item to each line ROI.
% This is the callback associated with that custom context menu. We want to
% provide an option to delete all line ROIs drawn in the axes. This
% callback uses findobj to search for the ROI Type and deletes any found
% ROIs.
function deleteAll(src,~)

hFig = ancestor(src,'figure');
hROIs = findobj(hFig,'Type','images.roi.Line');
delete(hROIs)

end

%%
%
% <<../deleteAll.gif>>
%