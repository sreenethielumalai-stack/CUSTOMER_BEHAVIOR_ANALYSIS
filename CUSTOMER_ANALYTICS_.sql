CREATE TABLE CUSTOMER_SHOPPING_CLEANED (
    CUSTOMER_ID NUMBER(10),
    AGE NUMBER(3),
    GENDER VARCHAR2(20),
    ITEM_PURCHASED VARCHAR2(100),
    CATEGORY VARCHAR2(50),
    PURCHASE_AMOUNT NUMBER(10,2),
    LOCATION VARCHAR2(100),
    ITEM_SIZE VARCHAR2(10),
    COLOR VARCHAR2(50),
    SEASON VARCHAR2(20),
    REVIEW_RATING NUMBER(3,2),
    SUBSCRIPTION_STATUS VARCHAR2(10),
    SHIPPING_TYPE VARCHAR2(50),
    DISCOUNT_APPLIED VARCHAR2(10),
    PREVIOUS_PURCHASES NUMBER(5),
    PAYMENT_METHOD VARCHAR2(50),
    FREQUENCY_OF_PURCHASES VARCHAR2(50),
    AGE_GROUP VARCHAR2(30),
    PURCHASE_FREQUENCY_DAYS NUMBER(5)
);


SELECT table_name from user_tables where table_name='coustomer_shopping_cleaned';



SELECT * FROM  customer_shopping_cleaned;

#===================================what is the total revenue grnetrated by male and female customers?===========================

select gender,sum(purchase_amount) as revenue from customer_shopping_cleaned
group by gender;

#================================which cus used discount but still spent more than avg purchase amount?=============================

select customer_id ,purchase_amount,discount_applied from customer_shopping_cleaned 
where discount_applied='Yes' and purchase_amount >(select avg(purchase_amount) from customer_shopping_cleaned);

#select distinct(discount_applied) from customer_shopping_cleaned ;
#select avg(purchase_amount) from customer_shopping_cleaned ;

# =======================================which are the top 5 product with highest avg review rating?====================================
select item_purchased,review_rating
from customer_shopping_cleaned 
where review_rating >= 3.75
and ROWNUM <= 5;

#select avg(review_rating) from customer_shopping_cleaned;

#       compare the avg purchase amount btw standard and express shipping

#"""select shipping_type,avg(purchase_amount)
#from customer_shopping_cleaned
#group by shipping_type;  ==== this is for all mode of shipping======"""

select shipping_type,round(avg(purchase_amount))
from customer_shopping_cleaned
where shipping_type in('Express' , 'Standard')
group by shipping_type;

#==============================   do subscribed cus spend more ? compare avg spenf and total revenue btw subscriber and non subscribers======================


select sum(purchase_amount),round(avg(purchase_amount)),subscription_status
from customer_shopping_cleaned
group by subscription_status;


#===============================which 5 product have highest percentage of purchase withd discount applied=====================================
SELECT *
FROM (
    SELECT
        item_purchased,
        ROUND(
            100 * SUM(CASE
                WHEN discount_applied = 'Yes' THEN 1
                ELSE 0
            END) / COUNT(*), 2
        ) AS discount_rate
    FROM customer_shopping_cleaned
    GROUP BY item_purchased
    ORDER BY discount_rate DESC
)
WHERE ROWNUM <= 5;
#=======================================segment customer into new ,returning and loyal based on their total number of previous purchase,show the count of each segment==================
SELECT
    customer_id,
    COUNT(*) AS total_purchases,
    CASE
        WHEN COUNT(*) = 1 THEN 'New'
        WHEN COUNT(*) BETWEEN 2 AND 4 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_segment
FROM customer_shopping_cleaned
GROUP BY customer_id;
#=========================================top 3 pruduct in each categoryy================================
SELECT *
FROM (
    SELECT
        category,
        item_purchased,
        COUNT(*) AS total_purchases,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM customer_shopping_cleaned
    GROUP BY category, item_purchased
)
WHERE rnk <= 3
ORDER BY category, rnk;

=================================================are customer who are repeat buyers(more than 5previous purchase) also likely to subscribs?==============

SELECT
    CASE
        WHEN total_purchases > 5 THEN 'Repeat Buyers'
        ELSE 'Other Customers'
    END AS customer_type,
    subscription_status,
    COUNT(*) AS customer_count
FROM (
    SELECT
        customer_id,
        COUNT(*) AS total_purchases,
        MAX(subscription_status) AS subscription_status
    FROM customer_shopping_cleaned
    GROUP BY customer_id
)
GROUP BY
    CASE
        WHEN total_purchases > 5 THEN 'Repeat Buyers'
        ELSE 'Other Customers'
    END,
    subscription_status
ORDER BY customer_type, subscription_status;
 

#===========================what is the revenu contributed by each age grp===============================
SELECT age_group,
sum(purchase_amount) as total_revenue
from customer_shopping_cleaned
group by age_group
ORDER BY total_revenue DESC;
