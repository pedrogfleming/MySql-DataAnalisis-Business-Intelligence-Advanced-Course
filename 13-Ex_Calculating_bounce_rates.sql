/*
June 14,2021
Hi there!
The other day you shoved us that all of our traffic is landing on the homepage right now.
We should check how that landing page is performing
Can you pull bounce rates for traffic landing on the homepage?
I would like to see three numbers...
Sessions,
Bounced Sessions,
and % of Sessions which bounced (aka "Bounce Rate")
Thanks!
-Morgan
*/

-- STEP 1: finding the first website_pageview_id for relevant sessions
-- STEP 2: identifying the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"ALTER
-- STEP 4: summarizing by counting total sessions and bounced sessions

USE mavenfuzzyfactory;

-- finding the minimun website pageview id associated with each session we care about
-- And we store the dataset as a temporary table
DROP TABLE first_pageviews;
CREATE TEMPORARY TABLE first_pageviews
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pageview_id
FROM website_pageviews
WHERE created_at <'2021-06-14'
GROUP BY
	website_session_id;
    
SELECT * FROM first_pageviews;
    
-- next, we´ll bring in the landing page to each session, but restrict to home only
-- this is redundant in this case, since all is to the homepage
DROP TABLE sessions_w_home_landing_page;
CREATE TEMPORARY TABLE sessions_w_home_landing_page
SELECT
	first_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews
	LEFT JOIN website_pageviews
		-- website pageview is the landing page view
		ON website_pageviews.website_pageview_id = first_pageviews.min_pageview_id
WHERE website_pageviews.pageview_url = '/home';

-- then a table to have count of pageviews per sessions
-- then limit it to just bounced_sessions

SELECT * FROM sessions_w_home_landing_page;

DROP TABLE bounced_sessions;
CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page,
	COUNT(website_pageviews.website_pageview_id) AS total_pages_per_session
FROM sessions_w_home_landing_page
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = sessions_w_home_landing_page.website_session_id 
GROUP BY 
	sessions_w_home_landing_page.website_session_id,
    sessions_w_home_landing_page.landing_page
HAVING total_pages_per_session = 1;


-- we´ll do this first just to show what´s in this query, then we will count them after:
-- Session who have multiple pages viewed will retrieve null in the 2nd colum because aren´t bounced sessions


SELECT 
	sessions_w_home_landing_page.website_session_id,
    bounced_sessions.website_session_id AS bounced_website_session_id
FROM sessions_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id
ORDER BY sessions_w_home_landing_page.website_session_id;



SELECT
	COUNT(DISTINCT sessions_w_home_landing_page.website_session_id) AS total_sessions,
	COUNT(DISTINCT bounced_sessions.website_session_id) AS total_bounced_session,
    (
		COUNT(DISTINCT bounced_sessions.website_session_id)
		/
		COUNT(DISTINCT sessions_w_home_landing_page.website_session_id)  
    ) AS bounce_rate
FROM sessions_w_home_landing_page
LEFT JOIN bounced_sessions
	ON sessions_w_home_landing_page.website_session_id = bounced_sessions.website_session_id;
    
/*
 Tha data its different from the video, it should look like this:

sessions		bounced_sessions		bounce_rate
	11044				6536				0.5918
After the result of the data:

Ouch... Almost a 60% bounce rate!
That´s pretty high from my experience, especially for paid search, which should be high quality traffic.

I will put together a coustom landing page for search,
and set up an experiment to see if the new page does better.
I will likely need your help analyzing the test once we get enough data to judge performance.
Thanks,Morgan.

NEXT STEPS:
.	Keep an eye on bounce rates,which represent a major area of improvement.
.	Help Morgan measure and analyze a new page that she thinks will improve performance,
	and analyze the results of an A/B split test against the homepage
*/