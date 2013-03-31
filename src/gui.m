function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 30-Mar-2013 15:55:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Load the neural net if given.
if size(varargin, 2) >= 1
  if ischar(varargin{1})
    handles.net = load(varargin{1});
  else
    handles.net = varargin{1};
  end
  handles.window = varargin{2};
  handles.skip = varargin{3};
end

% Put the plots in a list.
handles.plots = [handles.g1, handles.g2, handles.g3, handles.g4, ...
                 handles.g5, handles.g6, handles.g7, handles.g8, ...
		 handles.g9, handles.g10, handles.g11, handles.g12];

% Setup the lines and data.
handles.lines = zeros(size(handles.plots));
handles.ldata = zeros(size(handles.plots, 2), 10);
for i=1:size(handles.plots, 2)
  % Set current plot.
  axes(handles.plots(i));

  % Plot line and set YDataSource.
  handles.lines(i) = area(handles.ldata(i, :));
  set(handles.lines(i), 'YDataSource', 'handles.ldata(i, :)');

  % Set the axes.
  set(handles.plots(i),'XTick',[]);
  set(handles.plots(i),'YTick',[]);
  set(handles.plots(i),'XLim', [0.0, 0.9]);
  set(handles.plots(i),'YLim', [-0.1, 1.1]);
end

% Setup the camera.
tpos=[0, 0, 2.75];
cpos=tpos + [3, 2, -5];
set(handles.viewer,'CameraPosition',cpos);
set(handles.viewer,'CameraTarget',tpos);
set(handles.viewer,'CameraViewAngle',12);
set(handles.viewer,'CameraUpVector',[0 1 0]);
set(handles.viewer,'Projection','perspective');

% Setup the axes.
set(handles.viewer,'XLim', [-0.5, 0.5]);
set(handles.viewer,'YLim', [-1.0, 1.0]);
set(handles.viewer,'ZLim', [ 2.5, 3.0]);
axis(handles.viewer, 'equal');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in openbutton.
function openbutton_Callback(hObject, eventdata, handles)
% hObject    handle to openbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Select a file.
filename = uigetfile('*.csv','Select clip file');
if ~filename
   return
end
[p,name,e] = fileparts(filename);

% Set the clip name.
set(handles.clipname, 'String', name);

% List of tags.
tagset = { 'G1  lift outstretched arms', 'G2  Duck', ...
	'G3  Push right', 'G4  Goggles', 'G5  Wind it up', ...
	'G6  Shoot', 'G7  Bow', 'G8  Throw', 'G9  Had enough', ...
	'G10 Change weapon', 'G11 Beat both', 'G12 Kick' };

% Load the data from the file.
[X, Y] = load_file(name, tagset);
[Xp, Yp] = preprocess_data(X, Y, name, handles.window, handles.skip);

% Store the result.
handles.X = X;
handles.Y = Y;
handles.Xp = Xp;
handles.Yp = Yp;

% Display the inital skeleton.
axes(handles.viewer); cla;
[handles.joints, handles.bones] = gui_skel(X, 1, handles.viewer);

% Store the handles.
guidata(hObject, handles);


% --- Executes on button press in playbutton.
function playbutton_Callback(hObject, eventdata, handles)
% hObject    handle to playbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the data.
X = handles.X;
Y = handles.Y;
Xp = handles.Xp;
Yp = handles.Yp;

% Get the data size.
T=size(X,1);
Tp=size(Xp,1);

% Unset stop flag.
handles.stop = 0;
guidata(hObject, handles);

% Animate sequence
for i=1:Tp
  ti = i + (T - Tp);
  tip = i;

  % Check if the handle is still valid.
  if ~ishandle(hObject)
     break
  end

  % Check for stop flag.
  handles = guidata(hObject);
  if handles.stop
    axes(handles.viewer); cla;
    [handles.joints, handles.bones] = gui_skel(X, 1, handles.viewer);
    break;
  end

  % Update plots.
  if isfield(handles, 'net')
    % Get the input for the frame.
    x = Xp(tip, :);

    % Get the normalized network output.
    p = handles.net(x');
    p = p / sum(p);

    % Update line data.
    handles.ldata = circshift(handles.ldata, [0, 1]);
    handles.ldata(:, 1) = p(1:12);

    % Update the plots.
    for i=1:size(handles.lines, 2)
      refreshdata(handles.lines(i), 'caller');
    end
  end

  % Save the changed data.
  guidata(hObject, handles);

  % Update viewer with next frame.
  gui_skel(X, ti, handles.viewer, handles.joints, handles.bones);
  drawnow;
  %pause(1/30);
end


% --- Executes on button press in stopbutton.
function stopbutton_Callback(hObject, eventdata, handles)
% hObject    handle to stopbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set stop flag.
handles.stop = 1;
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
