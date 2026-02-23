WITH incentive_rows AS (
    SELECT 
        w.collector_code,
        CASE
            WHEN w.outstanding_balance < 50000 THEN 'Group 1'
            WHEN w.outstanding_balance >= 50000 AND j.judge_type IN (1,2) THEN 'Group 3'
            WHEN w.outstanding_balance >= 50000 
                 AND (j.judge_type NOT IN (1,2) OR j.judge_type IS NULL) THEN 'Group 2'
        END AS "Group",
        CASE
            WHEN w.auto_type_name = 'Motorcycle'
                 AND w.age_of_write_off <= 1
                 AND w.outstanding_balance < 10000 THEN 1500
            WHEN w.auto_type_name = 'Motorcycle'
                 AND w.age_of_write_off <= 1
                 AND w.outstanding_balance >= 10000
                 AND w.outstanding_balance < 30000 THEN 2000
            WHEN w.auto_type_name = 'Motorcycle'
                 AND w.age_of_write_off <= 1
                 AND w.outstanding_balance >= 30000 THEN 2500
            WHEN w.auto_type_name = 'Motorcycle'
                 AND w.age_of_write_off > 1
                 AND w.age_of_write_off <= 3
                 AND w.outstanding_balance < 10000 THEN 2000
            WHEN w.auto_type_name = 'Motorcycle'
                 AND w.age_of_write_off > 1
                 AND w.age_of_write_off <= 3
                 AND w.outstanding_balance >= 10000
                 AND w.outstanding_balance < 30000 THEN 2500
            WHEN w.auto_type_name = 'Motorcycle'
                 AND w.age_of_write_off > 1
                 AND w.age_of_write_off <= 3
                 AND w.outstanding_balance >= 30000 THEN 3000
            WHEN w.auto_type_name = 'Non Motorcycle'
                 AND w.age_of_write_off <= 1
                 AND w.outstanding_balance < 100000 THEN 2500
            WHEN w.auto_type_name = 'Non Motorcycle'
                 AND w.age_of_write_off <= 1
                 AND w.outstanding_balance >= 100000
                 AND w.outstanding_balance < 300000 THEN 3100
            WHEN w.auto_type_name = 'Non Motorcycle'
                 AND w.age_of_write_off <= 1
                 AND w.outstanding_balance >= 300000 THEN 3600
            WHEN w.auto_type_name = 'Non Motorcycle'
                 AND w.age_of_write_off > 1
                 AND w.age_of_write_off <= 3
                 AND w.outstanding_balance < 100000 THEN 3000
            WHEN w.auto_type_name = 'Non Motorcycle'
                 AND w.age_of_write_off > 1
                 AND w.age_of_write_off <= 3
                 AND w.outstanding_balance >= 100000
                 AND w.outstanding_balance < 300000 THEN 3600
            WHEN w.auto_type_name = 'Non Motorcycle'
                 AND w.age_of_write_off > 1
                 AND w.age_of_write_off <= 3
                 AND w.outstanding_balance >= 300000 THEN 4100
            ELSE 0
        END AS incentive
    FROM tb_data_wo w
    LEFT JOIN tb_data_judetype j
        ON j.agreement_no = w.agreement_no
    WHERE w.repo_status = 'W'
      AND NOT EXISTS (
          SELECT 1
          FROM tb_car_case c
          WHERE c.agreement_no = w.agreement_no
            AND c.car_case_desc IN ('รถเคลมประกัน', 'รถติดคดี', 'รถที่เป็นซาก')
      )
),
sum_by_collector AS (
    SELECT "Group", collector_code, SUM(incentive) AS incentive
    FROM incentive_rows
    GROUP BY "Group", collector_code
),
ranked AS (
    SELECT
        "Group",
        collector_code,
        incentive,
        RANK() OVER (PARTITION BY "Group" ORDER BY incentive DESC) AS rnk
    FROM sum_by_collector
)
SELECT "Group", collector_code, incentive
FROM ranked
WHERE rnk = 1
ORDER BY "Group";