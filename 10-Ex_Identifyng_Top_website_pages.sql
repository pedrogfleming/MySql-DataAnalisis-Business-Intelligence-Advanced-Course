/*
June 09,2012
Hi there!
I´m Morgan, the new Website Manager,
Could you help me get my head around the site by pulling
the most-viewed website pages,
ranked by session volume?    
Thanks!
-Morgan
*/
USE mavenfuzzyfactory;
DESC website_sessions;
DESC website_pageviews;
DESC orders;
SELECT * FROM website_pageviews;

SELECT 
    pageview_url,
    COUNT(DISTINCT website_session_id) AS total_views
FROM
    website_pageviews
WHERE
    created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY total_views DESC;

/*
After the data result:
Thank you!
It definitely seems like 
the homepage,
the products page,
and the Mr.Fuzzy page get the bulk of our traffic.
I would like to understand traffic patterns more.
I´ll follow up soon with a request to look at entry pages.
Thanks!
-Morgan

NEXT STEPS
.	Dig into whether this list is also representative of our top entry pages
.	Analyze the performance of each of our top pages to look for improvement opportunities
*/