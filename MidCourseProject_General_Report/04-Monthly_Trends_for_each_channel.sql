/*
I´m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch
Can you pull monthly trends for Gsearch,
alongside monthly trends for each of our other channels?
*/

-- when utm_source=null,nonbrand=null,http_refer=null then is direct typing traffic 
-- utm_source=null,nonbrand=null,http_refer="url" then is organic traffic 
USE mavenfuzzyfactory;
SELECT DISTINCT 
	utm_source ,
	utm_campaign,
	http_referer  
FROM website_sessions AS ws 
WHERE ws.created_at < '2012-11-27';

SELECT 
	YEAR(wb_sessions.created_at) AS yr,
	MONTH(wb_sessions.created_at) AS mo,
	COUNT(CASE WHEN wb_sessions.utm_source = 'gsearch' THEN wb_sessions.website_session_id ELSE NULL END) AS gsearch_paid_sessions,
	COUNT(CASE WHEN wb_sessions.utm_source = 'bsearch' THEN wb_sessions.website_session_id ELSE NULL END) AS bsearch_bsearch_sessions,
	COUNT(CASE WHEN wb_sessions.utm_source IS NULL AND http_referer IS NOT NULL THEN wb_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
	COUNT(CASE WHEN wb_sessions.utm_source IS NULL AND http_referer IS NULL THEN wb_sessions.website_session_id ELSE NULL END) AS direct_type_in_sessions,
	(
		COUNT(DISTINCT o.website_session_id)
		/
		COUNT(DISTINCT wb_sessions.website_session_id)
	) AS conv_rate
FROM website_sessions wb_sessions
	LEFT JOIN orders AS o 
		ON wb_sessions .website_session_id = o.website_session_id 
WHERE 
	wb_sessions.created_at < '2012-11-27'
GROUP BY 
	yr,
	mo
ORDER BY 
	yr ASC,
	mo ASC;