import SwiftUI

struct ScanItemView: View {
    @StateObject private var viewModel = ScanItemViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Item name", text: $viewModel.itemName)
                    Button("Check disposal guidance") { viewModel.checkDisposalGuidance() }
                } header: {
                    Text("Disposal lookup")
                }
                Section("Try these items") {
                    Text("Cardboard box, Plastic bag, Grass, Battery")
                }
                if let result = viewModel.result {
                    Section("Disposal guidance") {
                        Text(result.itemName).font(.headline)
                        Text(result.disposalStream.rawValue)
                        Text(result.instruction)
                    }
                }
                if let error = viewModel.errorMessage {
                    Section("What to do next") { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Check an Item")
        }
    }
}
