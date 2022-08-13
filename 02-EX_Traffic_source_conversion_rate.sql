/*
April 14,2012
Hi there,
Sounds like gsearch nonbrand is our major traffic source,but
we need to understand if those sessions are driving sales.
Could you please calculate the conversion rate(CVR)from
session to order?Based on what we're paying for clicks,
we'll needaCVR of at least4%to make the numbers work.
If we're much lower,we'll need to reduce bids.If we're
higher,we can increase bids to drive more volume.
Thanks,Tom
*/

DESC website_sessions;
DESC website_pageviews;
DESC orders;

SELECT 	
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
-- Based in the previous assignment (01) TOP 1
    web_sessions.created_at < '2012-04-14'AND
    utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand';
/*
After the results of the data:
Hmm,looks like we're below the 4% threshold we need
to make the economics work.
Based on this analysis,we'll need to dial down our search bids a bit.
We're over-spending based on the current conversion rate.
Nice work,your analysis just saved us some $$$!

NEXT STEPS:
•	Monitor the impact of bid reductions
•	Analyze performance trending by device type in order to refine bidding strategy
*/