//
//  TableEditorView.swift
//  VisionTable
//
//  Created by taeni on 10/25/25.
//


/*
Abstract:
Provides an interactive table editor view with support for editing, deleting, and moving rows and columns.
*/

import SwiftUI
import Vision

/// A view that allows users to edit a table interactively.
struct TableEditorView: View {
    
    // MARK: - Properties
    
    @State private var tableModel: EditableTableModel
    @State private var selectedRows: Set<Int> = []
    @State private var selectedColumns: Set<Int> = []
    @State private var editingCell: (row: Int, column: Int)? = nil
    @State private var showExportAlert = false
    @State private var exportMessage = ""
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Initialization
    
    /// Creates a table editor with the specified Vision table.
    ///
    /// - Parameter visionTable: The table detected by Vision framework.
    init(visionTable: DocumentObservation.Container.Table) {
        self._tableModel = State(
            initialValue: EditableTableModel(from: visionTable)
        )
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                editToolbar
                
                Divider()
                
                ScrollView([.horizontal, .vertical]) {
                    tableGrid
                        .padding()
                }
                
                Divider()
                
                bottomActionBar
            }
            .navigationTitle("Edit Table")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            exportTable(format: .tsv)
                        } label: {
                            Label("Export as TSV", systemImage: "doc.text")
                        }
                        
                        Button {
                            exportTable(format: .csv)
                        } label: {
                            Label("Export as CSV", systemImage: "tablecells")
                        }
                        
                        Button {
                            copyToClipboard()
                        } label: {
                            Label("Copy to Clipboard", systemImage: "doc.on.clipboard")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .overlay {
                if showExportAlert {
                    exportAlertView
                }
            }
        }
    }
    
    // MARK: - Edit Toolbar
    
    private var editToolbar: some View {
        HStack(spacing: 16) {
            Group {
                Button {
                    deleteSelectedRows()
                } label: {
                    Label("Delete Rows", systemImage: "trash")
                        .labelStyle(.iconOnly)
                }
                .disabled(selectedRows.isEmpty)
                
                Button {
                    deleteSelectedColumns()
                } label: {
                    Label("Delete Columns", systemImage: "trash")
                        .labelStyle(.iconOnly)
                }
                .disabled(selectedColumns.isEmpty)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            
            Spacer()
            
            Text("\(tableModel.rowCount) × \(tableModel.columnCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Table Grid
    
    private var tableGrid: some View {
        VStack(spacing: 0) {
            columnHeaders
            
            ForEach(0..<tableModel.rowCount, id: \.self) { rowIndex in
                HStack(spacing: 0) {
                    rowHeader(for: rowIndex)
                    
                    ForEach(0..<tableModel.columnCount, id: \.self) { columnIndex in
                        cellView(row: rowIndex, column: columnIndex)
                    }
                }
            }
        }
    }
    
    // MARK: - Column Headers
    
    private var columnHeaders: some View {
        HStack(spacing: 0) {
            Color.clear
                .frame(width: 44, height: 44)
            
            ForEach(0..<tableModel.columnCount, id: \.self) { columnIndex in
                columnHeader(for: columnIndex)
            }
        }
    }
    
    private func columnHeader(for index: Int) -> some View {
        VStack(spacing: 4) {
            Button {
                toggleColumnSelection(index)
            } label: {
                Image(systemName: selectedColumns.contains(index) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedColumns.contains(index) ? .blue : .secondary)
            }
            
            Text("\(index + 1)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 120, height: 44)
        .background(selectedColumns.contains(index) ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .overlay {
            Rectangle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        }
    }
    
    // MARK: - Row Header
    
    private func rowHeader(for index: Int) -> some View {
        HStack(spacing: 4) {
            Button {
                toggleRowSelection(index)
            } label: {
                Image(systemName: selectedRows.contains(index) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedRows.contains(index) ? .blue : .secondary)
            }
            
            Text("\(index + 1)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 44, height: 60)
        .background(selectedRows.contains(index) ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .overlay {
            Rectangle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        }
    }
    
    // MARK: - Cell View
    
    private func cellView(row: Int, column: Int) -> some View {
        Group {
            if let cell = tableModel.cell(at: row, column: column) {
                EditableCellView(
                    cell: cell,
                    isEditing: editingCell?.row == row && editingCell?.column == column,
                    onTap: {
                        editingCell = (row, column)
                    },
                    onEndEditing: {
                        editingCell = nil
                    }
                )
                .frame(width: 120, height: 60)
                .background(
                    backgroundForCell(row: row, column: column)
                )
                .overlay {
                    Rectangle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
            }
        }
    }
    
    private func backgroundForCell(row: Int, column: Int) -> Color {
        if selectedRows.contains(row) || selectedColumns.contains(column) {
            return Color.blue.opacity(0.1)
        }
        return Color(.systemBackground)
    }
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        HStack {
            Button("Clear Selection") {
                clearSelection()
            }
            .disabled(selectedRows.isEmpty && selectedColumns.isEmpty)
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Export Alert
    
    private var exportAlertView: some View {
        VStack {
            Text(exportMessage)
                .font(.callout)
                .padding(20)
                .background(Color.green.clipShape(.buttonBorder))
                .transition(.move(edge: .top))
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .animation(.easeInOut, value: showExportAlert)
    }
    
    // MARK: - Actions
    
    private func toggleRowSelection(_ index: Int) {
        if selectedRows.contains(index) {
            selectedRows.remove(index)
        } else {
            selectedRows.insert(index)
        }
    }
    
    private func toggleColumnSelection(_ index: Int) {
        if selectedColumns.contains(index) {
            selectedColumns.remove(index)
        } else {
            selectedColumns.insert(index)
        }
    }
    
    private func deleteSelectedRows() {
        let sortedRows = selectedRows.sorted(by: >)
        for row in sortedRows {
            tableModel.removeRow(at: row)
        }
        selectedRows.removeAll()
    }
    
    private func deleteSelectedColumns() {
        let sortedColumns = selectedColumns.sorted(by: >)
        for column in sortedColumns {
            tableModel.removeColumn(at: column)
        }
        selectedColumns.removeAll()
    }
    
    private func clearSelection() {
        selectedRows.removeAll()
        selectedColumns.removeAll()
    }
    
    private func exportTable(format: ExportFormat) {
        let content: String
        let formatName: String
        
        switch format {
        case .tsv:
            content = tableModel.exportToTSV()
            formatName = "TSV"
        case .csv:
            content = tableModel.exportToCSV()
            formatName = "CSV"
        }
        
        UIPasteboard.general.string = content
        
        exportMessage = "\(formatName) copied to clipboard!"
        showExportAlert = true
        
        Task {
            try? await Task.sleep(for: .seconds(2))
            showExportAlert = false
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = tableModel.exportToTSV()
        
        exportMessage = "Table copied to clipboard!"
        showExportAlert = true
        
        Task {
            try? await Task.sleep(for: .seconds(2))
            showExportAlert = false
        }
    }
    
    // MARK: - Export Format
    
    enum ExportFormat {
        case tsv
        case csv
    }
}
