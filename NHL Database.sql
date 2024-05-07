-- Create table for players
CREATE TABLE Player (
    Pname VARCHAR2(255) NOT NULL,
    Team VARCHAR2(255) NOT NULL,
    Goals float,
    Rebounds float,
    IceTime Float,
    ShotsOnGoal float,
    MissedShotAttempts float,
    ShotAttempts float,
    Penalties float,
    FaceOffs float,
    CorsiPercentage FLOAT
);

-- Create table for teams-------
CREATE TABLE Teams (
    Tname VARCHAR2(255),
    FaceOffsWon INT, 
    DivisionID INT
);

-- Create table for divisions----------
CREATE TABLE Division (
    Dname VARCHAR2(255),
    NHLDivisions VARCHAR2(255)
);



--Remove Duplicate Teams-----------
DELETE FROM Teams
WHERE ROWID NOT IN (
    SELECT MAX(ROWID)
    FROM Teams
    GROUP BY Tname
);

----Add data to FaceoffWon per team----------
UPDATE Teams
SET FaceOffsWon = (
    SELECT SUM(Player.FaceOffs)
    FROM Player
    WHERE Player.Team = Teams.Tname -- Use Teams.Tname instead of Teams.Name
);



--Define Team Divison
--1= 'East Atlantic'
--2= 'East Metropolitan'
--3= 'West Central'
--4= 'West Pacific'
UPDATE Teams
SET DivisionID = 
    CASE 
        WHEN Tname IN ('BOS', 'BUF', 'DET', 'FLA', 'MTL', 'OTT', 'TBL', 'TOR') THEN 1
        WHEN Tname IN ('CAR', 'CBJ', 'NJD', 'NYI', 'NYR', 'PHI', 'PIT', 'WSH') THEN 2
        WHEN Tname IN ('CHI', 'COL', 'DAL', 'MIN', 'NSH', 'STL', 'WPG') THEN 3
        WHEN Tname IN ('ANA', 'ARI', 'CGY', 'EDM', 'LAK', 'SJS', 'SEA', 'VAN', 'VGK') THEN 4
        ELSE 0 -- Handle cases where Tname doesn't match any abbreviation
    END;

--Define Divisons
INSERT INTO Division (Dname,NHLDivisions) 
VALUES             ('East Atlantic','1'); 
INSERT INTO Division (Dname,NHLDivisions) 
VALUES             ('East Metropolitan','2'); 
INSERT INTO Division (Dname,NHLDivisions) 
VALUES             ('West Central','3'); 
INSERT INTO Division (Dname,NHLDivisions) 
VALUES             ('West Pacific','4'); 



--Qureries like these used to inset data but automated through oracle-----
INSERT INTO PLAYER (PNAME, TEAM, GOALS, REBOUNDS, ICETIME, SHOTSONGOAL, MISSEDSHOTATTEMPTS, 
                    SHOTATTEMPTS, PENALTIES, FACEOFFS, CORSIPERCENTAGE) 
VALUES             ('Ryan Reaves', 'MIN', 0.43, 0.02, 321.0, 0.53, 1.0,
                    1.0, 0.0, 0.0, 0.0);

----Add Situation Column------------                
ALTER TABLE player
ADD (Situation VARCHAR2(50));

-----Add Player Key-------------------
ALTER TABLE Player
ADD CONSTRAINT pk_PlayerID PRIMARY KEY (PlayerID);











---------------------KEy-----------------------------------------------
-- Add a new column for the ID
ALTER TABLE temp_situation2
ADD ID INT;

-- Create a sequence for generating unique IDs
CREATE SEQUENCE temp_situation2_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

-- Create a trigger to populate the new ID column with unique values
CREATE OR REPLACE TRIGGER temp_situation2_id_trigger
BEFORE INSERT ON temp_situation2
FOR EACH ROW
BEGIN
    SELECT temp_situation2_id_seq.NEXTVAL
    INTO :new.ID
    FROM dual;
END;


-- Set the new ID column as the primary key
ALTER TABLE temp_situation2
ADD CONSTRAINT pk_temp_situation2_id PRIMARY KEY (ID);



DROP TRIGGER temp_situation2_id_trigger;

MERGE INTO Player p
USING temp_situation2 ts
ON (p.PlayerID = ts.ID)
WHEN MATCHED THEN
  UPDATE SET p.Situation = ts.Situationdescription;
  
  
  
  -------------Test Quires-------------------------------------------------- 
SELECT Pname, Goals, situation
FROM Player
WHERE Team = 'Team_Name'
ORDER BY Goals DESC;


SELECT Pname, Rebounds
FROM Player
WHERE situation = '4v5'
ORDER BY Rebounds DESC;


SELECT Team, AVG(CorsiPercentage) AS AvgCorsiPercentage
FROM Player
WHERE situation = '5v5'
GROUP BY Team
ORDER BY AvgCorsiPercentage DESC;


SELECT Pname, (SUM(ShotsOnGoal) / SUM(ShotAttempts)) AS ShootingEfficiency, situation
FROM Player
GROUP BY Pname, situation
ORDER BY Pname, situation;


SELECT Team, (1 - SUM(Penalties) / SUM(ShotAttempts)) AS PenaltyKillEfficiency
FROM Player
WHERE situation = '4v5' OR situation = '5v4'
GROUP BY Team
ORDER BY PenaltyKillEfficiency DESC;



SELECT Pname, (Goals + Rebounds + IceTime - Penalties) AS EfficiencyIndex
FROM Player
ORDER BY EfficiencyIndex DESC;




SELECT Team, (SUM(FaceOffs) / SUM(FaceOffs + Penalties)) AS FaceOffWinPercentage
FROM Player
GROUP BY Team
ORDER BY FaceOffWinPercentage DESC







--------Key for Divison---------------
ALTER TABLE Division
ADD CONSTRAINT NHLdivisions PRIMARY KEY (NHLdivisions);


--------------------Key for teams--------------------------
-- Create a sequence for generating unique IDs
CREATE SEQUENCE team_id_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

-- Alter the Teams table to add the TeamID column
ALTER TABLE Teams
ADD (TeamID INT);

-- Use the sequence to populate TeamID with unique values
UPDATE Teams
SET TeamID = team_id_seq.NEXTVAL;

-- Set TeamID as the primary key
ALTER TABLE Teams
ADD CONSTRAINT pk_Teams_TeamID PRIMARY KEY (TeamID);



