# VoltEdge Electronics: 2020 Sales Performance Analysis
## Project Background
VoltEdge Electronics, a global electronics retailer, faced a challenging year in 2020 due to the COVID-19 pandemic. Lockdowns, economic downturns, and shifts in consumer behavior significantly impacted sales performance. As a data analyst, my role is to evaluate the company’s sales trends, diagnose key problems, uncover growth opportunities, and provide strategic recommendations for 2020.
## Data Structure Overview
The analysis is based on data from five key tables:

1. **Sales**: Contains order details such as order number, product information, transaction dates, customer and store identifiers, and sales metrics.

2. **Customers**: Provides demographic and geographic details of customers, including gender, location, and birthdate.

3. **Products**: Lists product attributes such as name, brand, category, pricing, and cost details.

4. **Stores**: Contains store-specific information, including location, floor area, and store opening date.

5. **Exchange Rates**: Tracks currency exchange rates relative to the US dollar over time.




*Figure 1: Entity-Relationship Diagram (ERD) of the schema.*

![Schema](assets/schema.drawio.png)



## Executive Summary
VoltEdge Electronics suffered a **50% decline in total revenue**, dropping from **$19.8M in 2019 to $9.2M in 2020**. Profitability and order volume declined at the same rate. The peak sales month in **December 2020 reached only $650K**, a quarter of its previous year's peak.

- **Sales Trends**: The drop in revenue started in the second half of 2020, coinciding with government restrictions and declining consumer income.

- **Product Category Analysis**: **Computers ($3.7M), Cell Phones ($1.3M), and Home Appliances ($1.2M)** were the **top-performing categories**, while **Games & Toys, Audio, and Music/Movies/Audiobooks** were the **lowest-selling**.

- **Retail Store Performance**: Large stores generated **higher total sales**, but were **less efficient**, as measured by **revenue per square meter (RPSM)**. The **bottom-performing 1/3 of stores, which account for 40% of total retail space, have significantly lower efficiency**.

- **E-Commerce Growth**: Online sales **grew steadily, reaching 22.3% of total revenue** in 2020, but remain underdeveloped. However, **delivery efficiency improved significantly**, reducing the **average delivery time from 7.3 days (2016) to 4 days (2020)**.


A two-page interactive dashboard tracking sales performance is available <a href="https://public.tableau.com/app/profile/dung.duong.huynh5892/viz/GlobalElectronicsRetailerSalesDashboard/SalesPerformanceOverview" target="_blank">here</a>


## Insights Deep Dive
### i. Sales performance Overview
- **Annual Revenue Decline**: 50% drop **from $19.8M (2019) to $9.2M (2020)**.

- **Gross Profit Decline**: Declined **from $10.7M to $5.45M**.

- **Order Volume Decline**: Fell **from 9,083 orders in 2019 to 4,635 orders in 2020**.

- **Seasonality Trends**: Sales patterns remained consistent, with **peaks in February and December**, and a **trough in April**, although absolute figures were significantly lower than the previous two years.

Figure 2: Monthly sales by year: 2018-2020
![Monthly Sales by Year_ 2018-2020](https://github.com/user-attachments/assets/90021a37-8c75-4bb2-b63d-6f6a155f38ec)

  
