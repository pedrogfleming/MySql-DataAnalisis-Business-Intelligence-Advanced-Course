-- Demo on building conversion funnels

-- BUSINESS CONTEXT

-- we want to build a mini conversion funnel, from /lander-2 to /cart
-- we want to know how many people reach each step, and also dropoff rates
-- for simplicity of the demo, we?re looking at /lander-2 traffic ONLY
-- for simplicity of the demo, we?re looking at customers who like Mr Fuzzy only

-- STEP 1: select all pageviews for relevant sessions
-- STEP 2: identify each relevant pageview as the specific funnel step
-- STEP 3: create the session-level conversion funnel view
-- STEP 4: aggregate the data to assess funnel performance

-- first I will show you all of the pageviews we care about
-- then, I will remove the comments from my flag columns one by one to show you that looks like

SELECT 
	ws.website_session_id ,
	wp.pageview_url ,
	wp.created_at AS pageview_created_at,
	CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN wp.pageview_url  ='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
FROM website_sessions ws 
	LEFT JOIN website_pageviews wp 
		ON ws.website_session_id = wp.website_session_id 
WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe FOR demo
	AND wp.pageview_url  IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY
	ws.website_session_id,
	wp.created_at ;
	
-- next we will put the previous query insideasubquery(similar to temporary tables)
--  we will group by website_session_id,and take the MAX()of each of the flags
--  this MAX()becomes a made_it flag for that session,to show the session made it there

SELECT
    website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
 FROM (
 	SELECT 
	ws.website_session_id ,
	wp.pageview_url ,
	wp.created_at AS pageview_created_at,
	CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN wp.pageview_url  ='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
	FROM website_sessions ws 
		LEFT JOIN website_pageviews wp 
			ON ws.website_session_id = wp.website_session_id 
	WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe FOR demo
		AND wp.pageview_url  IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
	ORDER BY
		ws.website_session_id,
		wp.created_at
 ) AS pageview_level
 GROUP BY website_session_id;
 
-- next we will turn it into a temp table

DROP TABLE IF EXISTS session_level_made_it_flags_demo;
CREATE TEMPORARY TABLE session_level_made_it_flags_demo
SELECT
    website_session_id,
    MAX(products_page) AS product_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it
 FROM (
 	SELECT 
	ws.website_session_id ,
	wp.pageview_url ,
	wp.created_at AS pageview_created_at,
	CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
	CASE WHEN wp.pageview_url  ='/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page
	FROM website_sessions ws 
		LEFT JOIN website_pageviews wp 
			ON ws.website_session_id = wp.website_session_id 
	WHERE ws.created_at BETWEEN '2014-01-01' AND '2014-02-01' -- random timeframe FOR demo
		AND wp.pageview_url  IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
	ORDER BY
		ws.website_session_id,
		wp.created_at
 ) AS pageview_level
 GROUP BY website_session_id;
 
SELECT * FROM session_level_made_it_flags_demo;

-- then this would produce the final output (part 1)

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
	COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
	COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart
FROM session_level_made_it_flags_demo;

-- then we?ll translate those counts to click rates for final output part 2 (click rates)
-- I?ll start with the same query we just did, and show you how to calculate the rates 

SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
	(
		COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)
		/
		COUNT(DISTINCT website_session_id)
	) AS clicked_to_products,	
	(
		COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)
		/
		COUNT(DISTINCT website_session_id)
	) AS clicked_to_mrfuzzy,	
	(
		COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)
		/
		COUNT(DISTINCT website_session_id)
	) AS clicked_to_cart	
FROM session_level_made_it_flags_demo;