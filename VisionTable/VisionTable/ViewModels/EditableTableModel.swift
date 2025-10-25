//
//  EditableTableModel.swift
//  VisionTable
//
//  Created by taeni on 10/25/25.
//


/*
Abstract:
Provides a model for an editable table with support for row and column operations.
*/

import SwiftUI
import Vision

/// A model representing an editable table with rows and columns.
@Observable
final class EditableTableModel {
    
    // MARK: - Properties
    
    /// The cells organized in rows and columns.
    private(set) var cells: [[EditableCell]]
    
    /// The number of rows in the table.
    var rowCount: Int { cells.count }
    
    /// The number of columns in the table.
    var columnCount: Int { cells.first?.count ?? 0 }
    
    /// A Boolean value indicating whether the table is empty.
    var isEmpty: Bool { cells.isEmpty }
    
    // MARK: - Initialization
    
    /// Creates an editable table from a Vision table observation.
    ///
    /// - Parameter visionTable: The table detected by Vision framework.
    init(from visionTable: DocumentObservation.Container.Table) {
        self.cells = visionTable.rows.map { row in
            row.map { cell in
                EditableCell(
                    id: UUID(),
                    content: cell.content.text.transcript,
                    originalBoundingRegion: cell.content.boundingRegion
                )
            }
        }
    }
    
    /// Creates an empty table with the specified dimensions.
    ///
    /// - Parameters:
    ///   - rows: The number of rows.
    ///   - columns: The number of columns.
    init(rows: Int, columns: Int) {
        self.cells = (0..<rows).map { _ in
            (0..<columns).map { _ in
                EditableCell(id: UUID(), content: "")
            }
        }
    }
    
    // MARK: - Accessing Cells
    
    /// Accesses the cell at the specified row and column.
    ///
    /// - Parameters:
    ///   - row: The row index.
    ///   - column: The column index.
    /// - Returns: The cell at the specified position, or `nil` if out of bounds.
    func cell(at row: Int, column: Int) -> EditableCell? {
        guard row >= 0, row < rowCount,
              column >= 0, column < columnCount else {
            return nil
        }
        return cells[row][column]
    }
    
    /// Updates the content of a cell at the specified position.
    ///
    /// - Parameters:
    ///   - content: The new content for the cell.
    ///   - row: The row index.
    ///   - column: The column index.
    func updateCell(content: String, at row: Int, column: Int) {
        guard let cell = cell(at: row, column: column) else { return }
        cell.content = content
    }
    
    // MARK: - Row Operations
    
    /// Removes the row at the specified index.
    ///
    /// - Parameter index: The index of the row to remove.
    func removeRow(at index: Int) {
        guard index >= 0, index < rowCount else { return }
        cells.remove(at: index)
    }
    
    /// Moves a row from one position to another.
    ///
    /// - Parameters:
    ///   - source: The index of the row to move.
    ///   - destination: The destination index.
    func moveRow(from source: Int, to destination: Int) {
        guard source >= 0, source < rowCount,
              destination >= 0, destination < rowCount else {
            return
        }
        let row = cells.remove(at: source)
        cells.insert(row, at: destination)
    }
    
    // MARK: - Column Operations
    
    /// Removes the column at the specified index.
    ///
    /// - Parameter index: The index of the column to remove.
    func removeColumn(at index: Int) {
        guard index >= 0, index < columnCount else { return }
        for rowIndex in 0..<rowCount {
            cells[rowIndex].remove(at: index)
        }
    }
    
    /// Moves a column from one position to another.
    ///
    /// - Parameters:
    ///   - source: The index of the column to move.
    ///   - destination: The destination index.
    func moveColumn(from source: Int, to destination: Int) {
        guard source >= 0, source < columnCount,
              destination >= 0, destination < columnCount else {
            return
        }
        
        for rowIndex in 0..<rowCount {
            let cell = cells[rowIndex].remove(at: source)
            cells[rowIndex].insert(cell, at: destination)
        }
    }
    
    // MARK: - Export
    
    /// Exports the table as a tab-separated values string.
    ///
    /// - Returns: A TSV-formatted string.
    func exportToTSV() -> String {
        cells.map { row in
            row.map { $0.content }.joined(separator: "\t")
        }.joined(separator: "\n")
    }
    
    /// Exports the table as a CSV string.
    ///
    /// - Returns: A CSV-formatted string.
    func exportToCSV() -> String {
        cells.map { row in
            row.map { "\"\($0.content)\"" }.joined(separator: ",")
        }.joined(separator: "\n")
    }
}

/// A cell in an editable table.
@Observable
final class EditableCell: Identifiable {
    
    // MARK: - Properties
    
    /// A unique identifier for the cell.
    let id: UUID
    
    /// The text content of the cell.
    var content: String
    
    /// The original bounding region from Vision detection.
    var originalBoundingRegion: NormalizedRegion?
    
    /// A Boolean value indicating whether the cell is selected.
    var isSelected: Bool = false
    
    // MARK: - Initialization
    
    /// Creates a new editable cell.
    ///
    /// - Parameters:
    ///   - id: A unique identifier for the cell.
    ///   - content: The initial text content.
    ///   - originalBoundingRegion: The original bounding region from Vision detection.
    init(
        id: UUID = UUID(),
        content: String,
        originalBoundingRegion: NormalizedRegion? = nil
    ) {
        self.id = id
        self.content = content
        self.originalBoundingRegion = originalBoundingRegion
    }
}
