-- Fulfills KPI 1 (Total Points), KPI 2 (Total Wins), KPI 3 (Total Draws), and KPI 4 (Total Losses) at the Team and Season level.
SELECT 
    T.Name AS Team_Name,
    SUM(F.Points_total) AS Total_Points,
    SUM(F.Total_wins_count) AS Total_Wins,
    SUM(F.Draw_count) AS Total_Draws,
    SUM(F.Loss_count) AS Total_Losses
FROM DWH.Fact_Team_Monthly_Stat F
JOIN DWH.Dim_Team T ON F.Team_key = T.Team_key
GROUP BY T.Name;

-- Fulfills KPI 5 (Goals Scored), KPI 6 (Goals Conceded), and KPI 7 (Goal Difference).
SELECT 
    T.Name AS Team_Name,
    SUM(F.Goals_count) AS Total_Goals_Scored,
    SUM(F.Goals_conceded) AS Total_Goals_Conceded,
    SUM(F.Goal_difference) AS Total_Goal_Difference
FROM DWH.Fact_Team_Monthly_Stat F
JOIN DWH.Dim_Team T ON F.Team_key = T.Team_key
GROUP BY T.Name;

-- Fulfills KPI 8 (Matches Played), KPI 9 (Win Rate), and KPI 10 (Points per Match) to evaluate team efficiency.
SELECT 
    T.Name AS Team_Name,
    SUM(F.Total_matches_played) AS Matches_Played,
    (CAST(SUM(F.Total_wins_count) AS FLOAT) / NULLIF(SUM(F.Total_matches_played), 0)) * 100 AS Win_Rate,
    CAST(SUM(F.Points_total) AS FLOAT) / NULLIF(SUM(F.Total_matches_played), 0) AS Avg_Points_Per_Match
FROM DWH.Fact_Team_Monthly_Stat F
JOIN DWH.Dim_Team T ON F.Team_key = T.Team_key
GROUP BY T.Name;

-- Fulfills KPI 11 (Total League Goals), KPI 12 (Average Goals per Match), and KPI 13 (Total Matches) at the League and Season level.
SELECT 
    L.Name AS League_Name,
    SUM(F.Goals_count) AS Total_League_Goals,
    CAST(SUM(F.Goals_count) AS FLOAT) / SUM(F.Total_matches_played) AS Avg_Goals_Per_Match,
    SUM(F.Total_matches_played) AS Total_League_Matches
FROM DWH.Fact_Team_Monthly_Stat F
JOIN DWH.Dim_League L ON F.League_key = L.League_key
GROUP BY L.Name;

-- Fulfills KPI 16 (Home Advantage Ratio) by calculating the percentage of home wins relative to total league wins.
SELECT 
    L.Name AS League_Name,
    CAST(SUM(F.Home_wins_count) AS FLOAT) / NULLIF(SUM(F.Total_wins_count), 0) AS Home_Advantage_Ratio
FROM DWH.Fact_Team_Monthly_Stat F
JOIN DWH.Dim_League L ON F.League_key = L.League_key
GROUP BY L.Name;

-- Fulfills KPI 18 (First Half Goals) and KPI 19 (Second Half Goals) to analyze scoring timing and endurance.
SELECT 
    T.Name AS Team_Name,
    SUM(F.Goals_1st_half) AS Total_1st_Half_Goals,
    SUM(F.Goals_2nd_half) AS Total_2nd_Half_Goals
FROM DWH.Fact_Scoring_Efficiency F
JOIN DWH.Dim_Team T ON F.Team_key = T.Team_key
GROUP BY T.Name;

-- Fulfills KPI 20 (Comeback Matches Count) and KPI 21 (Clean Sheet Matches) using specific flags from the Scoring Junk dimension.
SELECT 
    T.Name AS Team_Name,
    COUNT(CASE WHEN J.Is_comeback_win = 1 THEN 1 END) AS Comeback_Count,
    COUNT(CASE WHEN J.Is_clean_sheet = 1 THEN 1 END) AS Clean_Sheet_Count
FROM DWH.Fact_Scoring_Efficiency F
JOIN DWH.Dim_Team T ON F.Team_key = T.Team_key
JOIN DWH.Dim_Scoring_Junk J ON F.Scoring_junk_key = J.Scoring_junk_key
GROUP BY T.Name;

-- Fulfills KPI 27 (Coach Win Rate) and KPI 28 (Coach Points per Match) to measure managerial effectiveness.
SELECT 
    C.Name AS Coach_Name,
    (CAST(COUNT(CASE WHEN F.Result_type = 'W' THEN 1 END) AS FLOAT) / COUNT(*)) * 100 AS Coach_Win_Rate,
    AVG(CAST(F.Points_earned AS FLOAT)) AS Coach_Points_Per_Match
FROM DWH.Fact_Coach_Stadium_Performance F
JOIN DWH.Dim_Coach C ON F.Coach_key = C.Coach_key
GROUP BY C.Name;

-- Fulfills KPI 29 (Home Stadium Win Rate) by calculating success rates at specific venues.
SELECT 
    S.Name AS Stadium_Name,
    (CAST(COUNT(CASE WHEN F.Result_type = 'W' AND F.Is_home_coach = 1 THEN 1 END) AS FLOAT) / 
     NULLIF(COUNT(CASE WHEN F.Is_home_coach = 1 THEN 1 END), 0)) * 100 AS Home_Stadium_Win_Rate
FROM DWH.Fact_Coach_Stadium_Performance F
JOIN DWH.Dim_Stadium S ON F.Stadium_key = S.Stadium_key
GROUP BY S.Name;

-- Fulfills KPI 26 (Monthly Performance Trend) by tracking goal and point aggregation per month.
SELECT 
    T.Name AS Team_Name,
    D.MonthName,
    SUM(F.Goals_count) AS Monthly_Goals,
    SUM(F.Points_total) AS Monthly_Points
FROM DWH.Fact_Team_Monthly_Stat F
JOIN DWH.Dim_Team T ON F.Team_key = T.Team_key
JOIN DWH.Dim_Date D ON F.Month_key = D.DateKey
GROUP BY T.Name, D.MonthName, D.Month
ORDER BY T.Name, D.Month;

-- Analyzes match behavior flags from the Junk Dimension to identify teams classified as "Second Half Specialists".
SELECT 
    T.Name AS Team_Name,
    SUM(F.Goals_1st_half) AS Total_1st_Half,
    SUM(F.Goals_2nd_half) AS Total_2nd_Half,
    COUNT(CASE WHEN J.Is_second_half_specialist = 1 THEN 1 END) AS Specialist_Match_Count
FROM DWH.Fact_Scoring_Efficiency F
JOIN DWH.Dim_Team T ON F.Team_key = T.Team_key
JOIN DWH.Dim_Scoring_Junk J ON F.Scoring_junk_key = J.Scoring_junk_key
GROUP BY T.Name
ORDER BY Specialist_Match_Count DESC;

-- Fulfills KPI 30 (Coach Impact Score) by analyzing head-to-head performance against opponent managers.
SELECT 
    C.Name AS Coach_Name,
    OC.Name AS Opponent_Coach_Name,
    COUNT(*) AS Matches_Played,
    SUM(F.Points_earned) AS Points_Gained_In_Matchup
FROM DWH.Fact_Coach_Stadium_Performance F
JOIN DWH.Dim_Coach C ON F.Coach_key = C.Coach_key
JOIN DWH.Dim_Coach OC ON F.Opponent_coach_key = OC.Coach_key
GROUP BY C.Name, OC.Name
ORDER BY Points_Gained_In_Matchup DESC;

-- Contributes to KPI 30 (Coach Impact Score) and general Stadium Performance by correlating venue capacity with point accumulation.
SELECT 
    S.Name AS Stadium_Name,
    S.Capacity,
    AVG(CAST(F.Points_earned AS FLOAT)) AS Avg_Points_At_Venue
FROM DWH.Fact_Coach_Stadium_Performance F
JOIN DWH.Dim_Stadium S ON F.Stadium_key = S.Stadium_key
GROUP BY S.Name, S.Capacity
ORDER BY Avg_Points_At_Venue DESC;

-- Fulfills KPI 17 (Total Goals per Match) aggregated at the League and Season level to identify high-scoring trends.
SELECT 
    L.Name AS League_Name,
    F.Season_key,
    AVG(CAST(F.Goals_total AS FLOAT)) AS Avg_Goals_Per_Match
FROM DWH.Fact_Scoring_Efficiency F
JOIN DWH.Dim_League L ON F.League_key = L.League_key
GROUP BY L.Name, F.Season_key
ORDER BY Avg_Goals_Per_Match DESC;

-- Supports "Competitive Balance Index" (KPI 15) by measuring the consistency (volatility) of team performance across months.
SELECT 
    T.Name AS Team_Name,
    L.Name AS League_Name,
    STDEV(F.Points_total) AS Points_Volatility,
    AVG(F.Points_total) AS Average_Monthly_Points
FROM DWH.Fact_Team_Monthly_Stat F
JOIN DWH.Dim_Team T ON F.Team_key = T.Team_key
JOIN DWH.Dim_League L ON F.League_key = L.League_key
GROUP BY T.Name, L.Name
ORDER BY Points_Volatility ASC;

-- Provides an advanced analysis of Stadium Performance (KPI 29) by categorizing venues into tiers based on capacity.
SELECT 
    CASE 
        WHEN S.Capacity >= 50000 THEN 'Elite (50k+)'
        WHEN S.Capacity >= 30000 THEN 'Large (30k-50k)'
        ELSE 'Medium/Small (<30k)'
    END AS Stadium_Tier,
    AVG(CAST(F.Points_earned AS FLOAT)) AS Avg_Points_Per_Match,
    SUM(F.Goals_scored) AS Total_Goals_At_Tier
FROM DWH.Fact_Coach_Stadium_Performance F
JOIN DWH.Dim_Stadium S ON F.Stadium_key = S.Stadium_key
GROUP BY 
    CASE 
        WHEN S.Capacity >= 50000 THEN 'Elite (50k+)'
        WHEN S.Capacity >= 30000 THEN 'Large (30k-50k)'
        ELSE 'Medium/Small (<30k)'
    END;

-- Analyzes "Second Half Goals" (KPI 19) to identify teams with a high offensive surge ratio in the final 45 minutes.
SELECT 
    T.Name AS Team_Name,
    SUM(F.Goals_1st_half) AS FH_Goals,
    SUM(F.Goals_2nd_half) AS SH_Goals,
    CAST(SUM(F.Goals_2nd_half) AS FLOAT) / NULLIF(SUM(F.Goals_total), 0) AS SH_Goal_Ratio
FROM DWH.Fact_Scoring_Efficiency F
JOIN DWH.Dim_Team T ON F.Team_key = T.Team_key
GROUP BY T.Name
HAVING CAST(SUM(F.Goals_2nd_half) AS FLOAT) / NULLIF(SUM(F.Goals_total), 0) > 0.6
ORDER BY SH_Goal_Ratio DESC;

-- Refines Coach performance metrics (KPI 28) by isolating results and tactical scoring patterns in Away matches.
SELECT 
    C.Name AS Coach_Name,
    COUNT(F.Fact_performance_key) AS Away_Matches,
    AVG(CAST(F.Points_earned AS FLOAT)) AS Avg_Away_Points,
    SUM(SE.Goals_2nd_half) AS Total_SH_Goals_Away
FROM DWH.Fact_Coach_Stadium_Performance F
JOIN DWH.Dim_Coach C ON F.Coach_key = C.Coach_key
JOIN DWH.Fact_Scoring_Efficiency SE ON F.Team_key = SE.Team_key 
    AND F.Date_key = SE.Date_key 
WHERE F.Is_home_coach = 0 
GROUP BY C.Name
ORDER BY Avg_Away_Points DESC;

-- Utilizes match behavior flags (Is_lead_blown) from the Scoring Junk dimension to analyze tactical failure rates for Coaches.
SELECT 
    C.Name AS Coach_Name,
    COUNT(F.Fact_performance_key) AS Matches_Led_At_HT,
    COUNT(CASE WHEN J.Is_lead_blown = 1 THEN 1 END) AS Leads_Blown,
    (CAST(COUNT(CASE WHEN J.Is_lead_blown = 1 THEN 1 END) AS FLOAT) / COUNT(*)) * 100 AS Lead_Blowing_Rate
FROM DWH.Fact_Coach_Stadium_Performance F
JOIN DWH.Dim_Coach C ON F.Coach_key = C.Coach_key
JOIN DWH.Fact_Scoring_Efficiency SE ON F.Team_key = SE.Team_key AND F.Date_key = SE.Date_key
JOIN DWH.Dim_Scoring_Junk J ON SE.Scoring_junk_key = J.Scoring_junk_key
GROUP BY C.Name
ORDER BY Lead_Blowing_Rate DESC;