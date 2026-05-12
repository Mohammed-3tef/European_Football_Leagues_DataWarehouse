CREATE DATABASE European_Football_Leagues_DWH;
GO

ALTER DATABASE European_Football_Leagues_DWH
COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE European_Football_Leagues_DWH;
GO

CREATE SCHEMA DWH;
GO

CREATE TABLE DWH.Dim_Date (
   [DateKey] [int] NOT NULL,
   [Date] [date] NOT NULL,
   [Day] [tinyint] NOT NULL,
   [DaySuffix] [char](2) NOT NULL,
   [Weekday] [tinyint] NOT NULL,
   [WeekDayName] [varchar](10) NOT NULL,
   [WeekDayName_Short] [char](3) NOT NULL,
   [WeekDayName_FirstLetter] [char](1) NOT NULL,
   [DOWInMonth] [tinyint] NOT NULL,
   [DayOfYear] [smallint] NOT NULL,
   [WeekOfMonth] [tinyint] NOT NULL,
   [WeekOfYear] [tinyint] NOT NULL,
   [Month] [tinyint] NOT NULL,
   [MonthName] [varchar](10) NOT NULL,
   [MonthName_Short] [char](3) NOT NULL,
   [MonthName_FirstLetter] [char](1) NOT NULL,
   [Quarter] [tinyint] NOT NULL,
   [QuarterName] [varchar](6) NOT NULL,
   [Year] [int] NOT NULL,
   [MMYYYY] [char](6) NOT NULL,
   [MonthYear] [char](7) NOT NULL,
   [IsWeekend] BIT NOT NULL,
   [IsHoliday] BIT NOT NULL,
   [HolidayName] VARCHAR(20) NULL,
   [SpecialDays] VARCHAR(20) NULL,
   [FirstDateofYear] DATE NULL,
   [LastDateofYear] DATE NULL,
   [FirstDateofQuater] DATE NULL,
   [LastDateofQuater] DATE NULL,
   [FirstDateofMonth] DATE NULL,
   [LastDateofMonth] DATE NULL,
   [FirstDateofWeek] DATE NULL,
   [LastDateofWeek] DATE NULL,
   [CurrentYear] SMALLINT NULL,
   [CurrentQuater] SMALLINT NULL,
   [CurrentMonth] SMALLINT NULL,
   [CurrentWeek] SMALLINT NULL,
   [CurrentDay] SMALLINT NULL,
   PRIMARY KEY CLUSTERED ([DateKey] ASC)
);

SET NOCOUNT ON

DECLARE @CurrentDate DATE = '2010-01-01'
DECLARE @EndDate DATE = '2030-12-31'

WHILE @CurrentDate < @EndDate
BEGIN
   INSERT INTO DWH.Dim_Date (
      [DateKey],
      [Date],
      [Day],
      [DaySuffix],
      [Weekday],
      [WeekDayName],
      [WeekDayName_Short],
      [WeekDayName_FirstLetter],
      [DOWInMonth],
      [DayOfYear],
      [WeekOfMonth],
      [WeekOfYear],
      [Month],
      [MonthName],
      [MonthName_Short],
      [MonthName_FirstLetter],
      [Quarter],
      [QuarterName],
      [Year],
      [MMYYYY],
      [MonthYear],
      [IsWeekend],
      [IsHoliday],
      [FirstDateofYear],
      [LastDateofYear],
      [FirstDateofQuater],
      [LastDateofQuater],
      [FirstDateofMonth],
      [LastDateofMonth],
      [FirstDateofWeek],
      [LastDateofWeek]
      )
   SELECT DateKey = YEAR(@CurrentDate) * 10000 + MONTH(@CurrentDate) * 100 + DAY(@CurrentDate),
      DATE = @CurrentDate,
      Day = DAY(@CurrentDate),
      [DaySuffix] = CASE 
         WHEN DAY(@CurrentDate) = 1
            OR DAY(@CurrentDate) = 21
            OR DAY(@CurrentDate) = 31
            THEN 'st'
         WHEN DAY(@CurrentDate) = 2
            OR DAY(@CurrentDate) = 22
            THEN 'nd'
         WHEN DAY(@CurrentDate) = 3
            OR DAY(@CurrentDate) = 23
            THEN 'rd'
         ELSE 'th'
         END,
      WEEKDAY = DATEPART(dw, @CurrentDate),
      WeekDayName = DATENAME(dw, @CurrentDate),
      WeekDayName_Short = UPPER(LEFT(DATENAME(dw, @CurrentDate), 3)),
      WeekDayName_FirstLetter = LEFT(DATENAME(dw, @CurrentDate), 1),
      [DOWInMonth] = DAY(@CurrentDate),
      [DayOfYear] = DATENAME(dy, @CurrentDate),
      [WeekOfMonth] = DATEPART(WEEK, @CurrentDate) - DATEPART(WEEK, DATEADD(MM, DATEDIFF(MM, 0, @CurrentDate), 0)) + 1,
      [WeekOfYear] = DATEPART(wk, @CurrentDate),
      [Month] = MONTH(@CurrentDate),
      [MonthName] = DATENAME(mm, @CurrentDate),
      [MonthName_Short] = UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
      [MonthName_FirstLetter] = LEFT(DATENAME(mm, @CurrentDate), 1),
      [Quarter] = DATEPART(q, @CurrentDate),
      [QuarterName] = CASE 
         WHEN DATENAME(qq, @CurrentDate) = 1
            THEN 'First'
         WHEN DATENAME(qq, @CurrentDate) = 2
            THEN 'second'
         WHEN DATENAME(qq, @CurrentDate) = 3
            THEN 'third'
         WHEN DATENAME(qq, @CurrentDate) = 4
            THEN 'fourth'
         END,
      [Year] = YEAR(@CurrentDate),
      [MMYYYY] = RIGHT('0' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)), 2) + CAST(YEAR(@CurrentDate) AS VARCHAR(4)),
      [MonthYear] = CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + UPPER(LEFT(DATENAME(mm, @CurrentDate), 3)),
      [IsWeekend] = CASE 
         WHEN DATENAME(dw, @CurrentDate) = 'Sunday'
            OR DATENAME(dw, @CurrentDate) = 'Saturday'
            THEN 1
         ELSE 0
         END,
      [IsHoliday] = 0,
      [FirstDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-01-01' AS DATE),
      [LastDateofYear] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-12-31' AS DATE),
      [FirstDateofQuater] = DATEADD(qq, DATEDIFF(qq, 0, GETDATE()), 0),
      [LastDateofQuater] = DATEADD(dd, - 1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) + 1, 0)),
      [FirstDateofMonth] = CAST(CAST(YEAR(@CurrentDate) AS VARCHAR(4)) + '-' + CAST(MONTH(@CurrentDate) AS VARCHAR(2)) + '-01' AS DATE),
      [LastDateofMonth] = EOMONTH(@CurrentDate),
      [FirstDateofWeek] = DATEADD(dd, - (DATEPART(dw, @CurrentDate) - 1), @CurrentDate),
      [LastDateofWeek] = DATEADD(dd, 7 - (DATEPART(dw, @CurrentDate)), @CurrentDate)

   SET @CurrentDate = DATEADD(DD, 1, @CurrentDate)
END

--Update Holiday information
UPDATE DWH.Dim_Date
SET [IsHoliday] = 1, [HolidayName] = 'Christmas'
WHERE [Month] = 12 AND [DAY] = 25

UPDATE DWH.Dim_Date
SET SpecialDays = 'Valentines Day'
WHERE [Month] = 2 AND [DAY] = 14

--Update current date information
UPDATE DWH.Dim_Date
SET CurrentYear = DATEDIFF(yy, GETDATE(), DATE),
    CurrentQuater = DATEDIFF(q, GETDATE(), DATE),
    CurrentMonth = DATEDIFF(m, GETDATE(), DATE),
    CurrentWeek = DATEDIFF(ww, GETDATE(), DATE),
    CurrentDay = DATEDIFF(dd, GETDATE(), DATE);

CREATE TABLE DWH.Dim_League (
    League_key INT IDENTITY PRIMARY KEY,
    League_id INT,
    Name NVARCHAR(255),
    Country NVARCHAR(100)
);

CREATE TABLE DWH.Dim_Team (
    Team_key INT IDENTITY PRIMARY KEY,
    Team_id INT,
    Name NVARCHAR(255),
    Founded_year INT,
    Start_date DATETIME,
    End_date DATETIME,
    Current_flag BIT
);
 
CREATE TABLE DWH.Dim_Stadium (
    Stadium_key INT IDENTITY PRIMARY KEY,
    Stadium_id INT,
    Name NVARCHAR(255),
    Location NVARCHAR(255),
    Capacity FLOAT,
    Start_date DATETIME,
    End_date DATETIME,
    Current_flag BIT
);
 
CREATE TABLE DWH.Dim_Coach (
    Coach_key INT IDENTITY PRIMARY KEY,
    Coach_id INT,
    Name NVARCHAR(255),
    Nationality NVARCHAR(100)
);
 
CREATE TABLE DWH.Dim_Scoring_Junk (
    Scoring_junk_key INT IDENTITY PRIMARY KEY,
    Venue_type NVARCHAR(20),
    Is_comeback_win BIT,
    Is_lead_blown BIT,
    Is_clean_sheet BIT,
    Is_second_half_specialist BIT,
    Result_type CHAR(1)
);

CREATE TABLE DWH.Fact_Team_Monthly_Stat(
    Fact_team_stat_key INT IDENTITY PRIMARY KEY,
 
    Season_key INT,  -- DEGNERATE DIM (20232024)
    League_key INT,
    Month_key INT,
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
 
    FOREIGN KEY (Month_key) REFERENCES DWH.Dim_Date(DateKey),
    FOREIGN KEY (League_key) REFERENCES DWH.Dim_League(League_key),
    FOREIGN KEY (Team_key) REFERENCES DWH.Dim_Team(Team_key)
);
 
CREATE TABLE DWH.Fact_Scoring_Efficiency(
    Fact_scoring_key INT IDENTITY PRIMARY KEY,
 
    Season_key INT, -- DEGNERATE DIM (20232024)
    League_key INT,
    Date_key INT,
    Team_key INT,
    Opponent_key INT,
 
    Scoring_junk_key INT,
 
    Goals_1st_half INT,
    Goals_2nd_half INT,
    Goals_total INT,
    Goals_against_total INT,
 
    FOREIGN KEY (Date_key) REFERENCES DWH.Dim_Date(DateKey),
    FOREIGN KEY (League_key) REFERENCES DWH.Dim_League(League_key),
    FOREIGN KEY (Team_key) REFERENCES DWH.Dim_Team(Team_key),
    FOREIGN KEY (Opponent_key) REFERENCES DWH.Dim_Team(Team_key),
    FOREIGN KEY (Scoring_junk_key) REFERENCES DWH.Dim_Scoring_Junk(Scoring_junk_key)
);

CREATE TABLE DWH.Fact_Coach_Stadium_Performance(
    Fact_performance_key INT IDENTITY PRIMARY KEY,
 
    Season_key INT, -- DEGNERATE DIM (20232024)
    Match_key INT,
    Team_key INT,
    Coach_key INT,
    Opponent_coach_key INT,
    Stadium_key INT,
    Date_key INT,
 
    Is_home_coach BIT,
 
    Points_earned INT,
 
    Goals_scored INT,
    Goals_conceded INT,
    Goal_difference INT,
 
    Result_type CHAR(1), -- [W, D, L]
  
    FOREIGN KEY (Date_key) REFERENCES DWH.Dim_Date(DateKey),
    FOREIGN KEY (Team_key) REFERENCES DWH.Dim_Team(Team_key),
    FOREIGN KEY (Coach_key) REFERENCES DWH.Dim_Coach(Coach_key),
    FOREIGN KEY (Opponent_coach_key) REFERENCES DWH.Dim_Coach(Coach_key),
    FOREIGN KEY (Stadium_key) REFERENCES DWH.Dim_Stadium(Stadium_key)
);
