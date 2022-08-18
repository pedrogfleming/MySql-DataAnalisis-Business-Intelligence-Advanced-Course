/*
July 28,2012
Hi there!
Based on your bounce rate analysis, 
we ran a new custom landing page (/lander-1)
in a 50/50 test against the homepage (/home) 
for our gsearch nonbrand traffic.

Can you pull bounce rates for the two groups so we can
evaluate the new page? 
Make sure to just look at the time period where /lander-1 was getting traffic,
so that it is a fair comparison.
Thanks,Morgan.

*/
USE mavenfuzzyfactory;


-- STEP 0: find out when the new page /lander launched
-- STEP 1: finding the first website_pageview_id for relevant sessions
-- STEP 2: identifying the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing total sessions and bounced sessions, by Landing Page

-- finding the first instance of /lander-1 to set analysis timeframe
DROP TABLE IF EXISTS first_instance_of_lander_1;
CREATE TEMPORARY TABLE first_instance_of_lander_1
SELECT 
	MIN(created_at) AS first_created_at,
    website_pageview_id AS first_pageview_id
FROM website_pageviews
WHERE 
	pageview_url = '/lander-1'
    AND created_at IS NOT NULL;

DROP TABLE IF EXISTS first_test_pageviews;
CREATE TEMPORARY TABLE first_test_pageviews
SELECT
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at < '2012-07-28' -- prescribed by the assignment
        AND website_pageviews.website_pageview_id > (SELECT first_pageview_id FROM first_instance_of_lander_1)
		AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY
	website_pageviews.website_session_id;
    
-- next, we´ll bring in the landing page to each session,
-- like last time, but restricting to home or lander-1 this time

DROP TABLE IF EXISTS nonbrand_test_sessions_w_landing_page;
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

-- THEN A TABLE TO HAVE COUNT OF PAGEVIEWS PER SESSION
-- THEN LIMIT IT TO JUST BOUNCED_SESSSIONS

DROP TABLE IF EXISTS nonbrand_test_bounced_sessions;
CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
SELECT
	nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = nonbrand_test_sessions_w_landing_page.website_session_id
GROUP BY 
	nonbrand_test_sessions_w_landing_page.website_session_id,
    Nonbrand_test_sessions_w_landing_page.landing_page
HAVING
	COUNT(website_pageviews.website_pageview_id) = 1;
    
-- do this first to show, then count them after:

SELECT
	nonbrand_test_sessions_w_landing_page.landing_page,
    nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_bounced_sessions.website_session_id AS bounced_website_session_id
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions
		ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
ORDER BY
	nonbrand_test_sessions_w_landing_page.website_session_id;
    
-- So finally, we count the bounce rate per session by landing page

SELECT
	nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
    (
		COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id)
        /
        COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id)
    ) AS bounce_rate
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions
		ON nonbrand_test_sessions_w_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
GROUP BY
	nonbrand_test_sessions_w_landing_page.landing_page;
    
/*
After the result data:
Hey!
This is so great.It looks like the custom lander has a lower bounce rate...success!
I will work with Tom to get campaigns updated so that all nonbrand paid traffic is pointing to the new page.
In a few weeks, I would like you to take a look at trends to make sure things have moved in the right direction.
Thanks, Morgan

NEXT STEPS:
.	Help Morgan confirm that traffic is all running to the new custom lander after campaign updates
.	Keep an eye on bounce rates and help the team look for other areas to test and optimize
*/