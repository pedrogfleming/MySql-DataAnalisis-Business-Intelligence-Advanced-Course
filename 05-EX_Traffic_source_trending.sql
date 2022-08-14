/*
May 10,2012
Hi there,
Based on your conversion rate analysis,we bid down
gsearch nonbrand on 2012-04-15.
Can you pull gsearch nonbrand trended session volume,by
week,to see if the bid changes have caused volume to drop
at all?
Thanks,Tom
*/

USE mavenfuzzyfactory;

SELECT * FROM website_sessions;

DESC website_sessions;
DESC website_pageviews;
DESC orders;

SELECT
   MIN(DATE(created_at)) week_start,
	COUNT(DISTINCT website_session_id)AS sessions
FROM website_sessions
WHERE 
utm_source = 'gsearch' AND
utm_campaign = 'nonbrand' AND
created_at < '2012-05-10'
GROUP BY 
YEAR(created_at),
WEEK(created_at)
ORDER BY week_start ASC;

/*
After the results of the data:
Hi there, great analysis!
Okay, based on this, it does look like gsearch nonbrand is fairly sensitive to bid changes
We want to maximum volume, but don´t want to spend more on ads than we can afford.
Let me think on this, I will likely follow up with some ideas.
Thanks, Tom

NEXT STEPS:
•	Continue to monitor volume levels
•	Thnik about how we could make the campaigns more efficient so that we can increase volume again
*/