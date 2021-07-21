    import XCTest
    @testable import SimpleSpreadsheets

    final class SimpleSpreadsheetsTests: XCTestCase {
        func testXLSX() throws {
            
            let table = Table([
                Table.Row([
                    .text("First Cell"),
                    .text("Second Cell"),
                    .integer(123),
                    .double(123.456),
                ]),
                Table.Row([
                    .text("Row 2"),
                ]),
                Table.Row([
                    .text(""),
                    .text("Row 3"),
                ]),
                Table.Row([
                    .text("Integer"),
                    .integer(123456)
                ]),
                Table.Row([
                    .text("Double"),
                    .double(123456)
                ]),
                Table.Row([
                    .text("Double"),
                    .double(123456.789)
                ]),
                Table.Row([
                    .text("Decimal"),
                    .decimal(123456)
                ]),
                Table.Row([
                    .text("Decimal"),
                    .decimal(123456.789)
                ]),
            ])
            
            let csv = table.createCSV()
            let xlsx = try table.createXLSX()
            
            XCTAssertFalse(csv.isEmpty)
            XCTAssertFalse(xlsx.isEmpty)
        }
    }
