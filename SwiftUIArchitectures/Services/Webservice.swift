//
//  Webservice.swift
//  SwiftUIArchitectures
//
//  Created by BKS-GGS on 08/02/23.
//

import Foundation

class Webservice {
    
    func getAllProducts() async throws -> [Product] {
        
        guard let url = URL(string: "https://api.escuelajs.co/api/v1/products") else {
            fatalError("URL is incorrect.")
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return try JSONDecoder().decode([Product].self, from: data)
    }
}
