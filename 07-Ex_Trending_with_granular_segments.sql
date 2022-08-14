/*
June 09,2012
Hi there,
After your device-level analysis of conversion rates,
we realized desktop was doing well,
so we bid our gsearch nonbrand desktop campaigns up on 2012-05-19.
Coud you pull weekly trends for both desktop and mobile
so we can see the impact on volume?
Yo can use 2012-04-15 until the bid change as a baseline.
Thanks,Tom
*/

-- Using a pivot table
SELECT
	MIN(DATE(created_at)) week_start,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END)AS dtop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)AS mob_sessions
    -- COUNT(DISTINCT website_session_id) AS total_sessions
FROM website_sessions
WHERE 
	utm_source = 'gsearch' AND
    utm_campaign = 'nonbrand' AND
    website_sessions.created_at BETWEEN '2012-04-15' AND '2012-06-09'
GROUP BY 
YEAR(created_at),
WEEK(created_at)
ORDER BY YEAR(created_at) ASC,WEEK(created_at) ASC;

/*
After the results of the data:
Nice work diggin into this!
It looks like mobile has been pretty flat or a little down,
but desktop is looking strong thanks to the bid changes we made
based on your previous conversion analysis.
Thing are moving in the right direction!
Thanks,Tom

NEXT STEPS:
•	Continue to monitor device-level volume and be aware of the impact bid levels has
•	Continue to monitor conversion performance at the device-level to optimize spend
*/