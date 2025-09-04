Drop table if exists orders;


CREATE TABLE orders (
    order_id VARCHAR(20) NOT NULL,
    order_date DATE,
    product_id VARCHAR(20),
    category VARCHAR(20),
	sales DECIMAL(10,4),
	profit DECIMAL(10,4),
    
    PRIMARY KEY (order_id, product_id)
);

Select * from orders