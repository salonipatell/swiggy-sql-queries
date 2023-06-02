--1 FIND CUSTOMERS WHO HAVE NEVER OREDERED?
>SELECT users.user_id, users.name
FROM users
WHERE users.user_id NOT IN (
  SELECT user_id
  FROM orders
  GROUP BY user_id
);


--2 FIND AVERAGE PRICE OF PER DISH?
>SELECT f.f_name, AVG(m.price) AS avgprice
FROM menu m
JOIN food f
ON m.f_id = f.f_id
GROUP BY m.f_id;  


--3 FIND TOP RESTAURANT IN TERM OF NUMBER OF ORDERS FOR A GIVEN MONTH 
>SELECT c.month, c.r_id, COUNT(r_id) AS total
FROM (
  SELECT b.month, b.r_id
  FROM (
    SELECT *, MONTHNAME(date) AS month
    FROM orders
  ) b
  WHERE b.month = 'June'
) c
GROUP BY c.r_id
ORDER BY total DESC
LIMIT 1;

--4 restaurants with monthly sales >x 
> SELECT r.r_name, SUM(o.amount) AS 'revenue'
FROM orders o
JOIN restaurants r ON o.r_id = r.r_id
WHERE MONTHNAME(o.date) LIKE 'June'
GROUP BY r.r_name
HAVING revenue > 500;


--5 SHOW ALL ORDERS WITH ORDER DETAILS FOR A PARTICULAR CUSTOMER IN A PARTICULAR DATE RANGE
SELECT o.order_id, r.r_name, f.f_name
FROM orders o
JOIN restaurants r ON o.r_id = r.r_id
JOIN order_details od ON o.order_id = od.order_id
JOIN food f ON f.f_id = od.f_id
WHERE o.user_id = (
  SELECT user_id
  FROM users
  WHERE name LIKE 'Ankit'
)
AND DATE BETWEEN '2022-06-10' AND '2022-07-10';

--6 FIND RESTAURANTS WITH MAX REPEATED CUSTOMERS
SELECT SUM(a.visits) AS "visits", a.r_name
FROM (
  SELECT o.user_id, r.r_name, COUNT(user_id) AS "visits"
  FROM orders o
  JOIN restaurants r ON o.r_id = r.r_id
  GROUP BY r.r_name, o.user_id
  HAVING COUNT(user_id) > 1
  ORDER BY COUNT(user_id) DESC
) a
GROUP BY a.r_name
ORDER BY visits DESC
LIMIT 1;


--7 MONTH OVER MONTH REVENUE GROWTH OF SWIGGY
SELECT c.month, ((c.revenue - c.previousrevenue) / c.previousrevenue) * 100 AS "overmonth"
FROM (
  SELECT a.revenue, a.month, LAG(a.revenue, 1) OVER (ORDER BY a.month DESC) AS "previousrevenue"
  FROM (
    SELECT MONTHNAME(date) AS month, SUM(amount) AS 'revenue'
    FROM orders
    GROUP BY month
    ORDER BY month DESC
  ) a
  GROUP BY a.month
) c
ORDER BY c.month DESC;




--8 CUSTOMER AND THEIR FAVOURITE FOOD
SELECT u.name, g.f_name, g.user_id
FROM (
  SELECT e.user_id, f.f_name, e.frequency
  FROM (
    SELECT d.user_id, d.f_id, d.frequency
    FROM (
      SELECT c.user_id, c.f_id, c.rank, c.frequency
      FROM (
        SELECT a.user_id, a.f_id, a.frequency, DENSE_RANK() OVER (PARTITION BY a.user_id ORDER BY a.frequency DESC) AS 'rank'
        FROM (
          SELECT o.user_id, od.f_id, COUNT(*) AS "frequency"
          FROM orders o
          JOIN order_details od ON od.order_id = o.order_id
          GROUP BY o.user_id, od.f_id
        ) a
      ) c
      WHERE c.rank = 1
      ORDER BY c.frequency DESC
    ) d
  ) e
  JOIN food f ON e.f_id = f.f_id
) g
JOIN users u ON g.user_id = u.user_id;


