/*
While we're on Gsearch,could you dive into nonbrand,and pull monthly sessions and orders split by device type?
I want to flex our analytical muscles a little and show the board we really know our traffic sources.
*/
SELECT 
	YEAR(wb_sessions.created_at) AS yr,
	MONTH(wb_sessions.created_at) AS mo,
	COUNT(CASE WHEN wb_sessions.device_type = 'mobile' THEN wb_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
	COUNT(CASE WHEN wb_sessions.device_type = 'mobile' THEN o.website_session_id ELSE NULL END) AS mobile_orders,
	COUNT(CASE WHEN wb_sessions.device_type = 'desktop' THEN wb_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
	COUNT(CASE WHEN wb_sessions.device_type = 'desktop' THEN o.website_session_id ELSE NULL END) AS desktop_orders,
	(
		COUNT(DISTINCT o.website_session_id)
		/
		COUNT(DISTINCT wb_sessions.website_session_id)
	) AS conv_rate
FROM website_sessions wb_sessions
	LEFT JOIN orders AS o 
		ON wb_sessions.website_session_id = o.website_session_id 
WHERE 
	wb_sessions.utm_source = 'gsearch' AND
	wb_sessions.utm_campaign = 'nonbrand' AND 
	wb_sessions.created_at < '2012-11-27'
GROUP BY 
	yr,
	mo
ORDER BY 
	yr ASC,
	mo ASC;