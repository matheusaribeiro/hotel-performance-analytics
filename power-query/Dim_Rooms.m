// Power Query (M) — Dim_Rooms
// Exported from the workbook. To refresh, point File.Contents to your local copy of data/Hotel_Database.xlsx.
let
    Source = Excel.Workbook(File.Contents("C:\path\to\data\Hotel_Database.xlsx"), null, true),
    Rooms_Sheet = Source{[Item="Rooms",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Rooms_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"RoomID", type text}, {"RoomNumber", type text}, {"Floor", type text}, {"Type", type text}, {"View", type text}, {"Capacity", type number}, {"Balcony", type text}, {"DailyRate", Currency.Type}}),
    #"Removed Blank Rows" = Table.SelectRows(#"Changed Type", each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null})))
in
    #"Removed Blank Rows"
