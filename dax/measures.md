# DAX Measures

All measures live in the Power Pivot data model (`Fact_Stays` table). They are layered: `Total Booking Value` is the base, and every other measure builds on it.

| # | Measure | DAX | Purpose |
|---|---|---|---|
| 1 | Total Booking Value | `SUM(Fact_Stays[BookingValue])` | Everything booked, any status (demand) |
| 2 | Revenue | `CALCULATE([Total Booking Value], Fact_Stays[Status] = "Completed")` | Realized revenue |
| 3 | Lost Revenue | `CALCULATE([Total Booking Value], Fact_Stays[Status] IN {"Cancelled", "No-show"})` | Revenue leakage |
| 4 | Pending Revenue | `CALCULATE([Total Booking Value], Fact_Stays[Status] = "Confirmed")` | Future stays not yet completed |
| 5 | Revenue Previous Month | `CALCULATE([Revenue], PREVIOUSMONTH(Dim_Calendar[Date]))` | Time intelligence base |
| 6 | Revenue MoM % | `DIVIDE([Revenue] - [Revenue Previous Month], [Revenue Previous Month])` | Month-over-month growth |
| 7 | Room Nights Sold | `CALCULATE(SUM(Fact_Stays[Nights]), Fact_Stays[Status] = "Completed")` | Volume |
| 8 | ADR | `DIVIDE([Revenue], [Room Nights Sold])` | Average Daily Rate |
| 9 | Rooms Count | `COUNTROWS(Dim_Rooms)` | Inventory |
| 10 | Revenue Per Room | `DIVIDE([Revenue], [Rooms Count])` | Room-category economics |
| 11 | Lost Revenue % | `DIVIDE([Lost Revenue], [Total Booking Value])` | Leakage as a share of everything booked (KPI card) |

**Reconciliation check:** `Revenue + Lost Revenue + Pending Revenue = Total Booking Value` (4,603,250.50 + 487,036.50 + 69,926.00 = 5,160,213.00).

**Model hygiene:** foreign keys in `Fact_Stays` (StayID, GuestID, RoomID) and helper sort columns (AgeRangeOrder, Index_Month_Year) are hidden from client tools.

**Design notes**
- `CALCULATE` changes the filter context by status, so one base measure serves four business definitions.
- `DIVIDE` avoids errors when the previous month is blank (first month of the series).
- Ratios (ADR, Revenue per Room) are measures, not calculated columns, so totals are recalculated as ratios instead of summed.
