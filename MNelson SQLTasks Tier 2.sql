/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

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
SELECT name, membercost FROM Facilities WHERE membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(membercost) FROM Facilities WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance FROM Facilities WHERE membercost < monthlymaintenance * .2;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * FROM Facilities WHERE name LIKE '%2';

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, CASE WHEN monthlymaintenance <=100 THEN 'cheap' WHEN monthlymaintenance >100 THEN 'expensive' END AS monthly_maintenance FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname, joindate FROM Members WHERE joindate IN ( SELECT MAX(joindate) FROM Members );

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT CONCAT_WS(' ', firstname, surname) AS full_name, f.name AS tennis_court FROM Members AS m LEFT JOIN Bookings AS b ON m.memid = b.memid AND b.memid > 0 LEFT JOIN Facilities AS f ON b.facid = f.facid WHERE b.facid = 0 OR b.facid = 1 ORDER BY full_name, tennis_court;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT DISTINCT f.name AS facility_name, CONCAT_WS(' ', firstname, surname) AS full_name, CASE WHEN b.memid = 0 AND f.guestcost * b.slots > 30 THEN f.guestcost * b.slots WHEN b.memid <> 0 AND f.membercost * b.slots > 30 THEN f.membercost * b.slots END AS costs FROM Bookings AS b LEFT JOIN Facilities AS f ON b.facid = f.facid LEFT JOIN Members AS m ON b.memid = m.memid WHERE CASE WHEN b.memid = 0 AND f.guestcost * b.slots > 30 THEN f.guestcost * b.slots WHEN b.memid <> 0 AND f.membercost * b.slots > 30 THEN f.membercost * b.slots END IS NOT NULL AND starttime LIKE '2012-09-14%' ORDER BY costs DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT facility_name, full_name, costs FROM ( SELECT DISTINCT f.name AS facility_name, CONCAT_WS(' ', firstname, surname) AS full_name, CASE WHEN b.memid = 0 THEN f.guestcost * b.slots WHEN b.memid <> 0 THEN f.membercost * b.slots END AS costs FROM Bookings AS b LEFT JOIN Facilities AS f ON b.facid = f.facid LEFT JOIN Members AS m ON b.memid = m.memid WHERE starttime LIKE '2012-09-14%' ) AS subquery WHERE costs > 30 ORDER BY costs DESC;
/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
import sqlite3
from sqlite3 import Error

 
def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(sqlite3.version)
    except Error as e:
        print(e)
 
    return conn

 
def select_all_tasks(conn):
    """
    Query all rows in the tasks table
    :param conn: the Connection object
    :return:
    """
    cur = conn.cursor()
    
    query1 = """
        SELECT s.name, s.guest_bookings, s.member_bookings, s.revenue
FROM (SELECT 
      f.name AS name, 
      SUM(CASE WHEN b.memid = 0 THEN b.slots END) AS guest_bookings,
      SUM(CASE WHEN b.memid <> 0 THEN b.slots END) AS member_bookings,
      SUM(CASE WHEN b.memid = 0 THEN b.slots*f.guestcost ELSE b.slots*f.membercost END) AS revenue 
      FROM Facilities AS f 
      LEFT JOIN Bookings AS b 
      ON f.facid = b.facid
      GROUP BY f.name) AS s 
WHERE s.revenue < 1000
GROUP BY s.name
ORDER BY s.revenue DESC;
        """
    cur.execute(query1)
 
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main():
    database = "sqlite_db_pythonsqlite.db"
 
    # create a database connection
    conn = create_connection(database)
    with conn: 
        print("2. Query all tasks")
        select_all_tasks(conn)
 
 
if __name__ == '__main__':
    main()


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
import sqlite3
from sqlite3 import Error

 
def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(sqlite3.version)
    except Error as e:
        print(e)
 
    return conn

 
def select_all_tasks(conn):
    """
    Query all rows in the tasks table
    :param conn: the Connection object
    :return:
    """
    cur = conn.cursor()
    
    query1 = """
        SELECT m.surname|| ' ' ||m.firstname AS full_name, r.firstname|| ' ' ||r.surname AS recommended_by
FROM Members as m 
LEFT OUTER JOIN Members as r 
ON m.recommendedby = r.memid
WHERE m.surname <> 'GUEST'
ORDER BY full_name;
        """
    cur.execute(query1)
 
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main():
    database = "sqlite_db_pythonsqlite.db"
 
    # create a database connection
    conn = create_connection(database)
    with conn: 
        print("2. Query all tasks")
        select_all_tasks(conn)
 
 
if __name__ == '__main__':
    main()

/* Q12: Find the facilities with their usage by member, but not guests */
 
def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(sqlite3.version)
    except Error as e:
        print(e)
 
    return conn

 
def select_all_tasks(conn):
    """
    Query all rows in the tasks table
    :param conn: the Connection object
    :return:
    """
    cur = conn.cursor()
    
    query1 = """
        SELECT f.name, m.firstname|| ' ' || m.surname AS full_name, SUM(b.slots)
FROM Bookings as b 
LEFT JOIN Facilities as f 
ON b.facid = f.facid
LEFT JOIN Members as m 
ON b.memid = m.memid
WHERE b.memid <> 0
GROUP BY b.facid, b.memid;
        """
    cur.execute(query1)
 
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main():
    database = "sqlite_db_pythonsqlite.db"
 
    # create a database connection
    conn = create_connection(database)
    with conn: 
        print("2. Query all tasks")
        select_all_tasks(conn)
 
 
if __name__ == '__main__':
    main()

/* Q13: Find the facilities usage by month, but not guests */
import sqlite3
from sqlite3 import Error

 
def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        print(sqlite3.version)
    except Error as e:
        print(e)
 
    return conn

 
def select_all_tasks(conn):
    """
    Query all rows in the tasks table
    :param conn: the Connection object
    :return:
    """
    cur = conn.cursor()
    
    query1 = """
        SELECT s.name, 
        s.month, SUM(s.slot) FROM (
        SELECT f.name AS name, 
        b.slots AS slot, 
        CASE WHEN b.starttime LIKE '%-01-%' THEN '1 - January' 
        WHEN b.starttime LIKE '%-02-%' THEN '2 - February' 
        WHEN b.starttime LIKE '%-03-%' THEN '3 - March' 
        WHEN b.starttime LIKE '%-04-%' THEN '4 - April' 
        WHEN b.starttime LIKE '%-05-%' THEN '5 - May' 
        WHEN b.starttime LIKE '%-06-%' THEN '6 - June' 
        WHEN b.starttime LIKE '%-07-%' THEN '7 - July' 
        WHEN b.starttime LIKE '%-08-%' THEN '8 - August' 
        WHEN b.starttime LIKE '%-09-%' THEN '9 - September' 
        WHEN b.starttime LIKE '%-10-%' THEN '10 - October' 
        WHEN b.starttime LIKE '%-11-%' THEN '11 - November' 
        WHEN b.starttime LIKE '%-12-%' THEN '12 - December' END AS month 
        FROM Bookings AS b 
        LEFT JOIN Facilities AS f 
        ON b.facid = f.facid) AS s 
        GROUP BY s.name, s.month 
        ORDER BY s.month;

        """
    cur.execute(query1)
 
    rows = cur.fetchall()
 
    for row in rows:
        print(row)


def main():
    database = "sqlite_db_pythonsqlite.db"
 
    # create a database connection
    conn = create_connection(database)
    with conn: 
        print("2. Query all tasks")
        select_all_tasks(conn)
 
 
if __name__ == '__main__':
    main()
