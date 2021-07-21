//
//  Table.swift
//  
//
//  Created by Florian Reinhart on 16.07.21.
//

import Foundation
import ZIPFoundation

public struct Table: ExpressibleByArrayLiteral {
    
    public var rows: [Row]
    
    public struct Row: ExpressibleByArrayLiteral {
        public var cells: [Cell]
        
        public init(_ cells: [Table.Cell]) {
            self.cells = cells
        }
        
        public init(arrayLiteral elements: Table.Cell...) {
            self.init(elements)
        }
    }
    
    public enum Cell {
        case empty
        case text(String)
        case integer(Int, formatter: NumberFormatter? = nil)
        case double(Double, formatter: NumberFormatter? = nil)
        case decimal(Decimal, formatter: NumberFormatter? = nil)
    }
    
    public init(_ rows: [Table.Row]) {
        self.rows = rows
    }
    
    public init() {
        self.init([])
    }
    
    public init(arrayLiteral elements: Table.Row...) {
        self.init(elements)
    }
}

public extension Table.Row {

    init(_ strings: [String]) {
        self.init(strings.map({ .text($0) }))
    }

    init(_ integers: [Int]) {
        self.init(integers.map({ .integer($0) }))
    }

    init(_ doubles: [Double]) {
        self.init(doubles.map({ .double($0) }))
    }

    init(_ decimals: [Decimal]) {
        self.init(decimals.map({ .decimal($0) }))
    }
}

public extension Table {
    
    func createCSV() -> Data {
        var csv = Data()
        
        for row in rows {
            
            var rowString = row.cells.map({ cell -> String in
                switch cell {
                case .empty:
                    return ""
                case .text(var text):
                    if text.contains("\"") {
                        text = text.replacingOccurrences(of: "\"", with: "\"\"")
                        return "\"\(text)\""
                    } else {
                        return text
                    }
                case .integer(let number, let formatter):
                    return formatter.flatMap { $0.string(from: NSNumber(value: number)) } ?? "\(number)"
                case .double(let number, let formatter):
                    return formatter.flatMap { $0.string(from: NSNumber(value: number)) } ?? "\(number)"
                case .decimal(let number, let formatter):
                    return formatter.flatMap { $0.string(from: NSDecimalNumber(decimal: number)) } ?? "\(number)"
                }
            })
            .joined(separator: ",")
            
            rowString.append("\n")
            
            csv.append(contentsOf: rowString.utf8)
        }
        
        return csv
    }
}

public extension Table {
    
    func createXLSX() throws -> Data {
        let archive = Archive(accessMode: .create)!
        
        let now = Date()
        try XLSXTemplateFile.addAllTemplateFiles(to: archive, modificationDate: now)
        
        let sheetData = createSheetXML()
        try archive.addEntry(with: "xl/worksheets/sheet1.xml",
                         type: .file,
                         uncompressedSize: UInt32(sheetData.count),
                         modificationDate: now,
                         compressionMethod: .deflate,
                         provider: { index, count in
                            sheetData.subdata(in: index ..< index + count)
                         })
        
        return archive.data!
    }
    
    func createSheetXML() -> Data {
        var xml = Data()
        
        xml.append(contentsOf: """
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <worksheet xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
            <sheetData>
            """.utf8)
     
        for row in rows {
            xml.append(contentsOf: "<row>".utf8)
            for cell in row.cells {
                switch cell {
                case .empty:
                    xml.append(contentsOf: "<c></c>".utf8)
                case .text(let text):
                    xml.append(contentsOf: """
                        <c t="inlineStr">
                            <is><t>\(text)</t></is>
                        </c>
                        """.utf8)
                case .integer(let number, let formatter):
                    let formatted = formatter.flatMap { $0.string(from: NSNumber(value: number)) } ?? "\(number)"
                    xml.append(contentsOf: """
                        <c t="n">
                            <v>\(formatted)</v>
                        </c>
                        """.utf8)
                case .double(let number, let formatter):
                    let formatted = formatter.flatMap { $0.string(from: NSNumber(value: number)) } ?? "\(number)"
                    xml.append(contentsOf: """
                        <c t="n">
                            <v>\(formatted)</v>
                        </c>
                        """.utf8)
                case .decimal(let number, let formatter):
                    let formatted = formatter.flatMap { $0.string(from: NSDecimalNumber(decimal: number)) } ?? "\(number)"
                    xml.append(contentsOf: """
                        <c t="n">
                            <v>\(formatted)</v>
                        </c>
                        """.utf8)
                }
            }
            xml.append(contentsOf: "</row>".utf8)
        }
        
        xml.append(contentsOf: """
            </sheetData>
            </worksheet>
            """.utf8)
        
        return xml
    }
}
