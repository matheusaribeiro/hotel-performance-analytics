// Power Query (M) — Fact_Stays
// Exported from the workbook. To refresh, point File.Contents to your local copy of data/Hotel_Database.xlsx.
let
    Source = Excel.Workbook(File.Contents("C:\path\to\data\Hotel_Database.xlsx"), null, true),
    Stays_Sheet = Source{[Item="Stays",Kind="Sheet"]}[Data],
    #"Promoted Headers" = Table.PromoteHeaders(Stays_Sheet, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"StayID", type text}, {"GuestID", type text}, {"RoomID", type text}, {"BookingDate", type date}, {"CheckInDate", type date}, {"CheckOutDate", type date}, {"NumGuests", Int64.Type}, {"Channel", type text}, {"PaymentMethod", type text}, {"Discount", Percentage.Type}, {"Status", type text}}),
    #"Removed Blank Rows" = Table.SelectRows(#"Changed Type", each not List.IsEmpty(List.RemoveMatchingItems(Record.FieldValues(_), {"", null}))),
    #"Merged Queries" = Table.NestedJoin(#"Removed Blank Rows", {"RoomID"}, Dim_Rooms, {"RoomID"}, "Dim_Rooms", JoinKind.LeftOuter),
    #"Expanded Dim_Rooms" = Table.ExpandTableColumn(#"Merged Queries", "Dim_Rooms", {"DailyRate"}, {"DailyRate"}),
    #"Added Custom" = Table.AddColumn(#"Expanded Dim_Rooms", "Nights", each Duration.Days([CheckOutDate] - [CheckInDate])),
    #"Changed Type1" = Table.TransformColumnTypes(#"Added Custom",{{"Nights", Int64.Type}}),
    #"Added Custom1" = Table.AddColumn(#"Changed Type1", "BookingValue", each ([DailyRate] * [Nights]) * (1-[Discount])),
    #"Changed Type2" = Table.TransformColumnTypes(#"Added Custom1",{{"BookingValue", Currency.Type}})
in
    #"Changed Type2"
