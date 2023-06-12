   SELECT a.student_id,
          a.initiating_user_desc,
          a.hold_desc,
          EXTRACT(DAY from AGE(c.registration_start_date, a.start_date)) AS days_before_registration,
          a.hold_code,
          a.hold_reason,
          a.amount_owed,
          a.is_registration_hold,
          a.start_date AS hold_start_date,
          b.term_desc AS hold_start_term,
          c.term_desc AS next_term,
          c.registration_start_date AS next_term_registration_start_date
     FROM export.student_hold a
LEFT JOIN export.term b
       ON a.start_date BETWEEN b.term_start_date AND b.term_end_date
LEFT JOIN export.term c
       ON c.term_id = b.next_term_id
    WHERE a.is_registration_hold IS TRUE
      AND b.term_id = '202140'

-- Just want to pull CS codes.
