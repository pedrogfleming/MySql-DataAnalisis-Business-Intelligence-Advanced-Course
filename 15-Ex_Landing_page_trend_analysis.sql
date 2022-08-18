/*
August 31,2012
Hi there,
Could you pull the volume of paid search nonbrand traffic landing on /home and /lander-1,
trended weekly since June 1st?
I want to make sure the lander change has improved the overall picture
Thanks!
*/

-- STEP 1: finding the first website_pageview_id for relevant sessions
-- STEP 2: identifying the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing by week (bounce rate, sessions to each lander)

USE mavenfuzzyfactory;

/* Remember: 
first_pageview_id is used to track the landing page that arrived each user
count_pageviews allow us to identify "bounces" in later calculations
*/
DROP TABLE IF EXISTS sessions_w_min_pv_id_and_view_count;
CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count
SELECT 
	website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
	COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE 
	website_sessions.created_at > '2012-06-01' -- asked by requestor
    AND website_sessions.created_at < '2012-08-31' -- prescribed by assignment date
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	website_sessions.website_session_id;

SELECT * FROM sessions_w_min_pv_id_and_view_count;


-- We obtain the time of each session and his landing_page 

DROP TABLE IF EXISTS sessions_w_counts_lander_and_created_at;
CREATE TEMPORARY TABLE sessions_w_counts_lander_and_created_at
SELECT
	sessions_w_min_pv_id_and_view_count.website_session_id,
	sessions_w_min_pv_id_and_view_count.first_pageview_id,
	sessions_w_min_pv_id_and_view_count.count_pageviews,
	website_pageviews.pageview_url AS landing_page,
	website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_id_and_view_count
	LEFT JOIN website_pageviews 
		ON sessions_w_min_pv_id_and_view_count.first_pageview_id = website_pageviews.website_pageview_id;

SELECT * FROM sessions_w_counts_lander_and_created_at;

-- Finaly, we group by week the total of session and calculate the bounce rate for both of the landing pages
SELECT 
	-- YEARWEEK(session_created_at) AS year_week,
	MIN(DATE(session_created_at)) AS week_start_date,
	-- COUNT(DISTINCT website_session_id) AS total_sessions,
	-- COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
	(
		COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) *1.0
		/
		COUNT(DISTINCT website_session_id)
	) AS bounce_rate,
	COUNT(DISTINCT CASE WHEN landing_page= '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
	COUNT(DISTINCT CASE WHEN landing_page= '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions
FROM sessions_w_counts_lander_and_created_at
GROUP BY 
	YEARWEEK(session_created_at);

/*
 * After the data result:
 * This is great. Thank you!
 * Looks like both pages were getting traffic for a while,
 * and then we fully switched over to the custom lander, as intended.
 * And it looks like our overall bounce rate has come down over time...nice!
 * I am going to do a full deep dive into our site, and will follo up with asks.
 * Thanks!
 * -Morgan
 * 
 * NEXT STEPS:
 * 	Enjoy the moment - your analysis of the experiment helped improve the business!
 * Stay tuned for the next wave of analysis request from Morgan,
 * who is fired up about optimizing the website after her first win
 */