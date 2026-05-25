-- ============================================================
--   CLINIC MANAGEMENT SYSTEM - Project 3
--   Database Design & Implementation (MySQL)
-- ============================================================

DROP DATABASE IF EXISTS clinic_management;
CREATE DATABASE clinic_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clinic_management;

-- ============================================================
--  1. DDL – CREATE TABLES
-- ============================================================

-- Department
CREATE TABLE Department (
    dept_id     INT          AUTO_INCREMENT PRIMARY KEY,
    dept_name   VARCHAR(100) NOT NULL UNIQUE
);

-- Clinic
CREATE TABLE Clinic (
    clinic_id   INT          AUTO_INCREMENT PRIMARY KEY,
    clinic_name VARCHAR(100) NOT NULL,
    address     VARCHAR(255) NOT NULL,
    dept_id     INT          NOT NULL,
    CONSTRAINT fk_clinic_dept FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Doctor
CREATE TABLE Doctor (
    doctor_id   INT          AUTO_INCREMENT PRIMARY KEY,
    doctor_name VARCHAR(100) NOT NULL,
    phone       VARCHAR(20),
    address     VARCHAR(255),
    dept_id     INT          NOT NULL,
    CONSTRAINT fk_doctor_dept FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Patient
CREATE TABLE Patient (
    patient_id  INT          AUTO_INCREMENT PRIMARY KEY,
    pat_name    VARCHAR(100) NOT NULL,
    phone       VARCHAR(20),
    address     VARCHAR(255),
    birth_date  DATE,
    job         VARCHAR(100)
);

-- Appointment
CREATE TABLE Appointment (
    appt_id     INT          AUTO_INCREMENT PRIMARY KEY,
    appt_date   DATE         NOT NULL,
    patient_id  INT          NOT NULL,
    doctor_id   INT          NOT NULL,
    start_time  TIME         NOT NULL,
    end_time    TIME         NOT NULL,
    cost        DECIMAL(10,2) NOT NULL DEFAULT 0,
    status      ENUM('scheduled','in progress','postponed') NOT NULL DEFAULT 'scheduled',
    diagnosis   TEXT,
    CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_appt_doctor  FOREIGN KEY (doctor_id)  REFERENCES Doctor(doctor_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_time CHECK (end_time > start_time)
);

-- ============================================================
--  2. VIEWS
-- ============================================================

-- View: appointment details (joins all entities)
CREATE OR REPLACE VIEW vw_appointment_details AS
SELECT
    a.appt_id,
    a.appt_date,
    a.start_time,
    a.end_time,
    a.status,
    a.cost,
    a.diagnosis,
    p.patient_id,
    p.pat_name      AS patient_name,
    d.doctor_id,
    d.doctor_name,
    dep.dept_name,
    c.clinic_name
FROM Appointment  a
JOIN Patient      p   ON p.patient_id = a.patient_id
JOIN Doctor       d   ON d.doctor_id  = a.doctor_id
JOIN Department   dep ON dep.dept_id  = d.dept_id
LEFT JOIN Clinic  c   ON c.dept_id    = d.dept_id;

-- View: total revenue per patient
CREATE OR REPLACE VIEW vw_patient_revenue AS
SELECT
    p.patient_id,
    p.pat_name,
    SUM(a.cost)   AS total_paid,
    COUNT(a.appt_id) AS total_appointments
FROM Patient p
JOIN Appointment a ON a.patient_id = p.patient_id
GROUP BY p.patient_id, p.pat_name;

-- ============================================================
--  3. DML – INSERT TEST DATA (≥ 10 records per table)
-- ============================================================

-- Departments (10)
INSERT INTO Department (dept_name) VALUES
('Cardiology'),
('Neurology'),
('Orthopedics'),
('Gastroenterology'),
('Dermatology'),
('Oncology'),
('Endocrinology'),
('Pulmonology'),
('Ophthalmology'),
('Urology');

-- Clinics (10 – two per first five departments)
INSERT INTO Clinic (clinic_name, address, dept_id) VALUES
('Heart Care Clinic A',       '12 Nile St, Cairo',        1),
('Heart Care Clinic B',       '45 Tahrir Sq, Giza',       1),
('Brain & Spine Clinic',      '7 Ramses Ave, Cairo',      2),
('Neuro Rehab Center',        '3 Dokki St, Giza',         2),
('Bone & Joint Clinic',       '22 Heliopolis, Cairo',     3),
('Sports Medicine Clinic',    '9 Nasr City, Cairo',       3),
('Digestive Health Clinic',   '15 Mohandeseen, Giza',     4),
('GI Endoscopy Center',       '1 Zamalek, Cairo',         4),
('Skin Care Clinic',          '30 Maadi, Cairo',          5),
('Laser Dermatology Center',  '8 6th October, Giza',      5);

-- Doctors (10)
INSERT INTO Doctor (doctor_name, phone, address, dept_id) VALUES
('Dr. Ahmed Hassan',    '01001234567', '10 Corniche, Cairo',       1),
('Dr. Sara Mahmoud',    '01112345678', '5 Nasr City, Cairo',       1),
('Dr. Khalid Youssef',  '01223456789', '3 Mohandeseen, Giza',      2),
('Dr. Nadia Farouk',    '01334567890', '20 Dokki, Giza',           2),
('Dr. Omar Salah',      '01445678901', '15 Heliopolis, Cairo',     3),
('Dr. Mona Gamal',      '01556789012', '7 Zamalek, Cairo',         4),
('Dr. Tarek Ibrahim',   '01667890123', '9 Maadi, Cairo',           4),
('Dr. Hana Ali',        '01778901234', '12 Sheraton, Cairo',       5),
('Dr. Yasser Fathy',    '01889012345', '4 Agouza, Giza',           6),
('Dr. Reem Adel',       '01990123456', '11 Imbaba, Giza',          7);

-- Patients (10)
INSERT INTO Patient (pat_name, phone, address, birth_date, job) VALUES
('Mohamed Adel',    '01011111111', '1 Tahrir, Cairo',      '1985-03-12', 'Engineer'),
('Layla Hassan',    '01022222222', '8 Dokki, Giza',        '1990-07-25', 'Teacher'),
('Karim Nasser',    '01033333333', '5 Nasr City, Cairo',   '1978-11-04', 'Doctor'),
('Dina Samir',      '01044444444', '3 Maadi, Cairo',       '2000-01-30', 'Student'),
('Tamer Fouad',     '01055555555', '14 Heliopolis, Cairo', '1965-06-18', 'Lawyer'),
('Rana Mostafa',    '01066666666', '6 6th October, Giza',  '1995-09-09', 'Pharmacist'),
('Sherif Zaki',     '01077777777', '2 Mohandeseen, Giza',  '1970-02-14', 'Businessman'),
('Nour Emad',       '01088888888', '19 Zamalek, Cairo',    '1988-12-22', 'Nurse'),
('Amira Lotfy',     '01099999999', '7 Agouza, Giza',       '2005-04-05', 'Student'),
('Hossam Ragab',    '01012345678', '9 Helwan, Cairo',      '1980-08-17', 'Accountant'),
-- patient with specific ID 12527 for the sample query
('Test Patient',    '01099000000', '99 Sample St, Cairo',  '1975-01-01', 'Retired');

-- set patient 11 to ID 12527 — easier: just insert with a known id
-- We'll reference patient_id via natural sequence; queries use WHERE patient_id = 12527
-- so let's force that id:
INSERT INTO Patient (patient_id, pat_name, phone, address, birth_date, job) VALUES
(12527, 'Walid Fahmy', '01056781234', '3 Pyramids Rd, Giza', '1968-05-20', 'Pilot');

-- Appointments (12)
INSERT INTO Appointment (appt_date, patient_id, doctor_id, start_time, end_time, cost, status, diagnosis) VALUES
-- 2022 appointments
('2022-04-10', 1,     1, '09:00', '09:30', 300.00, 'scheduled',    'Hypertension follow-up'),
('2022-08-15', 12527, 2, '10:00', '10:45', 400.00, 'scheduled',    'Arrhythmia monitoring'),
-- 2023 appointments
('2023-01-20', 2,     3, '11:00', '11:30', 250.00, 'scheduled',    'Migraine assessment'),
('2023-03-05', 3,     5, '08:30', '09:00', 350.00, 'in progress',  'Knee pain'),
('2023-06-18', 4,     6, '13:00', '13:30', 200.00, 'scheduled',    'Fatty liver'),
('2023-07-22', 5,     1, '09:30', '10:00', 300.00, 'postponed',    'Cardiac stress test'),
('2023-09-14', 6,     8, '14:00', '14:30', 150.00, 'scheduled',    'Eczema treatment'),
('2023-11-30', 12527, 2, '08:00', '08:45', 400.00, 'scheduled',    'Coronary artery disease'),
-- 2024 appointments
('2024-02-10', 7,     4, '10:00', '10:30', 275.00, 'scheduled',    'Epilepsy check'),
('2024-04-25', 8,     7, '12:00', '12:30', 220.00, 'in progress',  'GERD'),
('2024-08-03', 9,     8, '15:00', '15:30', 180.00, 'scheduled',    'Acne treatment'),
('2024-10-17', 12527, 1, '09:00', '09:45', 500.00, 'scheduled',    'Heart failure monitoring'),
-- additional records
('2023-05-12', 10,    9, '11:30', '12:00', 190.00, 'scheduled',    'Fatty liver'),
('2022-12-01', 12527, 5, '10:00', '10:30', 350.00, 'scheduled',    'Back pain');

-- ============================================================
--  4. SAMPLE QUERIES
-- ============================================================

-- Q1: List the name of patients diagnosed with fatty liver in the last year
-- (adjust CURDATE() – based on system date at runtime)
SELECT DISTINCT p.pat_name
FROM Patient     p
JOIN Appointment a ON a.patient_id = p.patient_id
WHERE a.diagnosis LIKE '%fatty liver%'
  AND a.appt_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- Q2: List the addresses of cardiology clinics
SELECT c.clinic_name, c.address
FROM Clinic     c
JOIN Department d ON d.dept_id = c.dept_id
WHERE d.dept_name = 'Cardiology';

-- Q3: List the total money paid by patient whose ID is 12527 in the last 3 years
SELECT
    p.pat_name,
    SUM(a.cost) AS total_paid
FROM Patient     p
JOIN Appointment a ON a.patient_id = p.patient_id
WHERE p.patient_id = 12527
  AND a.appt_date >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
GROUP BY p.pat_name;

-- Q4: Count of appointments per department
SELECT
    d.dept_name,
    COUNT(a.appt_id) AS appointment_count
FROM Department  d
JOIN Doctor      doc ON doc.dept_id   = d.dept_id
JOIN Appointment a   ON a.doctor_id   = doc.doctor_id
GROUP BY d.dept_name
ORDER BY appointment_count DESC;

-- Q5: List doctors and their departments with number of patients they treated
SELECT
    doc.doctor_name,
    dep.dept_name,
    COUNT(DISTINCT a.patient_id) AS patients_treated
FROM Doctor      doc
JOIN Department  dep ON dep.dept_id  = doc.dept_id
LEFT JOIN Appointment a ON a.doctor_id = doc.doctor_id
GROUP BY doc.doctor_id, doc.doctor_name, dep.dept_name
ORDER BY patients_treated DESC;

-- Q6: List all postponed appointments with patient and doctor info
SELECT
    a.appt_id,
    a.appt_date,
    p.pat_name,
    doc.doctor_name,
    a.diagnosis
FROM Appointment a
JOIN Patient     p   ON p.patient_id = a.patient_id
JOIN Doctor      doc ON doc.doctor_id = a.doctor_id
WHERE a.status = 'postponed';

-- Q7: Most common diagnosis
SELECT
    diagnosis,
    COUNT(*) AS frequency
FROM Appointment
WHERE diagnosis IS NOT NULL
GROUP BY diagnosis
ORDER BY frequency DESC
LIMIT 5;

-- ============================================================
-- End of script
-- ============================================================