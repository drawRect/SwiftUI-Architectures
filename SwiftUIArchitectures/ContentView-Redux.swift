//
//  ContentView-Redux.swift
//  SwiftUIArchitectures
//
//  Created by BKS-GGS on 09/02/23.
//

import SwiftUI

/*--------REDUX{REDUX PATTERN-PLAIN VANNILA PATTERN} ARCHITECTURE--------------*/
//Refer: https://www.dotnetcurry.com/reactjs/1356/redux-pattern-tutorial

// Particular reducer updating and managing the products
func productsReducer(_ state: ProductState, _ action: Action) -> ProductState {
    var state = state
    
    switch action {
    case let action as SetProducts:
        state.products = action.products
    default: break
    }
    
    return state
}

// Root Reducer
func appReducer(_ state: AppState, _ action: Action) -> AppState {
    var state = state
    state.products = productsReducer(state.products, action)
    return state
}

func productsMiddleware() -> Middleware<AppState> {
    return { state, action, dispatch in
        
        switch action {
        case let action as FetchProducts:
            Task {
                let products = try await Webservice().getAllProducts()
                dispatch(SetProducts(products: products))
            }
        default: break
        }
        
    }
}

typealias Dispatcher = (Action) -> Void

typealias Reducer<State: ReduxState> = (_ state: State, _ action: Action) -> State
typealias Middleware<StoreState: ReduxState> = (StoreState, Action, @escaping Dispatcher) -> Void

protocol ReduxState { }

struct AppState: ReduxState {
    var products = ProductState()
}

struct ProductState: ReduxState {
    var products = [Product]()
}

protocol Action { }

//These are the events going to dispatch on View
struct FetchProducts: Action {
    let search: String
}
struct SetProducts: Action {
    let products: [Product]
}

// Store is managing the State
class Store<StoreState: ReduxState>: ObservableObject {
    var reducer: Reducer<StoreState>
    @Published var state: StoreState
    var middlewares: [Middleware<StoreState>]
    
    init(reducer: @escaping Reducer<StoreState>,
         state: StoreState,
         middlewares: [Middleware<StoreState>] = []) {
        self.reducer = reducer
        self.state = state
        self.middlewares = middlewares
    }
    
    func dispatch(action: Action) {
        DispatchQueue.main.async {
            self.state = self.reducer(self.state, action)
        }
        
        // run all middlewares
        middlewares.forEach { middleware in
            middleware(state, action, dispatch)
        }
    }
}


struct ContentView_Redux: View {
    @EnvironmentObject var store: Store<AppState>
    
    struct Props {
        let products: [Product]
        let onFetchProducts: () -> Void
    }
    private func map(state: ProductState) -> Props {
        Props(products: state.products, onFetchProducts: {
            store.dispatch(action: FetchProducts(search: ""))
        })
    }

    var body: some View {
        let props = map(state: store.state.products)
        
        List(props.products) { product in
            Text(product.title)
        }.task {
            props.onFetchProducts()
        }
    }
}

struct ContentView_Redux_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let store = Store(reducer: appReducer, state: AppState(), middlewares: [productsMiddleware()])
            
            ContentView_Redux().environmentObject(store)
        }
    }
}
