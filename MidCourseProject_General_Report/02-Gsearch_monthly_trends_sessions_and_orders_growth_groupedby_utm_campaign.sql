/*
2. Next,it would be great to see a similar monthly trend for Gsearch,
but this time splitting out nonbrand and brand campaigns separately.
I am wondering if brand is picking up at all.
If so,this isagood story to tell.
*/

-- Brand sessions are people who search for your business explicitly in a search engine
 

SELECT 
	YEAR(wb_sessions.created_at) AS yr,
	MONTH(wb_sessions.created_at) AS mo,
	COUNT(CASE WHEN wb_sessions.utm_campaign = 'brand' THEN wb_sessions.website_session_id ELSE NULL END) AS brand_sessions,
	COUNT(CASE WHEN wb_sessions.utm_campaign = 'brand' THEN o.order_id  ELSE NULL END) AS brand_orders,
	COUNT(CASE WHEN wb_sessions.utm_campaign = 'nonbrand' THEN wb_sessions.website_session_id ELSE NULL END) AS nonbrand_sessions,
	COUNT(CASE WHEN wb_sessions.utm_campaign = 'nonbrand' THEN o.order_id  ELSE NULL END) AS nonbrand_orders,
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