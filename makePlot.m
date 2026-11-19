
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
    opts.PlotTypes (1,1) string = "line"
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
    0.835 0.369 0.000;  % Orange
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
for k = 1:n
    colorIndex = mod(k-1, size(colors,1)) + 1;
    styleIndex = mod(k-1, numel(styles)) + 1;

    switch opts.PlotTypes
        case "scatter"
            scatter(ax, X{k}, Y{k}, 12, ...
                colors(colorIndex,:), 'filled');

        case "line+markers"
            plot(ax, X{k}, Y{k}, ...
                'Color', colors(colorIndex,:), ...
                'LineStyle', styles{styleIndex}, ...
                'LineWidth', 1.2, ...
                'Marker', '.', ...
                'MarkerSize', 7);

        case "line"
            plot(ax, X{k}, Y{k}, ...
                'Color', colors(colorIndex,:), ...
                'LineStyle', styles{styleIndex}, ...
                'LineWidth', 1.4);

        otherwise
            error("Unknown PlotTypes option: %s", opts.PlotTypes);
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
    'XColor', [0.15 0.15 0.15], ...
    'YColor', [0.15 0.15 0.15]);

xlabel(ax, opts.XLabel, ...
    'FontName', 'Times New Roman', ...
    'FontSize', 10, ...
    'Interpreter', 'tex');

ylabel(ax, opts.YLabel, ...
    'FontName', 'Times New Roman', ...
    'FontSize', 10, ...
    'Interpreter', 'tex');

if strlength(opts.Title) > 0
    title(ax, opts.Title, ...
        'FontName', 'Times New Roman', ...
        'FontSize', 10, ...
        'FontWeight', 'normal', ...
        'Interpreter', 'tex');
end

if opts.Grid
    grid(ax, 'on');
    ax.GridColor = [0.75 0.75 0.75];
    ax.GridAlpha = 0.18;
    ax.XMinorGrid = 'off';
    ax.YMinorGrid = 'off';
else
    grid(ax, 'off');
end

if all(isfinite(opts.XLim))
    xlim(ax, opts.XLim);
end

if all(isfinite(opts.YLim))
    ylim(ax, opts.YLim);
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
