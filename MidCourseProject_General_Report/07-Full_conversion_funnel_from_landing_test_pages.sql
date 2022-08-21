/*
For the landing page test you analize previously, it would be great to show a full conversion funnel
from each of the two pages to orders.
You can use the same time period you analyzed last time (Jun 19 - Jul 28)
*/

USE mavenfuzzyfactory;


DROP TABLE IF EXISTS funnel_base_on_pageviews;
CREATE TEMPORARY TABLE funnel_base_on_pageviews
SELECT 
	ws.website_session_id ,
	wp.pageview_url ,
	wp.created_at AS pageview_created_at,
	CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
	CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS custom_lander,
	CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions AS ws 
	LEFT JOIN website_pageviews AS wp 
		ON ws.website_session_id =wp.website_session_id 
WHERE 
	ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
	AND ws.created_at < '2012-07-28'
	AND ws.created_at  > '2012-06-19'
ORDER BY 
	ws.website_session_id ,
	wp.created_at;



-- we use the max(value) to know if they saw or not that especific page as true(1) or false(0)

DROP TABLE IF EXISTS session_level_made_it_flagged;
CREATE TEMPORARY TABLE session_level_made_it_flagged
SELECT
	website_session_id,
	MAX(homepage) AS saw_homepage,
	MAX(custom_lander) AS saw_custom_lander,
	MAX(products_page) AS product_made_it,
	MAX(mrfuzzy_page) AS mrfuzzy_made_it,
	MAX(cart_page) AS cart_made_it,
	MAX(shipping_page) AS shipping_made_it,
	MAX(billing_page) AS billing_made_it,
	MAX(thankyou_page) AS thankyou_made_it
FROM funnel_base_on_pageviews
GROUP BY 
	website_session_id;
	
-- then this would produce the final output, part 1

SELECT 
	CASE
		WHEN saw_homepage = 1 THEN 'saw_homepage'
		WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
		ELSE 'uh oh... check logic'
	END AS segment,
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL end) AS to_products,
	COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL end) AS to_mrfuzzy,
	COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL end) AS to_cart,
	COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL end) AS to_shipping,
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL end) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL end) AS to_thankyou
	FROM session_level_made_it_flagged
GROUP BY 1;

-- then this is as final output part 2- converted to click rates
SELECT 
	CASE
		WHEN saw_homepage = 1 THEN 'saw_homepage'
		WHEN saw_custom_lander = 1 THEN 'saw_custom_lander'
		ELSE 'uh oh... check logic'
	END AS segment,
	(
		COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL end)
		/
		COUNT(DISTINCT website_session_id)
	) AS lander_click_rt,
	(
		COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL end)
		/
		COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL end)
	) AS products_click_rt,
	(
		COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL end)
		/
		COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL end)
	) AS mr_fuzzy_click_rt,
	(
		COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL end)
		/
		COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL end)
	) AS cart_click_rt,
	(
		COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL end)
		/
		COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL end)		
	) AS shipping_click_rt,
	(
		COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL end)
		/
		COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL end)
	) AS billing_click_rt
	FROM session_level_made_it_flagged
GROUP BY 1;

