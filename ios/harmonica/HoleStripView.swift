//
//  HoleStripView.swift
//  harmonica
//
//  Created by Feyzullah Kodat on 11.08.2025.
//

import SwiftUI

struct HoleStripView: View {
    let holeCount: Int
    @Binding var selectedHole: Int
    var onSelect: ((Int) -> Void)?
    
    @Namespace private var ringNS
    private let ringSize: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<holeCount, id: \.self) { hole in
                let isSelected = hole == selectedHole
                
                ZStack {
                    // Mavi Çember
                    if isSelected {
                        Circle()
                            .stroke(Color.blue, lineWidth: 5)
                            .matchedGeometryEffect(id: "ring", in: ringNS)
                    }
                    
                    // Sayı
                    Text("\(hole + 1)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(isSelected ? Color.blue : Color.white)
                    
                }
                .frame(width: ringSize, height: ringSize)
                .onTapGesture {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                        selectedHole = hole
                        onSelect?(hole)
                    }
                }
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.gray, lineWidth: 3)
        )
    }
}


#Preview {
    HoleStripView(holeCount: 10, selectedHole: .constant(3))
}
