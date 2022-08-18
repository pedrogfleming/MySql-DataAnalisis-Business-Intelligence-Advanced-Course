/*
September 05,2012
Hi there!
I'd like to understand where we lose our gsearch visitors
between the new/lander-1 page and placing an order.
Can you build us a full conversion funnel,
analyzing how many customers make it to each step?
Start with/lander-1 
and build the funnel all the way to our thank you page.
Please use data since August 5th.
Thanks!
-Morgan
*/

-- STEP 1 : select all pageviews for relevant sessions 
-- STEP 2: identify each pageview as the specific funnel step 
-- STEP 3: create the session-level conversion funnel view
-- STEP 4: aggregate the data to assess funnel performance

USE mavenfuzzyfactory;
SELECT * FROM  website_sessions AS ws2;
SELECT * FROM website_pageviews WHERE pageview_url LIKE '/bil%';

DROP TABLE IF EXISTS base_pageviews_per_session;
CREATE TEMPORARY TABLE base_pageviews_per_session
SELECT 
	ws.website_session_id ,
	wp.pageview_url ,
	wp.created_at AS pageview_created_at,
	CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN wp.pageview_url  ='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
	CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions ws 
	LEFT JOIN website_pageviews wp 
		ON ws.website_session_id = wp.website_session_id 
WHERE ws.created_at BETWEEN '2012-08-05' AND '2012-09-05'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
	AND wp.pageview_url  IN (
	'/lander-1',
	'/products',
	'/the-original-mr-fuzzy',
	'/cart',
	'/shipping',
	'/billing',
	'/thank-you-for-your-order')
ORDER BY
	ws.website_session_id,
	wp.created_at ;
	
SELECT * FROM base_pageviews_per_session;


-- Then we group per session all the path made it with flags per page clicked

DROP TABLE IF EXISTS session_level_made_it_flags;
CREATE TEMPORARY TABLE session_level_made_it_flags
SELECT
    website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM base_pageviews_per_session
GROUP BY website_session_id;

-- then this would produce the final output (part 1)

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
	COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
	COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
	COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
	COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
	COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
FROM session_level_made_it_flags;

-- then this as final output part 2 - click rates
-- we calculate the rate dividing the destination page / previous page
SELECT 
	(
		COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)
		/
		COUNT(DISTINCT website_session_id)
	) AS lander_click_rt,	
	(
		COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)
		/
		COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)
	) AS products_click_rt,	
	(
		COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)
		/
		COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)
	) AS mrfuzzy_click_rt,
	(
		COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)
		/
		COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)
	) AS cart_click_rt,
	
	(
		COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)
		/
		COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)
		
	) AS shipping_click_rt,
	(
		COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)
		/
		COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)
	) AS billing_click_rt
FROM session_level_made_it_flags;

/*
After the result data:
This analysis is really helpful!
Look like we should focus on the lander, Mr.Fuzzy page,
and the billing page, which have the lowest click rates.
I have some ideas for the billing page that I think will make customers more comfortable entering their credit card info.
I´ll test a new page soon and will ask for help analyzing performance.
Thnaks!
-Morgan

NEXT STEPS:
.	Help Morgan analyze the billing page test she plans to run
.	Continue to look for opportunities to improve customer conversion rates
*/