//
//  ContentView.swift
//  CoreDataEvenTimes
//
//  Created by Parker Rushton on 10/3/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        HStack {
                            Text(item.timestamp!, formatter: itemFormatter)
                            
                            Spacer()
                            
                            if item.hasEvenMinsAndSeconds {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let now = Date.now
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.hasEvenMinsAndSeconds = dateIsAllEven(now)
            try? viewContext.save()
        }
    }
    
    private func dateIsAllEven(_ date: Date) -> Bool {
        let min = Calendar.current.component(.minute, from: date)
        let sec = Calendar.current.component(.second, from: date)
        return min % 2 == 0 && sec % 2 == 0
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
        }
    }
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
