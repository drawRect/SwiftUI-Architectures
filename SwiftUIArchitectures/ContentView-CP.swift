//
//  ContentViewCP.swift
//  SwiftUIArchitectures
//
//  Created by BKS-GGS on 08/02/23.
//

import SwiftUI

/*--------CP{CONTAINER PATTERN} ARCHITECTURE--------------*/

// PRESENTER VIEW
struct ProductListView: View {
    let products: [Product]
    
    var body: some View {
        List(products) { product in
            Text(product.title)
        }
    }
}

// CONTAINER VIEW
struct ContentViewCP: View {
    @State private var products: [Product] = []
    
    var body: some View {
        ProductListView(products: products)
            .task {
            do {
                self.products = try await Webservice().getAllProducts()
            } catch {
                print(error)
            }
        }
    }
}

struct ContentViewCP_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewCP()
    }
}
