CREATE DATABASE European_Football_Leagues;
GO

ALTER DATABASE European_Football_Leagues
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE European_Football_Leagues;
GO

CREATE TABLE stadiums (
    stadium_id INT PRIMARY KEY,
    name NVARCHAR(255),
    location NVARCHAR(255),
    capacity FLOAT,
    updated_at DATETIME DEFAULT ('2024-08-01')
);

CREATE TABLE leagues (
    league_id INT PRIMARY KEY,
    name NVARCHAR(255),
    country NVARCHAR(100),
    country_id INT,
    icon_url NVARCHAR(MAX),
    cl_spot INT,
    uel_spot INT,
    relegation_spot INT,
    updated_at DATETIME DEFAULT ('2024-08-01')
);

CREATE TABLE coaches (
    coach_id INT PRIMARY KEY,
    name NVARCHAR(255),
    team_id INT NULL,
    nationality NVARCHAR(100),
    updated_at DATETIME DEFAULT ('2024-08-01')
);

CREATE TABLE teams (
    team_id INT PRIMARY KEY,
    name NVARCHAR(255),
    founded_year INT,
    stadium_id INT,
    league_id INT,
    coach_id INT,
    cresturl NVARCHAR(MAX),
    updated_at DATETIME DEFAULT ('2024-08-01'),
    
    CONSTRAINT FK_teams_stadium
        FOREIGN KEY (stadium_id) REFERENCES stadiums(stadium_id),

    CONSTRAINT FK_teams_league
        FOREIGN KEY (league_id) REFERENCES leagues(league_id),

    CONSTRAINT FK_teams_coach
        FOREIGN KEY (coach_id) REFERENCES coaches(coach_id)
);

CREATE TABLE players (
    player_id INT PRIMARY KEY,
    team_id INT,
    name NVARCHAR(255),
    position NVARCHAR(100),
    date_of_birth DATE,
    nationality NVARCHAR(100),
    updated_at DATETIME DEFAULT ('2024-08-01'),

    CONSTRAINT FK_players_team
        FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE referees (
    referee_id INT PRIMARY KEY,
    name NVARCHAR(255),
    nationality NVARCHAR(MAX),
    updated_at DATETIME DEFAULT ('2024-08-01')
);

CREATE TABLE seasons (
    season_id INT,
    league_id INT,
    year NVARCHAR(20),
    updated_at DATETIME DEFAULT ('2024-08-01'),

    CONSTRAINT PK_seasons 
        PRIMARY KEY (season_id, league_id),

    CONSTRAINT FK_seasons_league
        FOREIGN KEY (league_id) REFERENCES leagues(league_id)
);

CREATE TABLE matches (
    match_id INT PRIMARY KEY,
    season_id INT,
    league_id INT,
    matchday INT,
    home_team_id INT,
    away_team_id INT,
    winner NVARCHAR(50),
    utc_date DATETIME2,
    updated_at DATETIME DEFAULT ('2024-08-01'),

    CONSTRAINT FK_matches_season
        FOREIGN KEY (season_id, league_id) 
        REFERENCES seasons(season_id, league_id),

    CONSTRAINT FK_matches_league
        FOREIGN KEY (league_id) REFERENCES leagues(league_id),

    CONSTRAINT FK_matches_home_team
        FOREIGN KEY (home_team_id) REFERENCES teams(team_id),

    CONSTRAINT FK_matches_away_team
        FOREIGN KEY (away_team_id) REFERENCES teams(team_id)
);

CREATE TABLE scores (
    score_id INT PRIMARY KEY,
    match_id INT,
    full_time_home INT,
    full_time_away INT,
    half_time_home INT,
    half_time_away INT,
    updated_at DATETIME DEFAULT ('2024-08-01'),

    CONSTRAINT FK_scores_match
        FOREIGN KEY (match_id) REFERENCES matches(match_id)
);

CREATE TABLE standings (
    standing_id INT PRIMARY KEY,
    season_id INT,
    league_id INT,
    position INT,
    team_id INT,
    played_games INT,
    won INT,
    draw INT,
    lost INT,
    points INT,
    goals_for INT,
    goals_against INT,
    goal_difference INT,
    form NVARCHAR(50),
    updated_at DATETIME DEFAULT ('2024-08-01'),

    CONSTRAINT FK_standings_season
        FOREIGN KEY (season_id, league_id) 
        REFERENCES seasons(season_id, league_id),

    CONSTRAINT FK_standings_league
        FOREIGN KEY (league_id) REFERENCES leagues(league_id),

    CONSTRAINT FK_standings_team
        FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

----Delete_All_Data
--DELETE FROM scores;
--DELETE FROM matches;
--DELETE FROM players;
--DELETE FROM standings;
--UPDATE coaches SET team_id = NULL;
--DELETE FROM teams;
--DELETE FROM coaches;
--DELETE FROM seasons;
--DELETE FROM stadiums;
--DELETE FROM leagues;