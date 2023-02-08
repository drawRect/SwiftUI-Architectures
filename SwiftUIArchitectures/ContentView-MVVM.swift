//
//  ContentView.swift
//  SwiftUIArchitectures
//
//  Created by BKS-GGS on 08/02/23.
//

import SwiftUI



// NEW PRODUCT
// AddProductViewModel(Like every new screen should have their own viewModel)
// AddProductView

/*-----MVVM{MODEL-VIEW-VIEWMODEL} ARCHITECTURE-----*/

@MainActor
class ProductListViewModel: ObservableObject {
    
    @Published var products: [ProductViewModel] = []
    
    func populateProducts() async throws {
        let products = try await Webservice().getAllProducts()
        self.products = products.map(ProductViewModel.init)
    }
}

struct ProductViewModel: Identifiable {
    let product: Product
    
    var id: Int {
        product.id
    }
    
    var title: String {
        product.title
    }
}

struct ContentViewMVVM: View {
    
    @StateObject private var productListVM = ProductListViewModel()
    
    var body: some View {
        List(productListVM.products) { product in
            Text(product.title)
        }.task {
            do {
                try await productListVM.populateProducts()
            } catch {
                print(error)
            }
        }
    }
}


