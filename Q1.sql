SELECT 
    w.agreement_no,
    w.outstanding_balance,
    j.judge_type,
    CASE
        WHEN w.outstanding_balance < 50000 THEN 'Group 1'
        WHEN w.outstanding_balance >= 50000 
             AND j.judge_type IN (1,2) THEN 'Group 3'
        WHEN w.outstanding_balance >= 50000 
             AND (j.judge_type NOT IN (1,2) OR j.judge_type IS NULL) THEN 'Group 2'
    END AS "Group",
    w.age_of_write_off AS age_of_wo,
    w.auto_type_name
FROM tb_data_wo w
LEFT JOIN tb_data_judetype j
    ON j.agreement_no = w.agreement_no
WHERE NOT EXISTS (
    SELECT 1
    FROM tb_car_case c
    WHERE c.agreement_no = w.agreement_no
      AND c.car_case_desc IN ('รถเคลมประกัน', 'รถติดคดี', 'รถที่เป็นซาก')
)
ORDER BY w.agreement_no;