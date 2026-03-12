//
//  AddTaskView.swift
//  PriorityHub
//
//  Created by Sapana Bhorania on 3/11/26.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button {
            dismiss()
        } label: {
            Text("Add Task")
        }
    }
}

#Preview {
    AddTaskView()
}
