CREATE DATABASE European_Football_Leagues_DWH;
GO

ALTER DATABASE European_Football_Leagues_DWH
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO
 
USE European_Football_Leagues_DWH;
GO
 
CREATE SCHEMA STG;
GO
  
CREATE TABLE STG.stadiums (
    stadium_id INT,
    name NVARCHAR(255),
    location NVARCHAR(255),
    capacity FLOAT,
    updated_at DATETIME
);
 
CREATE TABLE STG.leagues (
    league_id INT,
    name NVARCHAR(255),
    country NVARCHAR(100),
    country_id INT,
    updated_at DATETIME
);
 
CREATE TABLE STG.coaches (
    coach_id INT,
    name NVARCHAR(255),
    team_id INT NULL,
    nationality NVARCHAR(100),
    updated_at DATETIME
);
 
CREATE TABLE STG.teams (
    team_id INT,
    name NVARCHAR(255),
    founded_year INT,
    stadium_id INT,
    league_id INT,
    coach_id INT,
    updated_at DATETIME
);

CREATE TABLE STG.scoring_junk (
    Score_ID INT,
    Match_ID INT,
    
    Venue_type NVARCHAR(20),
    Full_time_home INT,  -- goals scored by home team at full time
    Full_time_away INT,  -- goals scored by away team at full time
    Half_time_home INT,  -- goals scored by home team at half time
    Half_time_away INT,  -- goals scored by away team at half time
    
    Is_comeback_win BIT DEFAULT 0,
    Is_lead_blown BIT DEFAULT 0,
    Is_clean_sheet BIT DEFAULT 0,
    Is_second_half_specialist BIT DEFAULT 0,
    Result_type CHAR(1),
    
    updated_at DATETIME
);

CREATE TABLE STG.Fact_Team_Monthly_Stat(
    Team_stat_id INT IDENTITY PRIMARY KEY,
 
    Season_key INT,  -- DEGNERATE DIM (20232024)
    League_key INT,
    Month_key DATETIME, -- first day in each month
    Team_key INT,
 
    Goals_count INT,
    Goals_conceded INT,
    Goal_difference INT,
 
    Home_wins_count INT,
    Away_wins_count INT,
    Total_wins_count INT,
 
    Draw_count INT,
    Loss_count INT,
 
    Total_matches_played INT,
    Points_total INT,

    updated_at DATETIME
);
 
CREATE TABLE STG.Fact_Scoring_Efficiency(
    Scoring_id INT IDENTITY PRIMARY KEY,
 
    Season_key INT, -- DEGNERATE DIM (20232024)
    League_key INT,
    Match_Date_key DATETIME,
    Team_key INT,
    Opponent_key INT,
 
    Scoring_junk_key INT,
 
    Goals_1st_half INT,
    Goals_2nd_half INT,
    Goals_total INT,
    Goals_against_total INT,

    updated_at DATETIME
);

CREATE TABLE STG.Fact_Coach_Stadium_Performance(
    Performance_id INT IDENTITY PRIMARY KEY,
 
    Season_key INT, -- DEGNERATE DIM (20232024)
    Date_key DATETIME,
    Match_key INT,
    Team_key INT,
    Coach_key INT,
    Opponent_coach_key INT,
    Stadium_key INT,
 
    Is_home_coach BIT,
 
    Points_earned INT,
 
    Goals_scored INT,
    Goals_conceded INT,
    Goal_difference INT,
 
    Result_type CHAR(1),  -- [W, D, L]

    updated_at DATETIME
);

CREATE TABLE STG.config_table(
    table_name VARCHAR(150) PRIMARY KEY,
    last_extract_date DATETIME
);
 
INSERT INTO STG.config_table VALUES
('stadiums', '1900-01-01'),
('leagues', '1900-01-01'),
('teams', '1900-01-01'),
('coaches', '1900-01-01'),
('scores', '1900-01-01'), 
('fact_team_monthly_stat', '1900-01-01'), 
('fact_scoring_efficiency', '1900-01-01'), 
('fact_coach_stadium_performance', '1900-01-01'); 
