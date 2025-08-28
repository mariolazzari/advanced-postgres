CREATE TABLE
    employees (
        id INT GENERATED ALWAYS AS IDENTITY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        department TEXT NOT NULL,
        salary INT NOT NULL,
        PRIMARY KEY (id)
    );

INSERT INTO
    employees (first_name, last_name, department, salary)
VALUES
    ('Alice', 'Smith', 'Engineering', 125000),
    ('Bob', 'Baker', 'Sales', 85000);

SELECT
    *
FROM
    employees;

-- create a entry table where we audit new employees
CREATE TABLE
    new_employee_logs (
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        joining_date date NOT NULL
    );

-- Create a function
CREATE OR REPLACE FUNCTION new_employee_joining_func() RETURNS TRIGGER AS $new_employee_trigger$
   BEGIN
      INSERT INTO new_employee_logs(first_name, last_name, joining_date)
      VALUES (new.first_name, new.last_name, current_timestamp);
      RETURN NEW;
   END;
$new_employee_trigger$ LANGUAGE plpgsql;

-- create a trigger for this function (note that this is an AFTER INSERT and a row-level trigger)
CREATE TRIGGER new_employee_trigger 
AFTER INSERT ON employees
FOR EACH ROW 
    EXECUTE PROCEDURE new_employee_joining_func();

-- insert some values within employees table and notice how trigger works
INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('John', 'Watson', 'Sales', 65000);

SELECT * FROM employees;

-- new entry is added
SELECT * from new_employee_logs;

-- after udpate trigger

CREATE TABLE employee_salary_logs (
   id INT GENERATED ALWAYS AS IDENTITY,
   first_name TEXT NOT NULL,
   last_name TEXT NOT NULL,
   old_salary INT NOT NULL,
   incremented_salary INT NOT NULL,
   incremented_on DATE NOT NULL
);

-- If the salary is incremented, then let's aduit the last name and the time we incremented the salary and what the old salary and new salary is
CREATE OR REPLACE FUNCTION EMPLOYEE_SALARY_UPDATE_FUNC () RETURNS TRIGGER LANGUAGE PLPGSQL AS $$
BEGIN
  IF NEW.salary <> OLD.salary THEN
     INSERT INTO employee_salary_logs(first_name, last_name, old_salary, incremented_salary, incremented_on)
     VALUES(OLD.first_name, OLD.last_name, OLD.salary, NEW.salary, now());
  END IF;

  RETURN NEW;
END;
$$

CREATE TRIGGER EMPLOYEE_SALARY_UPDATE_TRIGGER
AFTER
UPDATE ON EMPLOYEES FOR EACH ROW
EXECUTE PROCEDURE EMPLOYEE_SALARY_UPDATE_FUNC ();

UPDATE employees
SET salary = 75000
WHERE last_name = 'Watson'; 

UPDATE EMPLOYEES
SET SALARY = 1.1 * SALARY

SELECT * FROM employee_salary_logs;

-- statement level trigger

-- table which tracks operations performed on other tables
CREATE TABLE table_changed_logs (
  change_type TEXT NOT NULL,  
  changed_table_name TEXT NOT NULL, 
  changed_on date NOT NULL
);

-- Function to track what changes were made to a table (INSERT, UPDATE, DELETE)
CREATE OR REPLACE FUNCTION table_changed_logs_func() RETURNS TRIGGER AS $table_changed_trigger$
   BEGIN
      INSERT INTO table_changed_logs(change_type, changed_table_name, changed_on)
      VALUES (TG_OP, TG_TABLE_NAME, current_timestamp);
      RETURN NEW;
   END;
$table_changed_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER employees_inserted_trigger
AFTER INSERT ON employees
EXECUTE PROCEDURE table_changed_logs_func();

CREATE TRIGGER employees_inserted_trigger
AFTER UPDATE ON employees
EXECUTE PROCEDURE table_changed_logs_func();

INSERT INTO employees (first_name, last_name, department, salary)
VALUES ('Julia', 'Dennis', 'Engineering', 80000);

SELECT * FROM table_changed_logs;
SELECT * FROM employee_salary_logs;

-- We can see the trigger using the following query (should be 4 triggers)
SELECT tgname FROM pg_trigger;
-- Drop triggers
DROP TRIGGER employees_inserted_trigger ON employees;

