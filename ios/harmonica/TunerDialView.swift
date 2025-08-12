//
//  TunerDialView.swift
//  harmonica
//
//  Created by Feyzullah Kodat on 11.08.2025.
//

import SwiftUI

// MARK: - TunerDialView
struct TunerDialView: View {
    /// Dışarıdan gelen cent değeri (-50...+50 arası hedeflenir)
    let cents: Double
    /// Ortada gösterilecek büyük nota (örn. "C", "E5")
    let targetNote: String
    
  
    // Animasyon için hafif yumuşatma
    @State private var displayedCents: Double = 0
    
    // Yay genişliği (derece)
    private let sweep: Double = 120 // -60 ... +60
    private let ema: Double = 0.25  // smoothing
    private let deadband: Double = 1.5
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Skala (Canvas ile)
                ScaleLayer(sweep: sweep)
                
                Text(targetNote)
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.blue)
                    .offset(y: -100)
                
                /*
                 // İğne (dar dikey çubuk)
                 Needle(length: r - 22, thickness: 6, cap: 8)
                     .fill(accent.opacity(0.95))
                     .rotationEffect(needleAngle(for: displayedCents))
                     .animation(.spring(response: 0.28, dampingFraction: 0.88), value: displayedCents)
                 */

            }
            .onAppear { displayedCents = clamp(cents) }
            .onChange(of: cents) { new in
                let clamped = clamp(new)
                let snapped = abs(clamped) < deadband ? 0 : clamped
                displayedCents = displayedCents*(1-ema) + snapped*ema
            }
        }
    }
    
    // -50 → -sweep/2, +50 → +sweep/2; 0 cent tepeye gelsin diye -90° offset
    private func needleAngle(for c: Double) -> Angle {
        .degrees((c / 50.0) * (sweep/2.0) - 90)
    }
    private func clamp(_ v: Double) -> Double { max(-50, min(50, v)) }
}

// MARK: - Skala (tikler ve -10 / 0 / +10)
private struct ScaleLayer: View {
    let sweep: Double
    
    var body: some View {
        Canvas { ctx, size in
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let rOuter = min(size.width, size.height) / 2
            let rShort = rOuter - 15
            let rLong  = rOuter - 25
            
            for c in stride(from: -50, through: 50, by: 10) {
                let isLong = c == 0
                let angleDeg = (Double(c)/50.0) * (sweep/2.0) - 90
                let angleRad = angleDeg * .pi / 180
                
                // Noktaları hesapla
                let p1 = CGPoint(
                    x: center.x + rOuter * CGFloat(cos(angleRad)),
                    y: center.y + rOuter * CGFloat(sin(angleRad))
                )
                let p2 = CGPoint(
                    x: center.x + (isLong ? rLong : rShort) * CGFloat(cos(angleRad)),
                    y: center.y + (isLong ? rLong : rShort) * CGFloat(sin(angleRad))
                )
                
                // Path çiz
                if abs(c) != 50 {
                    var path = Path()
                    path.move(to: p1)
                    path.addLine(to: p2)
                    
                    let isCenter = (c == 0)
                    let lineColor: Color = isCenter ? .primary : .secondary
                    let lineOpacity: Double = isCenter ? 0.95 : 0.6
                    let lineWidth: CGFloat = isCenter ? 3.0 : (isLong ? 2.0 : 2.0)
                    
                    ctx.stroke(path, with: .color(lineColor.opacity(lineOpacity)), lineWidth: lineWidth)
                }
                // Etiketler
                if c == -50 || c == 50 {
                    let label = c > 0 ? "+\(c)" : "\(c)"
                    let text = Text(label)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))

                    
                    let labelRadius = rLong
                    let labelPoint = CGPoint(
                        x: center.x + labelRadius * CGFloat(cos(angleRad)),
                        y: center.y + labelRadius * CGFloat(sin(angleRad))
                    )
                    
                    ctx.draw(text, at: labelPoint, anchor: .center)
                }
            }
        }
    }
}


// MARK: - İğne şekli
private struct Needle: Shape {
    let length: CGFloat
    let thickness: CGFloat
    let cap: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        // merkezden yukarı doğru uzanan kapsül
        let x = rect.midX
        let y = rect.midY
        let frame = CGRect(x: x - thickness/2, y: y - length, width: thickness, height: length)
        let r = min(cap, thickness/2)
        p.addPath(Path(roundedRect: frame, cornerRadius: r))
        return p
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(red: 24/255, green: 26/255, blue: 31/255)
        VStack {
            // görseldeki gibi merkez 0 cent
            TunerDialView(cents: 0, targetNote: "C")
                .padding()
        }
    }
    .ignoresSafeArea(.all)
}
