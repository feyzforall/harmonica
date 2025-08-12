//
//  ContentView.swift
//  harmonica
//
//  Created by Feyzullah Kodat on 11.08.2025.
//

import SwiftUI

struct ContentView: View {
    @State var selectedHole: Int = 0
    
    var body: some View {
        ZStack {
            Color(red: 24/255, green: 26/255, blue: 31/255)
            
            ZStack {
                TunerDialView(cents: 0, targetNote: "C")
                
                HoleStripView(holeCount: 10, selectedHole: $selectedHole) { hole in
                    selectedHole = hole
                }
                .offset(y: 100)
            }
        }
        .ignoresSafeArea()
    }
    
}

#Preview {
    ContentView()
}

