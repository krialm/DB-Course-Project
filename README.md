# PostgreSQL Database Project Report

## 1. Introduction
This report presents the design and implementation of a relational database system for an online store using PostgreSQL. The goal is to demonstrate a solid understanding of database concepts such as normalization, relationships, constraints, and transactions while avoiding database-specific features like stored procedures that are unique to other systems. PostgreSQL was chosen because of its robust feature set, support for advanced SQL, and ACID compliance.

## 2. Database Design

### 2.1 Overview
The database models the core entities required by a small online store. It stores details about customers, suppliers, product categories, individual products, orders, and the specific items within each order. Careful normalization ensures there is no redundant data while still allowing efficient retrieval of information.

### 2.2 Tables and Keys
There are six main tables in this design:
1. **Customers** – holds customer contact and address information.  
2. **Categories** – defines product categories.  
3. **Suppliers** – stores supplier details.  
4. **Products** – contains product names, prices, and inventory details.  
5. **Orders** – records orders placed by customers.  
6. **Order_Details** – a junction table implementing the many-to-many relationship between orders and products.

Each table uses a primary key implemented with `GENERATED ALWAYS AS IDENTITY` so PostgreSQL automatically assigns a unique identifier. Foreign key constraints enforce referential integrity.

### 2.3 Relationships
- **One-to-many:** Customers → Orders, Categories → Products, Suppliers → Products  
- **Many-to-many:** Orders ↔ Products via Order_Details  

Indexes are defined on several columns to optimize performance.

### 2.4 Data Types
- **INT** for identifiers  
- **VARCHAR(n)** for text  
- **NUMERIC(p,s)** for monetary values  
- **TIMESTAMP** for date/time fields  

### 2.5 Table Schemas

#### Customers
| Column | Data Type | Description |
|--------|-----------|-------------|
| customer_id | INT (identity) | Primary key |
| first_name | VARCHAR(50) | Given name |
| last_name | VARCHAR(50) | Family name |
| email | VARCHAR(100) | Unique email |
| phone | VARCHAR(20) | Contact number |
| address | VARCHAR(200) | Street address |
| city | VARCHAR(50) | City |
| country | VARCHAR(50) | Country |

#### Categories
| Column | Data Type | Description |
|--------|-----------|-------------|
| category_id | INT (identity) | Primary key |
| category_name | VARCHAR(50) | Category name |
| description | VARCHAR(255) | Optional description |

#### Suppliers
| Column | Data Type | Description |
|--------|-----------|-------------|
| supplier_id | INT (identity) | Primary key |
| supplier_name | VARCHAR(100) | Supplier name |
| contact_name | VARCHAR(100) | Contact person |
| phone | VARCHAR(20) | Phone number |
| city | VARCHAR(50) | Supplier city |
| country | VARCHAR(50) | Supplier country |

#### Products
| Column | Data Type | Description |
|--------|-----------|-------------|
| product_id | INT (identity) | Primary key |
| product_name | VARCHAR(100) | Product name |
| supplier_id | INT | FK to Suppliers |
| category_id | INT | FK to Categories |
| unit_price | NUMERIC(10,2) | Unit price |
| units_in_stock | INT | Stock quantity |
| units_on_order | INT | Quantity on order |

#### Orders
| Column | Data Type | Description |
|--------|-----------|-------------|
| order_id | INT (identity) | Primary key |
| customer_id | INT | FK to Customers |
| order_date | TIMESTAMP | Order date |
| required_date | TIMESTAMP | Required by customer |
| shipped_date | TIMESTAMP | Shipment date |
| freight | NUMERIC(10,2) | Shipping cost |
| order_status | VARCHAR(20) | Status |

#### Order_Details
| Column | Data Type | Description |
|--------|-----------|-------------|
| order_detail_id | INT (identity) | Primary key |
| order_id | INT | FK to Orders |
| product_id | INT | FK to Products |
| quantity | INT | Quantity ordered |
| unit_price | NUMERIC(10,2) | Price per unit |
| discount | NUMERIC(4,2) | Discount (0–1) |

### 2.6 Entity–Relationship Diagram
Insert ERD image here.

---

## 3. Data Manipulation and Queries
Insert, update, delete operations and SELECT statements demonstrating aggregates, pagination, grouping, and joins were executed. SQL scripts are provided separately.

---

## 4. Views, Functions, Triggers, and Transactions
A view summarizes order information, functions encapsulate reusable logic, and a trigger updates inventory automatically. A manual transaction demonstrates atomic updates and ACID-compliant behavior.

---

## 5. Conclusion
This project demonstrates the complete lifecycle of designing and implementing a relational database using PostgreSQL. Including the table schemas provides a clear view of structure. The resulting system forms a solid foundation for an online store and highlights the practical use of PostgreSQL.

