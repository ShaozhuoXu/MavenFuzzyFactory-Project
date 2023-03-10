####################################################################################################################################
-- Project One: Analyze and show the company's promising growth 
####################################################################################################################################
-- Project Situation:
-- Maven Fuzzy Factory has been live for ~8 months, 
-- and your CEO is due to present company performance metrics to the board next week. 
-- You’ll be the one tasked with preparing relevant metrics to show the company’s promising growth.
####################################################################################################################################
-- Project objective:
-- Extract and analyze website traffic and performance data from the Maven Fuzzy Factory database to quantify the company’s growth,
-- Analyze current performance, and use that data available to assess upcoming opportunities
####################################################################################################################################
-- Project Date Period: Before November 27, 2012
####################################################################################################################################
-- Project Mamo 1: 
-- Gsearch (one of the utm-source) seems to be the biggest driver of our business. 
-- Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there?
-- skills test: Trend Analysis
SELECT * FROM website_sessions; -- CHECK DATABASE 
SELECT * FROM website_pageviews;
SELECT * FROM orders;

SELECT 
YEAR(website_sessions.created_at) AS session_year,
MONTH(website_sessions.created_at) AS session_month,
COUNT(DISTINCT website_sessions.website_session_id) AS growth_session,
COUNT(DISTINCT orders.order_id) AS order_growth,
COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS CONVERSION_RATE
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY session_year,session_month;

-- Result / insight Suggestion: 
	-- Trending analysis, we could see that the session number for 'gsearch' utm_source is keep increasing from Mar to Nov
    -- the order are keep growth from 22 to 373 during those 8 months 

####################################################################################################################################
-- Project Mamo 2: 
-- it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately
-- manager is wondering if brand is picking up at all. If so, this is a good story to tell
-- skills test: Trend Analysis, subquary
SELECT * FROM website_sessions; -- CHECK DATABASE 
SELECT * FROM website_pageviews;
SELECT * FROM orders;

SELECT 
session_year,
session_month,
nonbrand_growth_session,
nonbrand_growth_orders,
brand_growth_session,
brand_growth_orders,
nonbrand_growth_orders / nonbrand_growth_session AS nonbrand_conversion_rate,
brand_growth_orders / brand_growth_session AS brand_Conversion_rate
FROM (
SELECT 
YEAR(website_sessions.created_at) AS session_year,
MONTH(website_sessions.created_at) AS session_month,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END ) AS nonbrand_growth_session,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END ) AS nonbrand_growth_orders,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END ) AS brand_growth_session,
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END ) AS brand_growth_orders
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
GROUP BY session_year,session_month
) AS page_level
GROUP BY 1,2;

-- Result / insight Suggestion: 
	-- Trending analysis, we could see that the session number for 'gsearch' utm_source with nonbrand have the stronger growth sessions and orders trend than brand 
    -- nonbrand have a stable growth on conversion rate, however, brand's conversion is unstable, as the sessions and orders number increased the brand conversion rate decreased. 
    -- By looking at the conversion rate, we could see that even though the total amount of session and orders number for brand is weaker than nonbrand, 
    -- but brand's the coversion rate acutally higher than non-brand at the final stage. 
    
####################################################################################################################################
-- Project Mamo 3: 
-- CEO Asking: Could you dive into nonbrand, and pull monthly sessions and orders split by device type?
-- manager want to flex our analytical muscles a little and show the board we really know our traffic sources.

SELECT * FROM website_sessions; -- CHECK DATABASE 
SELECT * FROM website_pageviews;
SELECT * FROM orders;

DROP TEMPORARY TABLE IF EXISTS device_sessions_orders;
CREATE TEMPORARY TABLE device_sessions_orders
SELECT 
YEAR(website_sessions.created_at) AS year,
MONTH(website_sessions.created_at) AS month, 
COUNT( DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
COUNT( DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN orders.order_id ELSE NULL END ) AS mobile_orders,
COUNT( DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
COUNT( DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN orders.order_id ELSE NULL END ) AS desktop_orders
FROM website_sessions
LEFT JOIN orders
ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1,2;
SELECT * FROM device_sessions_orders;

SELECT 
year,month,
mobile_orders / mobile_sessions AS mobile_conversion_rate,
desktop_orders / desktop_sessions AS deskto_conversion_rate
FROM device_sessions_orders;

-- Result / insight Suggestion: 
	-- Trending analysis, we could see that Desktop type have way stronger growth trend than the mobile device on sessions and orders.
    -- On the conversion rate analysis, we be able to see that desktop's CRV is stably increasing in 8 months
    -- mobile device's CRV do not have any siginificant improvement after July 2012.

####################################################################################################################################
-- Project Mamo 4: 
-- one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch 
-- Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?

SELECT 
DISTINCT utm_source,utm_campaign,http_referer  -- Identiy all the channels for for utm-source / utm_campaign /http_referer
FROM website_sessions -- we have 'gsearch', 'bsearch'
WHERE website_sessions.created_at < '2012-11-27';
-- Result / insight Suggestion: 
	-- we have utm-source / utm_campaign /http_referer are all null we know that is direct in traffic,
    -- we have utm-source / utm_campaign are null but still have http_referer then we know that is orgainc search traffic
    -- now, we are going to analysis all those type traffic 

DROP TEMPORARY TABLE IF EXISTS channels_trend;
CREATE TEMPORARY TABLE channels_trend
SELECT 
YEAR(created_at)AS year,
MONTH(created_at) AS month,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END)AS gsearch_sessions,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END)AS bsearch_sessions,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS organic_search_sessions,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS direct_search_sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;
SELECT * FROM channels_trend;
-- Result Suggestion for channels trend table : 
	-- Trending analysis, compared with 'bsearch' and 'socialbook', we could see that 'gsearch' is still our strongest traffic channels. 
    -- we can see that we still have small amount of the traffic that comes from organic_search_sessions and direct_search_sessions
    -- those two types of search are non margin cost, it is a suprise for us. 

SELECT year,month,
gsearch_sessions / (gsearch_sessions+bsearch_sessions+organic_search_sessions+direct_search_sessions) AS share_of_gsearch,
bsearch_sessions / (gsearch_sessions+bsearch_sessions+organic_search_sessions+direct_search_sessions) AS share_of_bsearch,
organic_search_sessions / (gsearch_sessions+bsearch_sessions+organic_search_sessions+direct_search_sessions) AS share_of_organic_search,
direct_search_sessions / (gsearch_sessions+bsearch_sessions+organic_search_sessions+direct_search_sessions) AS share_of_direct_search
FROM channels_trend;

-- Result / insight Suggestion for share analysis: 
    -- for the share analysis, we are able to see the share of gsearch decreasing, and the bsearch channel are increasing, which mean more and more people access from bsearch
    -- share of gsearch decreased from 95% in Jan to 69% in November, bsearch increased percentage of share from less than 1% in Jan to 20% in November
    -- oganic search and direct search are remain stable around 1~5% 
####################################################################################################################################
-- Project Mamo 5:
	-- I’d like to tell the story of our website performance (Growth of referer webstie trend )improvements over the course of the first 8 months. 
    -- Could you pull session to order conversion rates, by month?
    
SELECT * FROM website_sessions; -- CHECK DATABASE 
SELECT * FROM website_pageviews;
SELECT * FROM orders;

SELECT DISTINCT  http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'; -- define how many website we have

DROP TEMPORARY TABLE IF EXISTS web_performance;
CREATE TEMPORARY TABLE web_performance
SELECT 
YEAR(website_sessions.created_at) AS year,
MONTH(website_sessions.created_at) AS month,
COUNT(DISTINCT CASE WHEN website_sessions.http_referer = 'https://www.gsearch.com' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_com_sessions,
COUNT(DISTINCT CASE WHEN website_sessions.http_referer = 'https://www.bsearch.com' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_com_sessions
FROM website_sessions
LEFT JOIN orders
ON website_sessions.website_session_id = orders.order_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2;
SELECT * FROM web_performance;

-- Result / insight Suggestion for TREND analysis: 
	-- both webstie sessions are increasing, which mean we had catch more and more customer attentions
    
SELECT Year,month,
gsearch_com_sessions / (gsearch_com_sessions + bsearch_com_sessions) AS percentage_gsearch,
bsearch_com_sessions / (gsearch_com_sessions + bsearch_com_sessions) AS percentage_bsearch
FROM web_performance;

-- Result / insight Suggestion for share analysis: 
	-- gsearch percentage are decresing during the 8 months and the customer start shifting from gsearch.com to bsearch.com

####################################################################################################################################
-- Project Mamo 6: 
	-- For the gsearch lander test (/lander-1), please estimate the revenue that test earned us
    -- Look at the increase in CVR from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value
-- Concepts recap:
	-- Website PageView ID 
		-- is a unique identifier that is generated by a website for each individual page view. 
        --  used to track individual page views and is typically associated with a single user.
        -- usually temporary and are only relevant for the duration of the page view.
	-- Website Session ID
		-- is a unique identifier that is generated by a website for each individual browsing session
        -- used to track a user's activity on the website over a period of time, including multiple page views.
        -- One webstie session ID will have mutiple pageview ID
SELECT * FROM website_sessions; -- CHECK DATABASE 
SELECT * FROM website_pageviews;
SELECT * FROM orders;

-- STEP 0: check when the test landing page ('/lander-1') released time and the first pageview ID, test start time
SELECT
MIN(created_at) AS first_pageview_date,
MIN(website_pageview_id) as First_pageview_ID
FROM website_pageviews
WHERE website_pageviews.pageview_url = '/lander-1'; 
--  we can see the '/lander-1' is launched as 2012-06-19 00:35:54 with the first pageview_ID 23504

-- STEP1: create TEMPORARY TABLE see the unique page view id with its own website sessions id 
DROP TEMPORARY TABLE IF EXISTS fist_test_pageviews;
CREATE TEMPORARY TABLE fist_test_pageviews
SELECT 
website_sessions.website_session_id,
MIN(website_pageviews.website_pageview_id) AS min_page_view_id
FROM website_pageviews
INNER JOIN website_sessions
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-07-28' -- the test end at Jul 28, we already know it
AND website_pageviews.website_pageview_id >= 23504 --  the frist page view test when the test start 
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY website_sessions.website_session_id;
-- now we have the session_id that correspond with the first page view id
-- different session_id will reach to mutiple page view id, because a customer may going through from /home page to /check out page
SELECT * FROM fist_test_pageviews;

-- STEP2: JOIN back to the website.pageview table and restricting to home or lander-1 page
DROP TEMPORARY TABLE IF EXISTS session_landing_table;
CREATE TEMPORARY TABLE session_landing_table
SELECT 
fist_test_pageviews.website_session_id,
website_pageviews.pageview_url AS landing_page
FROM fist_test_pageviews
LEFT JOIN website_pageviews
ON fist_test_pageviews.min_page_view_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');
SELECT * FROM session_landing_table;
-- now we have could see which session actually landing on with page: home or lander-1

-- STEP3: Combine the the session landing table and orders table 
DROP TEMPORARY TABLE IF EXISTS session_orders_made;
CREATE TEMPORARY TABLE session_orders_made
SELECT 
session_landing_table.website_session_id,
session_landing_table.landing_page,
orders.website_session_id AS Order_made
FROM session_landing_table
LEFT JOIN orders
ON session_landing_table.website_session_id = orders.website_session_id;
SELECT * FROM session_orders_made;
-- so that we could see which session ID actually make the order

-- STEP 4: COUNT the order made, and total session, and get the conversion rate for those two type landing_pages
SELECT 
session_orders_made.landing_page,
COUNT(DISTINCT session_orders_made.website_session_id) AS total_session,
COUNT( DISTINCT session_orders_made.Order_made) AS orders_session,
COUNT( DISTINCT session_orders_made.Order_made) / COUNT(DISTINCT session_orders_made.website_session_id) AS Conversion_Rate
FROM session_orders_made
GROUP BY 1;
-- now we could see that the lander-1 page have additional (0.0406-0.0318) orders per session than /home page
-- the incremental value percetage is 0.0088

-- STEP 5: we want know the specific pageview end for this TEST, looking for the end pageview ID
	-- finding the most recent pageview for gsearch nonbrand where the traffic was sent to home. (before every traffic are fully convert to lander-1)
SELECT 
MAX(website_sessions.website_session_id) AS recent_page_view_id
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND pageview_url = '/home';
-- We have the pageview ID: 17145 is in /home, after than all the traffic are going other url. 

-- STEP 6: we use the most recent pageview ID and count the number of the session actually during the test 
SELECT 
COUNT(website_sessions.website_session_id) AS session_since_test
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND website_session_id > 17145;
-- we can know that there 22972 sessions that are no longer go through the /home page view 
-- we calcuate the total incremental revenue now 
-- 22972 * 0.0088 = 202.1536 increment orders since the test

-- Result / insight Suggestion for conversion rate and increment revenue:
	-- after the test we could see that the conversionrate for lander-1 have 0.0088 percentage higher than /home;
    -- translate to incremental revenue, we know that /lander-1 page acutally generate 202 more orders than /home. 

####################################################################################################################################
-- Project Mamo 7: 
	-- For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each of the two pages to orders. 
    -- use the same time period you analyzed last time (Jun 19 – Jul 28) for conversion rate.
    -- Time Period: 2012-06-19 to 2012-07-28, utm-scouces = 'gsearch', and utm_campaign = 'nonbrand'
	-- we look at customers who like MR Fuzzy product only
    -- Skills Test: Conversion Funnel Test / A/B TESTING 
SELECT * FROM website_sessions; -- CHECK DATABASE 
SELECT * FROM website_pageviews;
SELECT * FROM orders;

-- STEP 0: distinct how many pageview_url it have in the database
SELECT DISTINCT website_pageviews.pageview_url
FROM website_sessions
LEFT JOIN website_pageviews
ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
AND website_sessions.utm_source = 'gsearch'
AND utm_campaign = 'nonbrand';
-- we identify that we have url: '/lander-1', '/home', '/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order'

	-- STEP 1: select all pageviews for relevant sessions
DROP TEMPORARY TABLE IF EXISTS ID_view;
CREATE TEMPORARY TABLE ID_view
SELECT
website_session_id,
MAX(landed_lander_1_page) AS Lander1_view,
MAX(landed_home_page) AS home_view,
MAX(landed_product_page) AS product_view,
MAX(landed_MRFuzzy_page) AS MRFuzzy_view,
MAX(landed_Cart_page) AS Cart_view,
MAX(landed_shipping_page) AS shipping_view,
MAX(landed_billing_page) AS billing_view
FROM(
SELECT 
website_sessions.website_session_id,
website_pageviews.pageview_url AS URL_Web,
-- website_pageviews.created_at AS pageview_created_time,
CASE WHEN website_pageviews.pageview_url = '/lander-1'THEN 1 ELSE 0 END AS landed_lander_1_page,
CASE WHEN website_pageviews.pageview_url = '/home'THEN 1 ELSE 0 END AS landed_home_page,
CASE WHEN website_pageviews.pageview_url = '/products'THEN 1 ELSE 0 END AS landed_product_page,
CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy'THEN 1 ELSE 0 END AS landed_MRFuzzy_page,
CASE WHEN website_pageviews.pageview_url = '/cart'THEN 1 ELSE 0 END AS landed_Cart_page,
CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS landed_shipping_page,
CASE WHEN website_pageviews.pageview_url = '/billing'THEN 1 ELSE 0 END AS landed_billing_page,
CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order'THEN 1 ELSE 0 END AS landed_thank_page
FROM  website_sessions
LEFT JOIN website_pageviews
ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
AND website_pageviews.pageview_url IN ('/lander-1','/home','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
AND website_sessions.utm_source = 'gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
ORDER BY website_sessions.website_session_id,
website_pageviews.created_at
) AS Page_vew
GROUP BY 1;
SELECT * FROM ID_view;
    
-- STEP 2: aggregate the data to assess funnel performance use the temp table 
DROP TEMPORARY TABLE IF EXISTS segment_conversion_funnels;
CREATE TEMPORARY TABLE segment_conversion_funnels
SELECT 
CASE 
WHEN Lander1_view = 1 THEN 'saw_home_page'
WHEN home_view = 1 THEN 'saw_lander_1_page'
ELSE Null END AS segment,
COUNT(DISTINCT website_session_id) AS total_session,
COUNT( DISTINCT CASE WHEN product_view = 1 THEN website_session_id ELSE NULL END) AS total_product_view,
COUNT( DISTINCT CASE WHEN MRFuzzy_view = 1 THEN website_session_id ELSE NULL END) AS total_MRFuzzy_view,
COUNT( DISTINCT CASE WHEN Cart_view = 1 THEN website_session_id ELSE NULL END) AS total_Cart_view,
COUNT( DISTINCT CASE WHEN shipping_view = 1 THEN website_session_id ELSE NULL END) AS total_shipping_view,
COUNT( DISTINCT CASE WHEN billing_view = 1 THEN website_session_id ELSE NULL END) AS total_billing_view
FROM ID_view
GROUP BY segment;
SELECT * FROM segment_conversion_funnels; -- CHECK TABLE 
-- NOW we can see two different segment with their whole number for each stage: conversion funnels

-- STEP 3: we are going to translate to the conversion rate 
SELECT 
segment,
total_product_view / total_session AS Product_Selected,
total_MRFuzzy_view / total_product_view AS MRFuzzy_Selected,
total_Cart_view / total_MRFuzzy_view AS MRFuzzy_CarIn,
total_shipping_view / total_Cart_view  AS Shipping_Selected,
total_billing_view / total_shipping_view AS pay_billing_placed
FROM segment_conversion_funnels;

-- Result / insight Suggestion for conversion funnels:
		-- now we are be able to see those two of the page of conversion rate for each funnels
        
####################################################################################################################################
-- Project Mamo 8: 
	-- manager want to quantify the impact of our billing test: billing-2, billing to see which of the billing page will cause more order made.
    -- time period: '2012-09-10' to '2012-11-10'
    -- analyze the lift generated from the test (Sep 10 – Nov 10), in terms of revenue per billing page session
    -- pull the number of billing page sessions for the past month to understand monthly impact.
SELECT * FROM website_sessions; -- CHECK DATABASE 
SELECT * FROM website_pageviews;
SELECT * FROM orders;

-- STEP: Because we alreay have the test launced time, so we just need to identify what orders made my which billing page
SELECT 
website_pageviews.website_session_id,
website_pageviews.pageview_url AS Billing_page_type,
orders.order_id,
orders.price_usd
FROM website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at BETWEEN '2012-09-10' AND '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing-2','/billing');
    
    
    
    
    
    



