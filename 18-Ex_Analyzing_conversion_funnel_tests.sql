/*
November 10,2012
Hello!
We tested an updated billing page based on your funnel analysis.
Can you takealook and see whether /billing-2 is
doing any better than the original /billing page?
We're wondering what%of sessions on those pages end up
placing an order.FYI-we ran this test for all traffic,not just
for our search visitors.
Thanks!
-Morgan
 */

-- first, finding the starting point to frame the analysis 
SELECT 
	MIN(wp.website_pageview_id) AS first_pv_id
FROM website_pageviews AS wp 
WHERE pageview_url = '/billing-2';
-- first_pv_id = 53550


-- first we´ll look at this without orders, then we´ll add in orders 

DROP TABLE IF EXISTS billing_sessions_w_orders;
CREATE TABLE billing_sessions_w_orders
SELECT 
	wp.website_session_id ,
	wp.pageview_url AS billing_version_seen,
	o.order_id 
FROM website_pageviews AS wp 
	LEFT JOIN orders AS o 
		ON o.website_session_id = wp.website_session_id 
WHERE wp .website_pageview_id >= (SELECT MIN(wp.website_pageview_id) AS first_pv_id FROM website_pageviews AS wp WHERE pageview_url = '/billing-2')
AND wp.created_at < '2012-11-10' -- time OF ASSIGNMENT
AND wp.pageview_url IN ('/billing','/billing-2'); 

-- same as above, just wrapping as a subquery and summarizing
-- final analysis output

SELECT 
	billing_version_seen,
	COUNT(DISTINCT website_session_id) AS sessions,
	COUNT(DISTINCT order_id) AS orders,
	(
		COUNT(DISTINCT order_id)
		/
		COUNT(DISTINCT website_session_id)
	) AS billing_to_order_rt
FROM billing_sessions_w_orders
GROUP BY 
	billing_version_seen;

/*
After the data result:

This is so good to see!
Looks like the new version of the billing page is doinga
much better job converting customers ... yes !!
Iwill get Engineering to roll this out to all of our customers right away.
Your insights just made us some major revenue.
Thanks so much!
-Morgan

NEXT STEPS:
.	 After Morgan gets Engineering to roll out the  new version to 100% of traffic,
	 use the data to confirm they have done so correctly
.	 Monitor overall sales performance to see the  impact this change produces
*/