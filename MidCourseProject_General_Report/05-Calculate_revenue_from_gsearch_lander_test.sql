/*
For the gsearch lander test, please estimate the revenue that test earned us
(Hint: Look at the increase in CVR from the test (Jun 19 - Jul 28),
and use nonbrand sessions and revenue since then to calculate incremental value)
*/

USE mavenfuzzyfactory;

-- We search for the minimun page id when the test started in /lander-1
DROP TABLE IF EXISTS min_page_id_test_lander1;
CREATE TEMPORARY TABLE min_page_id_test_lander1
SELECT
	MIN(wp.website_pageview_id) AS first_test_pv
FROM website_pageviews AS wp 
WHERE pageview_url = '/lander-1';
-- It is 23504

-- Then we limit the date range only when the test was running
DROP TABLE IF EXISTS  first_test_pageviews;
CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
	wp.website_session_id ,
	MIN(wp.website_pageview_id) AS min_pageview_id
FROM website_pageviews AS wp 
	INNER JOIN website_sessions AS ws 
		ON ws.website_session_id = wp.website_session_id 
		AND ws.created_at < '2012-07-28' -- prescribed BY ASSIGNMENT 
		AND wp.website_pageview_id >= (SELECT first_test_pv FROM min_page_id_test_lander1)
		AND ws.utm_source = 'gsearch'
		AND ws.utm_campaign = 'nonbrand'
GROUP BY 
		wp.website_session_id ;
	
-- next, we´ll bring int the landing page to each session, like last time, but restricting to home or lander-1 this time
	
DROP TABLE IF EXISTS nonbrand_test_sessions_w_landing_pages;
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_pages
SELECT
	first_test_pageviews.website_session_id,
	wp.pageview_url AS landing_page
FROM first_test_pageviews 
	LEFT JOIN website_pageviews AS wp 
		ON wp.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE wp.pageview_url IN ('/home','/lander-1');

-- then we make a table to bring in orders associated with the sessions so be can have the base to perform the performance analysis
DROP TABLE IF EXISTS nonbrand_test_sessions_w_orders;
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_orders
SELECT
	nonbrand_test_sessions_w_landing_pages.website_session_id,
	nonbrand_test_sessions_w_landing_pages.landing_page,
	o.order_id AS order_id
FROM nonbrand_test_sessions_w_landing_pages
	LEFT JOIN orders AS o 
		ON o.website_session_id = nonbrand_test_sessions_w_landing_pages.website_session_id;

	
-- We perform the conversion rate from sessions to orders
DROP TABLE IF EXISTS conversion_rate_from_sessions_to_orders;
CREATE TEMPORARY TABLE conversion_rate_from_sessions_to_orders
SELECT 
	landing_page,
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT order_id) AS orders,
	(
		COUNT(DISTINCT order_id)
		/
		COUNT(DISTINCT website_session_id)
	) AS conversion_rate
FROM nonbrand_test_sessions_w_orders 
GROUP BY 1;

-- 0.0319 for /home 
-- 0.0406 fir /lander-1
-- 0.0087 additional orders per session

-- finding the most recent pageview for gsearch nonbrand where the traffic was sent to /home 
DROP TABLE IF EXISTS most_recent_gsearch_nonbrand_home_pageview;
CREATE TEMPORARY TABLE most_recent_gsearch_nonbrand_home_pageview
SELECT 
	MAX(ws.website_session_id) AS max_session
FROM website_sessions AS ws 
	LEFT JOIN website_pageviews AS wp 
		ON wp.website_session_id = ws.website_session_id 
WHERE
	ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
	AND wp.pageview_url = '/home'
	AND ws.created_at < '2012-11-27';
	
-- max website_session_id  = 17145
-- since then, all of the traffic was re routed elsewhere

SELECT 
	COUNT(ws.website_session_id) AS sessions_since_test
FROM website_sessions AS ws 
WHERE ws.created_at < '2012-11-27'
	AND ws.website_session_id > (SELECT max_session FROM most_recent_gsearch_nonbrand_home_pageview) -- LAST /home session 
	AND ws.utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand';

-- 22972 website_sessions since the test 

-- x .0087 incremental conversion = 202 incremental orders since 07/29
-- roughly 4 months, so roughly 50 extra orders per month. Not bad!