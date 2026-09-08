import SwiftUI

struct CleanupBookingView: View {
    @EnvironmentObject private var addressStore: ResidentAddressStore
    @State private var showingAddressEditor = false
    @StateObject private var viewModel = CleanupBookingViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Saved address") {
                    if addressStore.hasSavedAddress {
                        Text(addressStore.formattedAddress)
                        Button("Edit address") { showingAddressEditor = true }
                    } else {
                        Button("Add address") { showingAddressEditor = true }
                    }
                }
                Section("Select items") {
                    Text("Paint and asbestos need specialist disposal.")
                    ForEach(CleanupItemType.allCases) { item in
                        Button {
                            if viewModel.selectedItems.contains(item) {
                                viewModel.selectedItems.remove(item)
                            } else {
                                viewModel.selectedItems.insert(item)
                            }
                        } label: {
                            HStack {
                                Text(item.rawValue).foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: viewModel.selectedItems.contains(item) ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(.tint)
                                    .accessibilityHidden(true)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityValue(viewModel.selectedItems.contains(item) ? "Selected" : "Not selected")
                        .accessibilityAddTraits(viewModel.selectedItems.contains(item) ? .isSelected : [])
                    }
                }
                Section {
                    Button("Prepare clean up request") {
                        viewModel.submitBooking(address: addressStore.address)
                    }
                    .disabled(!addressStore.hasSavedAddress)
                } footer: {
                    Text("Demo only. Requests aren’t sent to council.")
                }
                if let confirmation = viewModel.result {
                    Section("Demo reference") {
                        Text(confirmation.reference).font(.headline)
                    }
                }
                if let error = viewModel.errorMessage {
                    Section("What to do next") { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Clean Up")
            .sheet(isPresented: $showingAddressEditor) { AddressEditorView() }
            .onChange(of: addressStore.address) { _, _ in viewModel.clearResult() }
        }
    }
}
