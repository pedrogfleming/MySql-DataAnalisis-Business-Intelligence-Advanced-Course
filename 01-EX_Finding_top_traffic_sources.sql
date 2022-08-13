USE mavenfuzzyfactory;
-- WHERE created_at < '2012-04-12'
/*SITE TRAFFIC BREAKDOWN
April 12,2012
Good morning,We've been live for almost a month now and we're
starting to generate sales.
Can you help me understand where the bulk of our website sessions are coming
from,through yesterday?
I'd like to see a breakdown by
UTM source,
campaign
and referring domain
if possible.Thanks! -Cindy
*/

DESC website_sessions;
DESC website_pageviews;
DESC orders;

SELECT * FROM website_sessions;
SELECT * FROM website_pageviews;
SELECT * FROM orders;

SELECT 
	utm_source,
    utm_campaign,
    http_referer,  
    COUNT(DISTINCT website_session_id) AS number_of_sessions
FROM
    website_sessions
WHERE
    created_at < '2012-04-12'
GROUP BY 
	utm_source,
    utm_campaign,
    http_referer
ORDER BY number_of_sessions DESC;
/*
After the results of the data:
Great analysis!
Based on your findings,it seems like we should
probably dig into gsearch,nonbrandabit deeper to
see what we can do to optimize there.
I'll loop in Tom tomorrow morning to get his thoughts
on next steps.
-Cindy

NEXT STEPS:
•	Drill deeper into gsearch nonbrand campaign traffic to explore potential optimization opportunities
•	Await further instruction from Tom
*/