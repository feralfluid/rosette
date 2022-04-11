//
//  ContentView.swift
//  rosette
//
//  Created by Ty Poorman on 3/27/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image("rosette")
        }
        .frame( maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
