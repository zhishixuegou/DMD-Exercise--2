/* Create a table medication_stock in your Smart Old Age Home database. The table must have the following attributes:
 1. medication_id (integer, primary key)
 2. medication_name (varchar, not null)
 3. quantity (integer, not null)
 Insert some values into the medication_stock table. 
 Practice SQL with the following:
 */

 -- Q!: List all patients name and ages 
SELECT name, age FROM patients;

 -- Q2: List all doctors specializing in 'Cardiology'
SELECT * FROM doctors WHERE specialization = 'Cardiology';
 
 -- Q3: Find all patients that are older than 80
SELECT * FROM patients WHERE age > 80;



-- Q4: List all the patients ordered by their age (youngest first)
SELECT * FROM patients ORDER BY age ASC;



-- Q5: Count the number of doctors in each specialization
SELECT specialization, COUNT(*) as doctor_count 
FROM doctors 
GROUP BY specialization;


-- Q6: List patients and their doctors' names

SELECT p.name as patient_name, p.age, d.name as doctor_name, d.specialization
FROM patients p
JOIN doctors d ON p.doctor_id = d.doctor_id;


-- Q7: Show treatments along with patient names and doctor names

SELECT t.treatment_type, t.treatment_time, 
       p.name as patient_name, 
       d.name as doctor_name,
       n.name as nurse_name
FROM treatments t
JOIN patients p ON t.patient_id = p.patient_id
JOIN doctors d ON p.doctor_id = d.doctor_id
JOIN nurses n ON t.nurse_id = n.nurse_id;

-- Q8: Count how many patients each doctor supervises

SELECT d.name as doctor_name, d.specialization, 
       COUNT(p.patient_id) as patient_count
FROM doctors d
LEFT JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.name, d.specialization
ORDER BY patient_count DESC;

-- Q9: List the average age of patients and display it as average_age

SELECT AVG(age) as average_age FROM patients;

-- Q10: Find the most common treatment type, and display only that

SELECT treatment_type, COUNT(*) as count
FROM treatments
GROUP BY treatment_type
ORDER BY count DESC
LIMIT 1;


-- Q11: List patients who are older than the average age of all patients

SELECT name, age
FROM patients
WHERE age > (SELECT AVG(age) FROM patients);

-- Q12: List all the doctors who have more than 5 patients
SELECT d.name, COUNT(p.patient_id) as patient_count
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.name
HAVING COUNT(p.patient_id) > 5;



-- Q13: List all the treatments that are provided by nurses that work in the morning shift. List patient name as well. 

SELECT t.treatment_type, t.treatment_time, 
       p.name as patient_name, 
       n.name as nurse_name, n.shift
FROM treatments t
JOIN patients p ON t.patient_id = p.patient_id
JOIN nurses n ON t.nurse_id = n.nurse_id
WHERE n.shift = 'Morning';


-- Q14: Find the latest treatment for each patient
SELECT p.name as patient_name, 
       t.treatment_type, 
       t.treatment_time,
       n.name as nurse_name
FROM patients p
JOIN treatments t ON p.patient_id = t.patient_id
JOIN nurses n ON t.nurse_id = n.nurse_id
WHERE (t.patient_id, t.treatment_time) IN (
    SELECT patient_id, MAX(treatment_time)
    FROM treatments
    GROUP BY patient_id
);


-- Q15: List all the doctors and average age of their patients
SELECT d.name as doctor_name, 
       d.specialization,
       AVG(p.age) as average_patient_age
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.name, d.specialization;


-- Q16: List the names of the doctors who supervise more than 3 patients

SELECT d.name, COUNT(p.patient_id) as patient_count
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.name
HAVING COUNT(p.patient_id) > 3;

-- Q17: List all the patients who have not received any treatments (HINT: Use NOT IN)

SELECT * FROM patients 
WHERE patient_id NOT IN (SELECT DISTINCT patient_id FROM treatments);


-- Q18: List all the medicines whose stock (quantity) is less than the average stock

SELECT medication_name, quantity
FROM medication_stock
WHERE quantity < (SELECT AVG(quantity) FROM medication_stock)
ORDER BY quantity ASC;


-- Q19: For each doctor, rank their patients by age

SELECT d.name as doctor_name,
       p.name as patient_name,
       p.age,
       RANK() OVER (PARTITION BY d.doctor_id ORDER BY p.age DESC) as age_rank
FROM doctors d
JOIN patients p ON d.doctor_id = p.doctor_id
ORDER BY d.name, age_rank;

-- Q20: For each specialization, find the doctor with the oldest patient

WITH DoctorPatientAges AS (
    SELECT d.specialization,
           d.name as doctor_name,
           MAX(p.age) as max_patient_age
    FROM doctors d
    JOIN patients p ON d.doctor_id = p.doctor_id
    GROUP BY d.specialization, d.doctor_id, d.name
),
RankedDoctors AS (
    SELECT specialization,
           doctor_name,
           max_patient_age,
           RANK() OVER (PARTITION BY specialization ORDER BY max_patient_age DESC) as rank
    FROM DoctorPatientAges
)
SELECT specialization, doctor_name, max_patient_age
FROM RankedDoctors
WHERE rank = 1;




