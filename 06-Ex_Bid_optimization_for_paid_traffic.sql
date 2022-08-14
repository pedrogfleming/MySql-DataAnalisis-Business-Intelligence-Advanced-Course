/*
May 11,2012
Hi there,
I was trying to use our site on my mobile device the other day, and the experience was not great.
Could you pull conversion rates from session to order, by device type?
If desktop performance is better than on mobile
we may be able to bid up for desktop specifically to get more volume?
Thnks,Tom
*/

USE mavenfuzzyfactory;

DESC website_sessions;
DESC website_pageviews;
DESC orders;
SELECT * FROM website_sessions;
SELECT 	
	web_sessions.device_type,
    COUNT(DISTINCT web_sessions.website_session_id) AS sessions,
    COUNT(o.website_session_id) AS orders,
    (
		COUNT(DISTINCT o.website_session_id)
        /
		COUNT(DISTINCT web_sessions.website_session_id)
    ) AS sessions_to_order_conv_rate
FROM
    website_sessions AS web_sessions
LEFT JOIN orders AS o
ON web_sessions.website_session_id = o.website_session_id
WHERE
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand' AND
    web_sessions.created_at < '2012-05-11'
GROUP BY device_type
ORDER BY sessions_to_order_conv_rate DESC;

/*
After the results of the data:
Great!
I´m going to increase our bids on desktop.
When we bid higher, we´ll rank higher in the auctions, 
so I think your insights here should lead to a sales boost.
Well done!!
-Tom

NEXT STEPS:
•	Analyze volume by device type to see if the bid changes make a material impact
•	Continue to look for ways to optimize campaigns
*/