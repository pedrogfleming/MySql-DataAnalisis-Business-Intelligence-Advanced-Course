USE mavenfuzzyfactory;
-- Show total activity per page
SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS pvs
FROM website_pageviews
WHERE website_pageview_id < 1000 -- arbitrary
GROUP BY pageview_url
ORDER BY pvs DESC;