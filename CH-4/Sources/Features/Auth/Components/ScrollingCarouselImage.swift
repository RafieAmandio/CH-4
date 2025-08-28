import SwiftUI

/// A tiltable, endlessly left-scrolling banner.
/// Works great for a wide image like your "carousel".
struct ScrollingCarouselImage: View {
    let name: String
    var height: CGFloat = 130
    var angle: Double = -12          // <— adjust tilt here (in degrees)
    var pointsPerSecond: CGFloat = 40 // <— scrolling speed

    var body: some View {
        GeometryReader { geo in
            let w = max(geo.size.width, 1)
            TimelineView(.animation) { ctx in
                // Move left at a constant speed and wrap every width.
                let t = ctx.date.timeIntervalSinceReferenceDate
                let travel = CGFloat(t) * pointsPerSecond
                let x = -travel.remainder(dividingBy: w)

                VStack(spacing: 15) {
                    VStack(spacing: 0) {
                        Image(name)
                            .frame(width: w, height: 100)
                        
                    }
                    .frame(width: w, height: height, alignment: .leading)
                    .offset(x: x)                     // ← slides left
                    .rotationEffect(.degrees(angle))
                    VStack {
                        Image(name)
                            .frame(width: w, height: 100)
                    }
                    .frame(width: w, height: height, alignment: .leading)
                    .offset(x: -x)                     // ← slides left
                    .rotationEffect(.degrees(angle))
                }  // ← tilt
             
            }
        }
        .frame(height: height)
    }
}

#Preview {
    ScrollingCarouselImage(
        name: "carousel",
        height: 260,
        angle: -12,  // tweak this
        pointsPerSecond: 40  // tweak speed
    )
}
