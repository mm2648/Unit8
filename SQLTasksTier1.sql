/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost > 0;

Answer Q1:
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*)
FROM Facilities
WHERE membercost = 0;

Answer Q2: COUNT = 4

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0 AND membercost < 0.2 * monthlymaintenance;

Answer Q3:

facid	  name	   membercost	monthlymaintenance	
0	Tennis Court 1	 5.0	          200
1	Tennis Court 2	 5.0	          200
4	Massage Room 1	 9.9	          3000
5	Massage Room 2	 9.9	          3000
6	Squash Court	 3.5	          80

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1, 5);

Answer Q4:
facid	name	  membercost	guestcost	initialoutlay	monthlymaintenance	
1	Tennis Court 2 	5.0	    25.0	       8000	             200
5	Massage Room 2 	9.9	    80.0	       4000	             3000


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, 
       CASE 
           WHEN monthlymaintenance > 100 THEN 'expensive'
           ELSE 'cheap'
       END AS label
FROM Facilities;

Answer Q5:

name	label	
Tennis Court 1	expensive
Tennis Court 2	expensive
Badminton Court	cheap
Table Tennis	cheap
Massage Room 1	expensive
Massage Room 2	expensive
Squash Court	cheap
Snooker Table	cheap
Pool Table	cheap


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members);

Answer Q6:

firstname	surname	
Darren	Smith

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT 
    CONCAT_WS(' ', Members.firstname, Members.surname) AS member_name,
    Facilities.name AS court_name
FROM 
    Members
    JOIN Bookings ON Members.memid = Bookings.memid
    JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE 
    Facilities.name LIKE '%Tennis Court%'
ORDER BY 
    member_name;
    
 Answer Q7:
List of 46 rows 


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT Facilities.name AS facility_name,
       CONCAT_WS(' ', Members.firstname, Members.surname) AS member_name,
       CASE
           WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
           ELSE Facilities.membercost * Bookings.slots
       END AS cost
FROM Bookings
JOIN Facilities ON Bookings.facid = Facilities.facid
LEFT JOIN Members ON Bookings.memid = Members.memid
WHERE DATE(Bookings.starttime) = '2012-09-14' 
AND (
    (Bookings.memid = 0 AND Facilities.guestcost * Bookings.slots > 30)
    OR (Bookings.memid != 0 AND Facilities.membercost * Bookings.slots > 30)
)
ORDER BY cost DESC;

Answer Q8:
List of 12 rows

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT facility_name, member_name, cost
FROM (
    SELECT Facilities.name AS facility_name,
           CASE
               WHEN Members.firstname = 'GUEST' AND Members.surname = 'GUEST' THEN 'Guest'
               ELSE CONCAT_WS(' ', Members.firstname, Members.surname)
           END AS member_name,
           CASE
               WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
               ELSE Facilities.membercost * Bookings.slots
           END AS cost
    FROM Bookings
    JOIN Facilities ON Bookings.facid = Facilities.facid
    LEFT JOIN Members ON Bookings.memid = Members.memid
    WHERE DATE(Bookings.starttime) = '2012-09-14' 
) AS subquery
WHERE cost > 30
ORDER BY cost DESC;

Answer Q9:
Same list of 12 rows as in Q8


/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT name AS facility_name, 
       SUM(CASE WHEN memid = 0 THEN guestcost * slots ELSE membercost * slots END) AS total_revenue
FROM Bookings
JOIN Facilities ON Bookings.facid = Facilities.facid
GROUP BY facility_name
HAVING total_revenue < 1000
ORDER BY total_revenue;

Answer Q10:
('Table Tennis', 180)
('Snooker Table', 240)
('Pool Table', 270)

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m.firstname || ' ' || m.surname AS member_name,
       (SELECT r.firstname || ' ' || r.surname FROM Members AS r WHERE r.memid = m.recommendedby) AS recommended_by
FROM Members AS m
ORDER BY m.surname, m.firstname;

Answer Q11:
List with 31 rows

/* Q12: Find the facilities with their usage by member, but not guests */

  SELECT f.name AS facility_name,
       COUNT(DISTINCT b.memid) AS member_usage
FROM Bookings AS b
JOIN Facilities AS f ON b.facid = f.facid
JOIN Members AS m ON b.memid = m.memid
WHERE m.firstname != 'GUEST' AND m.surname != 'GUEST'
GROUP BY facility_name;

Answer Q12:
2.6.0
2. Query all tasks
('Badminton Court', 24)
('Massage Room 1', 24)
('Massage Room 2', 12)
('Pool Table', 27)
('Snooker Table', 22)
('Squash Court', 24)
('Table Tennis', 25)
('Tennis Court 1', 23)
('Tennis Court 2', 21)

/* Q13: Find the facilities usage by month, but not guests */

SELECT f.name AS facility_name,
       strftime('%m', starttime) AS month,
       COUNT(*) AS usage_count
FROM Bookings AS b
JOIN Facilities AS f ON b.facid = f.facid
JOIN Members AS m ON b.memid = m.memid
WHERE m.firstname != 'GUEST' AND m.surname != 'GUEST'
GROUP BY facility_name, month;

Answer 13:
2.6.0
2. Query all tasks
('Badminton Court', '07', 51)
('Badminton Court', '08', 132)
('Badminton Court', '09', 161)
('Massage Room 1', '07', 77)
('Massage Room 1', '08', 153)
('Massage Room 1', '09', 191)
('Massage Room 2', '07', 4)
('Massage Room 2', '08', 9)
('Massage Room 2', '09', 14)
('Pool Table', '07', 103)
('Pool Table', '08', 272)
('Pool Table', '09', 408)
('Snooker Table', '07', 68)
('Snooker Table', '08', 154)
('Snooker Table', '09', 199)
('Squash Court', '07', 23)
('Squash Court', '08', 85)
('Squash Court', '09', 87)
('Table Tennis', '07', 48)
('Table Tennis', '08', 143)
('Table Tennis', '09', 194)
('Tennis Court 1', '07', 65)
('Tennis Court 1', '08', 111)
('Tennis Court 1', '09', 132)
('Tennis Court 2', '07', 41)
('Tennis Court 2', '08', 109)
('Tennis Court 2', '09', 126)

