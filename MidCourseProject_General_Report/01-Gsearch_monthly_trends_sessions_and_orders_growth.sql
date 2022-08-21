/*
Gsearch seems to be the biggest driver of our business.
Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?
*/
USE mavenfuzzyfactory;
SELECT * FROM website_sessions AS ws ;
SELECT * FROM website_pageviews AS wp ;
SELECT * FROM orders AS o ;

DESC website_sessions;

SELECT 
	YEAR(wb_sessions.created_at) AS yr,
	MONTH(wb_sessions.created_at) AS mo,
	COUNT(DISTINCT wb_sessions.website_session_id) AS sessions,
	COUNT(DISTINCT o.website_session_id) AS total_orders,
	(
		COUNT(DISTINCT o.website_session_id)
		/
		COUNT(DISTINCT wb_sessions.website_session_id)
	) AS conv_rate
FROM website_sessions wb_sessions
	LEFT JOIN orders AS o 
		ON wb_sessions .website_session_id = o.website_session_id 
WHERE 
	wb_sessions.utm_source = 'gsearch' AND
	wb_sessions.created_at < '2012-11-27'
GROUP BY 
	yr,
	mo
ORDER BY 
	yr ASC,
	mo ASC;


