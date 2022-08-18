-- The most entry page/landing page viewed by our users

CREATE TEMPORARY TABLE first_pageview
SELECT
	website_session_id,
    MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE website_pageview_id < 1000 -- arbitrary
GROUP BY website_session_id;

SELECT
	website_pageviews.pageview_url AS landing_page, -- or "entry page"
    COUNT(DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.min_pv_id = website_pageviews.website_pageview_id
GROUP BY
	website_pageviews.pageview_url;

DROP TABLE first_pageview;