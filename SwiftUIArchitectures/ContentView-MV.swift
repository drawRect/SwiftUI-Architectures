//
//  ContentView-MV.swift
//  SwiftUIArchitectures
//
//  Created by BKS-GGS on 08/02/23.
//

import SwiftUI

/*--------MV{MODEL VIEW} ARCHITECTURE--------------*/

@MainActor
class StoreModel: ObservableObject {
    
    @Published var products: [Product] = []
//    @Published var reviews: [Review] = []
    @Published var categories: [Category] = []
    
    func populateProducts() async throws {
        self.products = try await Webservice().getAllProducts()
    }
    
    func addProduct(_ product: Product) async throws {
        // call webservice to add product
    }
}

struct ContentViewMV: View {
    //@StateObject also fine!
    @EnvironmentObject private var storeModel: StoreModel
    var body: some View {
        List(storeModel.products) { product in
            Text(product.title)
        }.task {
            do {
                try await storeModel.populateProducts()
            } catch {
                print(error)
            }
        }
    }
}

struct ContentViewMV_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewMV()
            .environmentObject(StoreModel())
    }
}
