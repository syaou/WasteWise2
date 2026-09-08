import SwiftUI

struct CollectionCalendarView: View {
    @EnvironmentObject private var addressStore: ResidentAddressStore
    @State private var showingAddressEditor = false
    @EnvironmentObject private var viewModel: CollectionScheduleViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Residential address") {
                    if addressStore.hasSavedAddress {
                        Text(addressStore.formattedAddress)
                        Button("Edit address") { showingAddressEditor = true }
                    } else {
                        Button("Add address") { showingAddressEditor = true }
                    }
                    Button("Check collection day") {
                        viewModel.findCollectionDates(address: addressStore.address)
                    }
                    .disabled(!addressStore.hasSavedAddress || viewModel.isLoading)
                }
                if viewModel.isLoading {
                    ProgressView("Checking collection schedule…")
                }
                if let schedule = viewModel.result {
                    Section {
                        if let day = schedule.collectionDay {
                            LabeledContent("Collection day", value: day)
                        }
                        if let area = schedule.recyclingArea {
                            LabeledContent("Recycling area", value: area)
                        }
                    } header: {
                        Text("Collection schedule")
                    }
                }
                if let error = viewModel.errorMessage {
                    Section("What to do next") { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Collections")
            .sheet(isPresented: $showingAddressEditor) { AddressEditorView() }
        }
    }
}
