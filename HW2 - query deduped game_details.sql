
INSERT INTO fact_game_details
WITH deduped AS (
    SELECT
        g.game_date_est,
        g.season,
        g.home_team_id,
        gd.*,
        ROW_NUMBER() OVER (PARTITION BY gd.game_id, team_id, player_id ORDER BY g.game_date_est) AS row_num
    FROM game_details gd
    JOIN games g ON gd.game_id = g.game_id
)
SELECT
    game_date_est AS dim_game_date,
    season AS dim_season,
    team_id AS dim_team_id,
      player_id AS dim_player_id,
    player_name As di_player_name,
    start_position AS dim_start_position,
    team_id = home_team_id AS dim_is_playing_at_home,
    COALESCE(POSITION('DNP' in comment), 0) > 0 AS dim_did_not_play,
    COALESCE(POSITION('DND' in comment), 0) > 0 AS dim_did_not_dress,
    COALESCE(POSITION('NWT' in comment), 0) > 0 AS dim_not_with_team,
    CAST(SPLIT_PART(min, ':', 1) AS REAL)
     + CAST(SPLIT_PART(min, ':', 2) AS REAL)/60 AS m_minutes,
    fgm AS m_fgm,
    fga AS m_fga,
    fg3m AS m_fg3m,
    fg3a AS m_fg3a,
    ftm AS m_ftm,
    fta AS m_fta,
    oreb AS m_oreb,
    dreb AS m_dreb,
    reb AS m_reb,
    ast AS m_ast,
    stl AS m_stl,
    blk AS m_stl,
    "TO" AS m_turnovers,
    pf AS m_pf,
    pts AS m_pts,
    plus_minus AS m_plus_minus
    FROM deduped
WHERE row_num = 1;


CREATE TABLE fact_game_details (
    dim_game_date DATE,
    dim_season INT,
    dim_team_id INT,
    dim_player_id INT,
    dim_player_name TEXT,
    dim_start_position TEXT,
    dim_is_playing_at_home BOOLEAN,
    dim_did_not_play BOOLEAN,
    dim_did_not_dress BOOLEAN,
    dim_not_with_team BOOLEAN,
    m_minutes REAL,
    m_fgm INT,
    m_fga INT,
    m_fg3m INT,
    m_fg3a INT,
    m_ftm INT,
    m_fta INT,
    m_oreb INT,
    m_dreb INT,
    m_reb INT,
    m_ast INT,
    m_stl INT,
    m_blk INT,
    m_turnovers INT,
    m_pf INT,
    m_pts INT,
    m_plus_minus INT,
    PRIMARY KEY (dim_game_date, dim_team_id, dim_player_id)
);


SELECT t.*, fgd.*
FROM fact_game_details fgd JOIN teams t
ON t.team_id = fgd.dim_team_id;