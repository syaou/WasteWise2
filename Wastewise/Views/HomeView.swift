import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var addressStore: ResidentAddressStore
    @State private var confirmingRemoval = false
    @State private var showingAddressEditor = false

    var body: some View {
        NavigationStack {
            List {
                Section("Welcome to WasteWise") {
                    Text("Check what goes where, find your bin day and plan a clean up.")
                }
                Section {
                    Button(addressStore.hasSavedAddress ? "Edit address" : "Add address") {
                        showingAddressEditor = true
                    }
                }
                Section("Saved address") {
                    if addressStore.hasSavedAddress {
                        Text(addressStore.formattedAddress)
                        Button("Remove address", role: .destructive) { confirmingRemoval = true }
                            .font(.footnote)
                    } else {
                        Text("Add your address to get started.")
                    }
                }
            }
            .navigationTitle("WasteWise")
            .sheet(isPresented: $showingAddressEditor) { AddressEditorView() }
            .confirmationDialog("Remove your saved address?", isPresented: $confirmingRemoval, titleVisibility: .visible) {
                Button("Remove address", role: .destructive) { addressStore.clear() }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}
