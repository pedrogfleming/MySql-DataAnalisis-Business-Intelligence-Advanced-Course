/*
June 12,2012
Hi there!
Would you be able to pull a list of the top entry pages?
I want to confirm where our users are hitting the site.
If could pull all entry pages and rank them on entry volume, tha would be great.
Thanks!
-Morgan
*/

-- Step 1: find the first pageview for each session

-- Step 2:  find the url the customer saw on that first pageview

USE mavenfuzzyfactory;
CREATE TEMPORARY TABLE first_pageview_per_session
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE created_at < '2012-06-12' 
GROUP BY website_session_id;


SELECT 
    web_pv.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_pv_session.website_session_id) AS sessions_hitting_page
FROM
    website_pageviews AS web_pv
        RIGHT JOIN
    first_pageview_per_session AS first_pv_session ON web_pv.website_pageview_id = first_pv_session.min_pv_id
GROUP BY landing_page_url;


/*
After the data result:
Wow, looks like our traffic all comes in through the homepage right now!
Seems pretty obvius where we should focus on making any improvements
I will likely have some follow up request to look into performance for the homepage - stay tuned!
Thanks
-Morgan

NEXT STEPS:
.	Analyze landing page performance,for the homepage specifically
.	Think about whether or not the homepage is the best initial experience for all customers
*/

DROP TABLE first_pageview_per_session;