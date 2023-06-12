  WITH cohort AS
           (
               /*
                Our base cohort consists of all students who were enrolled as a degree seeking student as of census after
                fall 2017 and who are not enrolled in fall 2023 semester.
                */
               SELECT DISTINCT a.student_id
                 FROM export.student_term_outcome a
                WHERE a.term_id::int >= 201740
                  AND a.is_enrolled_census IS TRUE
                  AND a.is_degree_seeking
                  AND a.student_id NOT IN (SELECT a1.student_id
                                             FROM student_term_level a1
                                            WHERE a1.term_id = '202340'
                                              AND a1.is_enrolled IS TRUE
                )
           ),
       holds AS
           (
               /*
                We included cashiers holds (hold_code = CS) only.
                */
               SELECT a.student_id,
                      a.hold_desc,
                      a.hold_code,
                      a.hold_reason,
                      a.is_registration_hold,
                      b.term_id,
                      TRUE AS has_hold
                 FROM export.student_hold a
                          LEFT JOIN export.term b
                                    ON a.start_date BETWEEN b.term_start_date AND b.term_end_date
                WHERE a.is_registration_hold IS TRUE
                  AND a.hold_code = 'CS'
                  AND b.term_id::int >= 201740
           )
SELECT a.student_id,
       c.first_name,
       c.last_name,
       c.birth_date,
       c.primary_phone_number,
       c.cell_phone_number,
       c.campus_phone_number,
       c.local_address_city,
       c.local_address_line_1,
       c.local_address_line_2,
       c.local_address_line_3,
       c.local_address_state_code,
       c.local_address_zip_code,
       c.first_admit_county_code,
       c.first_admit_state_code,
       c.first_admitted_term_desc,
       c.gender_code,
       d.overall_gpa,
       d.overall_cumulative_credits_earned AS cumulative_credits,
       d.primary_major_desc                AS last_major,
       d.latest_registered_term_id         AS last_term_attended,
       COALESCE(e.has_hold, FALSE) AS has_hold,
       e.hold_code,
       e.hold_desc,
       e.hold_reason
  FROM cohort a
           LEFT JOIN export.student_term_outcome b
                     ON a.student_id = b.student_id
           LEFT JOIN export.student c
                     ON c.student_id = a.student_id
           LEFT JOIN export.student_term_level d
                     ON d.student_id = a.student_id
                         AND d.term_id = d.latest_registered_term_id
                         AND d.is_primary_level IS TRUE
           LEFT JOIN holds e
                     ON e.student_id = a.student_id
                         AND e.term_id = d.latest_registered_term_id
 WHERE (b.is_dropped_out IS TRUE OR b.is_stopped_out IS TRUE)
   AND b.term_id = '202320'
