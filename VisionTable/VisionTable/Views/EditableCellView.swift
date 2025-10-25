//
//  EditableCellView.swift
//  VisionTable
//
//  Created by taeni on 10/25/25.
//


/*
Abstract:
Provides a view component for displaying and editing individual table cells.
*/

import SwiftUI

/// A view that displays an editable cell in the table.
struct EditableCellView: View {
    
    // MARK: - Properties
    
    /// The cell to display and edit.
    @Bindable var cell: EditableCell
    
    /// A Boolean value indicating whether the cell is currently being edited.
    let isEditing: Bool
    
    /// A closure called when the cell is tapped.
    let onTap: () -> Void
    
    /// A closure called when editing ends.
    let onEndEditing: () -> Void
    
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if isEditing {
                editingView
            } else {
                displayView
            }
        }
    }
    
    // MARK: - Editing View
    
    private var editingView: some View {
        TextField("", text: $cell.content, axis: .vertical)
            .textFieldStyle(.plain)
            .font(.system(size: 14))
            .padding(8)
            .focused($isFocused)
            .onAppear {
                isFocused = true
            }
            .onSubmit {
                onEndEditing()
            }
    }
    
    // MARK: - Display View
    
    private var displayView: some View {
        Text(cell.content)
            .font(.system(size: 14))
            .lineLimit(3)
            .multilineTextAlignment(.leading)
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture {
                onTap()
            }
    }
}

#Preview {
    EditableCellView(
        cell: EditableCell(content: "Sample Text"),
        isEditing: false,
        onTap: {},
        onEndEditing: {}
    )
    .frame(width: 120, height: 60)
    .border(Color.gray.opacity(0.3))
}