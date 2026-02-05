% ==== 原始数据 ====
clear all;  close all;  clc;
year = [2025 2024 2023 2022 2021 2020 2019 2018 2017 2016 2015 2014 2013 ...
        2012 2011 2010 2009 2008 2007 2006 2005 2004 2003 2002 2001 2000];
without_ai = [434	704	584	689	615	516	546	502	485	476	463	459	426	447 ...
    339	403	289	218	211	178	133	92	80	55	60	31];
with_ai    = [34	37	32	37	12	17	11	12	13	11	4	6	10	11	6 ...
4	0	2	6	2	4	1	4	0.1	0.1	0];
perc = 100*with_ai./without_ai;


% ==== 排序为升序（建议） ====
[yrs, idx] = sort(year);
with_ai    = with_ai(idx);
without_ai = without_ai(idx);
perc       = perc(idx);

% ==== 计算总量 ====
total = without_ai;

% ==== 平滑参数与方法（可调） ====
% 窗长：用样本数的 ~8%，至少3
win = max(3, ceil(numel(yrs) * 0.08));
win_2 = max(3, ceil(numel(yrs) * 0.08));
% 数量曲线方法：'movmean' or 'sgolay'
methodCounts = 'movmean';
% 占比曲线方法：'rlowess'（稳健LOWESS）
methodRatio  = 'rlowess';

% ==== 生成平滑曲线（仅用于绘图） ====
total_s   = smoothdata(total,   methodCounts, win);
withai_s  = smoothdata(with_ai, methodCounts, win);
% 占比直接平滑（不从平滑数量比值推，因为那样可能失真）
ratio_s   = smoothdata(perc,    methodRatio,  win);

%% ==== 作图（新版）====
%% ==== 作图（线性坐标 + 莫兰迪色柱状图）====
figure('Color','w');
set(gcf,'Position',[100 100 900 480]);   % 适当调大一点窗口
hold on;

% ==== 统一颜色定义 ====
colTotalLine  = [0 0.28 0.55];      % 深蓝：总量平滑线
colTotalPoint = [0.70 0.82 0.96];   % 浅蓝：总量散点
colAIline     = [0.00 0.55 0.35];   % 墨绿：AI 平滑线
colAIpoint    = [0.67 0.87 0.80];   % 浅绿：AI 散点

% 莫兰迪色（偏灰的粉棕色，可以根据喜好微调 RGB）
colBar        = [0.78 0.45 0.50];

%% ==== 左轴：论文数量（线性坐标）====
yyaxis left

% 原始散点
hTotalRaw = scatter(yrs, total, 32, ...
    'o', ...
    'MarkerFaceColor', colTotalPoint, ...
    'MarkerEdgeColor', colTotalLine, ...
    'LineWidth', 0.8, ...
    'DisplayName','FWAV (raw count)');

hold on
hAIRaw = scatter(yrs, with_ai, 32, ...
    's', ...
    'MarkerFaceColor', colAIpoint, ...
    'MarkerEdgeColor', colAIline, ...
    'LineWidth', 0.8, ...
    'DisplayName','With AI (raw count)');

% 平滑曲线（柔顺）
hTotalSmooth = plot(yrs, total_s, '-', ...
    'LineWidth', 2.0, ...
    'Color', colTotalLine, ...
    'DisplayName','FWAV (smoothed)');

hAISmooth = plot(yrs, withai_s, '-', ...
    'LineWidth', 2.0, ...
    'Color', colAIline, ...
    'DisplayName','With AI (smoothed)');

ylabel('Number of publications');
ylim([0, max(total)*1.3]);

ax = gca;
ax.YAxis(1).Color = colTotalLine;   % 左轴刻度颜色偏蓝

%% ==== 右轴：AI 占比（莫兰迪色柱状图）====
yyaxis right

hb = bar(yrs, perc, 0.8, ...
    'FaceColor', colBar, ...
    'EdgeColor', 'none', ...
    'FaceAlpha', 0.6, ...           % 透明度
    'DisplayName','AI ratio (actual)');

ylabel('Ratio (%)');
ylim([0, max(perc)*1.3]);
ax.YAxis(2).Color = colBar;         % 右轴刻度颜色与柱子协调

%% ==== 坐标轴、网格与标题 ====
xlabel('Year');
% title('Publication trends and AI method proportion');

ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridAlpha = 0.2;
ax.LineWidth = 1.0;

%% ==== 图例：包含“实际点”和“平滑线” ====
legend([hTotalRaw, hAIRaw, hTotalSmooth, hAISmooth, hb], ...
    {'FWAV (raw)', ...
     'With AI (raw)', ...
     'FWAV (smoothed)', ...
     'With AI (smoothed)', ...
     'AI ratio (bar)'}, ...
    'Location','northwest');

%% ==== 手动定义坐标轴范围 ====

% X 轴：年份范围（根据你数据是 2000–2025）
xlim([2000 2026]);
xticks(2000:2:2025);   % 每 2 年一个刻度，可按需改成 :1 或 :5

% 左轴：论文数量
yyaxis left
% 你的数据大约在 0–700 之间，这里给一点余量
ylim([0 730]);          % 或者 [0 max(total)*1.2]
yticks(0:100:800);      % 可按需要调整间隔

% 右轴：AI 占比（%）
yyaxis right
% perc 最大大概 7.8%，这里设置到 0–9 或 0–10 看起来比较舒服
ylim([0 9]);                                % 固定 0–9
% 或者写成自动一点的：ylim([0 ceil(max(perc))+1]);
yticks(0:1:9);                              % 每 1% 一个刻度


% 统一字体
set(findall(gcf,'-property','FontName'),'FontName','Times New Roman');
set(gca,'FontSize',11);
