//
//  XLSXTemplateFile.swift
//  
//
//  Created by Florian Reinhart on 16.07.21.
//

import Foundation
import ZIPFoundation

struct XLSXTemplateFile {
    let path: String
    let data: Data
    
    static func addAllTemplateFiles(to archive: Archive, modificationDate: Date) throws {
        try templateFiles.forEach { try $0.add(to: archive, modificationDate: modificationDate) }
    }
    
    func add(to archive: Archive, modificationDate: Date) throws {
        try archive.addEntry(with: path,
                         type: .file,
                         uncompressedSize: UInt32(data.count),
                         modificationDate: modificationDate,
                         compressionMethod: .deflate) { index, count in
            data.subdata(in: index ..< index + count)
        }
    }
    
    static let templateFiles = [
        XLSXTemplateFile(path: "_rels/.rels",
                         data: Data("""
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
            <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
        </Relationships>
        """.utf8)),
        
        XLSXTemplateFile(path: "[Content_Types].xml",
                         data: Data("""
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
            <Default Extension="xml" ContentType="application/xml"/>
            <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
            <Override ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml" PartName="/xl/workbook.xml"/>
            <Override ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml" PartName="/xl/worksheets/sheet1.xml"/>
        </Types>
        """.utf8)),
        
        XLSXTemplateFile(path: "xl/_rels/workbook.xml.rels",
                         data: Data("""
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
            <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
        </Relationships>
        """.utf8)),
        XLSXTemplateFile(path: "xl/workbook.xml",
                         data: Data("""
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <workbook xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
            <sheets>
                <sheet name="Sheet 1" sheetId="1" r:id="rId1"/>
            </sheets>
        </workbook>
        """.utf8))
    ]
}
