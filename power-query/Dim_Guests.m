// Power Query (M) — Dim_Guests
// Exported from the workbook. To refresh, point File.Contents to your local copy of data/Hotel_Database.xlsx.
let
    Source = Excel.Workbook(File.Contents("C:\path\to\data\Hotel_Database.xlsx"), null, true),
    Guests_Sheet = Source{[Item="Guests",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Guests_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"BirthDate", type date}, {"Age", Int64.Type}, {"City", type text}, {"State", type text}, {"Region", type text}, {"TripPurpose", type text}, {"Email", type text}, {"SignUpDate", type date}, {"GuestID", type text}, {"GuestName", type text}, {"Gender", type text}}),
    #"Removed Blank Rows" = Table.SelectRows(#"Changed Type", each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
    #"Removed Other Columns" = Table.SelectColumns(#"Removed Blank Rows",{"GuestID", "GuestName", "Gender", "Age", "City", "State", "Region", "TripPurpose"}),
    #"Added Conditional Column" = Table.AddColumn(#"Removed Other Columns", "Age Range", each if [Age] <= 29 then "From 18 to 29 years" else if [Age] <= 39 then "From 30 to 39 years" else if [Age] <= 49 then "From 40 to 49 years" else if [Age] <= 60 then "From 50 to 60 years" else "Above 60 years"),
    #"Added Conditional Column1" = Table.AddColumn(#"Added Conditional Column", "AgeRangeOrder", each if [Age] <= 29 then 1 else if [Age] <= 39 then 2 else if [Age] <= 49 then 3 else if [Age] <= 60 then 4 else 5),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Conditional Column1",{{"AgeRangeOrder", Int64.Type}, {"Age Range", type text}})
in
    #"Changed Type1"
