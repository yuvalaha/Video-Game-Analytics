# 🎮 Video Game Sales Analytics Dashboard

This Power BI project presents an interactive dashboard that analyzes global video game data across multiple consoles, genres, publishers, and time periods.  
It allows users to explore key insights such as sales trends, console-specific performance, and top games based on critic scores and revenue.

---

## 📊 Features

### 🧩 Main Dashboard (`Main Dashboard.png`)
- **Genre Distribution** – Visualizes the number of games per genre.
- **Sales by Year and Region** – Tracks global sales by region (North America, Japan, Europe/Africa, Rest of World).
- **Console Market Share** – Donut chart showing total sales by gaming console.
- **Top Publishers** – Highlights publishers with the highest number of released games.
- **Console Selector** – Clickable grid for selecting a console and navigating to detailed insights.

### 🎮 Console Details View (`Console Dashboard.png`)
Upon selecting a console (e.g. PS4), users are taken to a dedicated report page showing:
- **Sales Over Time by Region**
- **Top 5 Best-Selling Games**
- **Average Critic Score by Publisher**
- **KPIs**:
  - Total Game Sales (in millions)
  - Number of Genres represented

---

## 🧰 Technologies Used

- **Power BI Desktop**
- **DAX** for dynamic calculations
- **SQL (optional)** – for preprocessing the raw dataset
- **Public Video Game Dataset** – over 64,000 titles included

---

## 📁 Files Included

| File                        | Description                              |
|-----------------------------|------------------------------------------|
| `video_game_dashboard.pbix`| Main Power BI report                     |
| `game_data_query.sql`      | SQL script used to load/prepare data     |
| `Main Dashboard.png`       | Screenshot of the main overview page     |
| `Console Dashboard.png`    | Screenshot of the console-specific page  |

---

## 📸 Screenshots

### 🔷 Main Dashboard
![Main Dashboard](Main%20Dashboard.png)

### 🔷 Console Details
![Console Dashboard](Console%20Dashboard.png)

---

## 🚀 How to Use

1. Download and open the `.pbix` file in Power BI Desktop.
2. Interact with slicers or click on a console tile to drill into more detailed views.
3. (Optional) Connect to SQL Server for live or updated data sources.

---

## 📌 Notes

- All sales figures are in **millions**.
- The dashboard supports interactive filtering and dynamic drill-through views.
- Designed for both business stakeholders and data enthusiasts.

---

## 📬 Contact

Feel free to fork, clone, or reuse this project.  
If you enjoyed it or learned from it, ⭐ give it a star!
