
function [fig, ax] = makePlot(x, y, labels, filename, opts)
% makePlot - Publication-ready plots for the ITC project.
%
% Example:
% itcPlot(t, [reference, measured], ...
%     ["Reference", "Measured"], "altitude_tracking", ...
%     YLabel="Altitude (m)");
%
% x, y:
%   Numeric arrays: shared x, one y-column per signal.
%   Cell arrays:    individual x/y vectors per signal.
%
% filename:
%   Output filename without extension.
%   Use "" to skip export.

arguments
    x
    y
    labels = string.empty
    filename (1,1) string = ""
    opts.XLabel (1,1) string = "Time (s)"
    opts.YLabel (1,1) string = ""
    opts.Title (1,1) string = ""
    opts.WidthCm (1,1) double {mustBePositive} = 12.5
    opts.HeightCm (1,1) double {mustBePositive} = 7.5
    opts.XLim (1,2) double = [-inf inf]
    opts.YLim (1,2) double = [-inf inf]
    opts.Grid (1,1) logical = true
    opts.LegendLocation (1,1) string = "best"
    opts.OutputDir (1,1) string = "figures"
    opts.SaveFig (1,1) logical = true
    opts.PlotTypes (1,:) string = "line"
    opts.MarkerSize (1,1) double {mustBePositive} = 12
    opts.YAxis (1,:) string = "left"
    opts.YLabelRight (1,1) string = ""
    opts.YLimRight (1,2) double = [-inf inf]
end

%% Normalize input data
if isnumeric(y)
    if ~isnumeric(x) || ~isvector(x)
        error("For numeric y, x must be a numeric vector.");
    end

    x = x(:);
    if isvector(y)
        y = y(:);
    end

    if size(y,1) ~= numel(x)
        error("Rows of y must match the length of x.");
    end

    n = size(y,2);
    X = repmat({x}, 1, n);
    Y = arrayfun(@(k) y(:,k), 1:n, ...
        'UniformOutput', false);

elseif iscell(y)
    n = numel(y);

    if iscell(x)
        if numel(x) ~= n
            error("x and y cell arrays must have equal length.");
        end
        X = x;
    elseif isnumeric(x) && isvector(x)
        X = repmat({x}, 1, n);
    else
        error("Invalid x input.");
    end

    Y = y;
else
    error("y must be numeric or a cell array.");
end

for k = 1:n
    if ~isnumeric(X{k}) || ~isnumeric(Y{k}) || ...
            ~isvector(X{k}) || ~isvector(Y{k}) || ...
            numel(X{k}) ~= numel(Y{k})
        error("Signal %d has invalid or mismatched data.", k);
    end

    X{k} = X{k}(:);
    Y{k} = Y{k}(:);
end

if ~isempty(labels) && numel(labels) ~= n
    error("Number of labels must equal number of signals.");
end

%% Project color palette
colors = [
    0.000 0.447 0.698;  % Blue
    0.9 0.1 0.000;  % Orange
    0.000 0.620 0.451;  % Green
    0.494 0.314 0.627;  % Purple
    0.350 0.350 0.350;  % Gray
    0.800 0.475 0.655;  % Pink
];

styles = {'-', '--', '-.', ':'};

%% Create figure
fig = figure( ...
    'Color', 'w', ...
    'Units', 'centimeters', ...
    'Position', [3 3 opts.WidthCm opts.HeightCm], ...
    'Renderer', 'painters');

ax = axes('Parent', fig);
hold(ax, 'on');

%% Plot signals

%% Plot signals

% Expand a single plot type to all datasets
plotTypes = opts.PlotTypes;

if isscalar(plotTypes)
    plotTypes = repmat(plotTypes, 1, n);
elseif numel(plotTypes) ~= n
    error("PlotTypes must have one entry per dataset.");
end

    % if plotTypes(1) == "scatter"
    %     lineStyle = "-";
    % else
    %     lineStyle = styles{styleIndex};
    % end

% Expand axis assignment to all datasets
yAxes = opts.YAxis;
if isscalar(yAxes)
    yAxes = repmat(yAxes, 1, n);
end

% Validate options
if numel(plotTypes) ~= n || numel(yAxes) ~= n
    error("PlotTypes and YAxis must have one entry per dataset.");
end

if ~all(ismember(yAxes, ["left", "right"]))
    error('YAxis entries must be "left" or "right".');
end

useRightAxis = any(yAxes == "right");

% Plot each signal on its assigned axis
for k = 1:n
    if useRightAxis
        yyaxis(ax, char(yAxes(k)));
    end

    colorIndex = mod(k-1, size(colors,1)) + 1;
    styleIndex = mod(k-1, numel(styles)) + 1;

    color = colors(colorIndex,:);

    switch plotTypes(k)
        case "scatter"
            scatter(ax, X{k}, Y{k}, ...
                opts.MarkerSize, color, ...
                'filled');

        case "line"
            plot(ax, X{k}, Y{k}, ...
                'Color', color, ...
                'LineStyle', styles{styleIndex}, ...
                'LineWidth', 1.4);

        case "line+markers"
            plot(ax, X{k}, Y{k}, ...
                'Color', color, ...
                'LineStyle', styles{styleIndex}, ...
                'LineWidth', 1.2, ...
                'Marker', '.', ...
                'MarkerSize', 8);

        otherwise
            error("Unknown plot type: %s", plotTypes(k));
    end
end


%% Axes formatting
set(ax, ...
    'FontName', 'Times New Roman', ...
    'FontSize', 9, ...
    'LineWidth', 0.8, ...
    'TickDir', 'out', ...
    'Box', 'off', ...
    'Layer', 'top', ...
    'XColor', [0.15 0.15 0.15]);

% , ...
%     'YColor', [0.15 0.15 0.15]

xlabel(ax, opts.XLabel, ...
    'FontName', 'Times New Roman', ...
    'FontSize', 10, ...
    'Interpreter', 'tex');



%% Y-axis formatting

if useRightAxis
    % Left Y-axis
    yyaxis(ax, 'left');

    ylabel(ax, opts.YLabel, ...
        'FontName', 'Times New Roman', ...
        'FontSize', 10);

    if all(isfinite(opts.YLim))
        ylim(ax, opts.YLim);
    end

    % Right Y-axis
    yyaxis(ax, 'right');

    ylabel(ax, opts.YLabelRight, ...
        'FontName', 'Times New Roman', ...
        'FontSize', 10);

    if all(isfinite(opts.YLimRight))
        ylim(ax, opts.YLimRight);
    end

    % Neutral axis colors
    ax.YAxis(1).Color = [0.15 0.15 0.15];
    ax.YAxis(2).Color = [0.15 0.15 0.15];

    % Return to left axis
    yyaxis(ax, 'left');

else
    ylabel(ax, opts.YLabel, ...
        'FontName', 'Times New Roman', ...
        'FontSize', 10);

    if all(isfinite(opts.YLim))
        ylim(ax, opts.YLim);
    end
end


%% Legend
if ~isempty(labels)
    lgd = legend(ax, cellstr(labels), ...
        'Location', char(opts.LegendLocation), ...
        'Box', 'off', ...
        'FontName', 'Times New Roman', ...
        'FontSize', 9, ...
        'Interpreter', 'tex');
    lgd.AutoUpdate = 'off';
end

%% Export
if strlength(filename) > 0
    if ~isfolder(opts.OutputDir)
        mkdir(opts.OutputDir);
    end

    basePath = fullfile(opts.OutputDir, filename);

    % Vector PDF for LaTeX
    exportgraphics(fig, basePath + ".pdf", ...
        'ContentType', 'vector', ...
        'BackgroundColor', 'white');

    % Editable MATLAB figure
    if opts.SaveFig
        savefig(fig, basePath + ".fig");
    end

    fprintf("Exported: %s.pdf\n", basePath);
end

end
