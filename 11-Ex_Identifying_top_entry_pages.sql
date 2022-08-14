USE mavenfuzzyfactory;
DESC website_sessions;
DESC website_pageviews;
DESC orders;
SELECT * FROM website_sessions;
SELECT * FROM website_pageviews;
SELECT * FROM orders;
CREATE TEMPORARY TABLE top_entry_pages
SELECT 
    pageview_url,
    COUNT(DISTINCT website_session_id) AS total_views
FROM
    website_pageviews
WHERE
    created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY total_views DESC;

SELECT * FROM top_entry_pages;

