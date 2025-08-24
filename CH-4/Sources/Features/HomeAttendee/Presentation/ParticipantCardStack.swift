import SwiftUI

struct ParticipantCardStack: View {
    let cards: [ParticipantCardData]
    @State private var currentIndex = 0
    @State private var dragOffset = CGSize.zero
    
    private let cardOffset: CGFloat = 30
    private let cardScale: CGFloat = 0.95
    private let swipeThreshold: CGFloat = 100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<cards.count, id: \.self) { index in
                    let cardData = cards[index]
                    FlexibleParticipantCard(
                        image: cardData.image,
                        name: cardData.name,
                        title: cardData.title,
                        detailContent: cardData.detailContent,
                        onTap: cardData.onTap
                    )
                    .scaleEffect(scaleForCard(at: index))
                    .offset(offsetForCard(at: index))
                    .zIndex(zIndexForCard(at: index))
                    .opacity(opacityForCard(at: index))
                    .allowsHitTesting(index == currentIndex)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        handleSwipeGesture(value.translation)
                    }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func zIndexForCard(at index: Int) -> Double {
        let position = (index - currentIndex + cards.count) % cards.count
        
        if position == 0 {
            return Double(cards.count) // Current card on top
        } else {
            return Double(cards.count - position) // Stack others behind
        }
    }
    
    private func scaleForCard(at index: Int) -> CGFloat {
        let position = (index - currentIndex + cards.count) % cards.count
        
        if position == 0 {
            let dragEffect = abs(dragOffset.width) / 1000.0
            return 1.0 - dragEffect * 0.1 // Current card with drag effect
        } else if position <= 2 {
            let scaleReduction = cardScale
            var result: CGFloat = 1.0
            for _ in 0..<position {
                result *= scaleReduction
            }
            return result
        } else {
            return 0.8 // Cards further back
        }
    }
    
    private func offsetForCard(at index: Int) -> CGSize {
        let position = (index - currentIndex + cards.count) % cards.count
        
        if position == 0 {
            // Current card follows drag
            return dragOffset
        } else if position <= 2 {
            // Stacked cards behind with offset
            let baseOffset = CGFloat(position) * cardOffset
            return CGSize(width: baseOffset, height: baseOffset * 0.3)
        } else {
            // Cards way behind - keep them in the stack but further back
            let baseOffset = CGFloat(3) * cardOffset
            return CGSize(width: baseOffset, height: baseOffset * 0.3)
        }
    }
    
    private func opacityForCard(at index: Int) -> Double {
        let adjustedIndex = index % cards.count
        let adjustedCurrent = currentIndex % cards.count
        let position = (adjustedIndex - adjustedCurrent + cards.count) % cards.count
        
        if position == 0 {
            return 1.0 // Current card
        } else if position <= 2 {
            return 0.7 - Double(position - 1) * 0.2 // Visible stacked cards
        } else {
            return 0.1 // Cards further back but still present
        }
    }
    
    private func handleSwipeGesture(_ translation: CGSize) {
        let swipeDistance = translation.width
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if swipeDistance > swipeThreshold {
                // Swipe right - go to previous card (loop to end if at beginning)
                currentIndex = (currentIndex - 1 + cards.count) % cards.count
            } else if swipeDistance < -swipeThreshold {
                // Swipe left - go to next card (loop to beginning if at end)
                currentIndex = (currentIndex + 1) % cards.count
            }
            
            dragOffset = .zero
        }
    }
}

// Data model for the cards
struct ParticipantCardData {
    let image: Image
    let name: String
    let title: String
    let detailContent: AnyView
    let onTap: () -> Void
}
