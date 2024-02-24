//
//  ContentView.swift
//  GradientNavigationStack
//
//  Created by Roberto Camargo on 14/11/23.
//

import SwiftUI

public struct HomeScrollableGradientBackgroundCustomView<Content: View>: View {
    @State private var gradientEndPoint: Double = 0
    var content: () -> Content
    var heightPercentage: Double
    var maxHeight: Double
    var minHeight: Double
    var startColor: Color
    var endColor: Color
    var navigationTitle: String
    
    // MARK: Custom
    @State private var shouldShowTitle = false

    private func calculateEndPointForScrollPosition(scrollPosition: Double) -> Double {
        let absoluteScrollPosition = abs(scrollPosition)
        let endPoint = heightPercentage - (heightPercentage / maxHeight) * absoluteScrollPosition

        return endPoint.clamped(to: 0 ... heightPercentage)
    }

    private func checkScrollPositionAndGetEndPoint(scrollPosition: Double) -> Double {
        let isScrollPositionLowerThanMinHeight = scrollPosition < minHeight

        return isScrollPositionLowerThanMinHeight ? calculateEndPointForScrollPosition(scrollPosition: scrollPosition) : heightPercentage
    }

    private func onScrollPositionChange(scrollPosition: Double) {
        gradientEndPoint = checkScrollPositionAndGetEndPoint(
            scrollPosition: scrollPosition
        )
    }
    
    private func checkPosition( _ geometry : GeometryProxy) {
        shouldShowTitle = geometry.frame(in: .global).minY < 0
    }

    public init(heightPercentage: Double, maxHeight: Double, minHeight: Double, startColor: Color, endColor: Color,
                navigationTitle: String, @ViewBuilder content: @escaping () -> Content)
    {
        self.heightPercentage = heightPercentage
        self.maxHeight = maxHeight
        self.minHeight = minHeight
        self.startColor = startColor
        self.endColor = endColor
        self.navigationTitle = navigationTitle
        self.content = content
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                
                HStack {
                    Text(navigationTitle)
                        .bold()

                    Spacer()

                    NavigationLink {
                        Text("Person View")
                    } label: {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundStyle(.white, .gray)
                            .imageScale(.large)
                    }

                }
                .font(.title)
                .padding()
                
                LazyVStack {
                    content()
                }
                .padding()
                .coordinateSpace(name: "scroll")
                .background(
                    GeometryReader { geometry in
                        
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(
                                in: .named("scroll")
                            ).origin
                        )
                        .onAppear {
                            checkPosition(geometry)
                        }
                    })
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) {
                    value in
                    onScrollPositionChange(scrollPosition: value.y)
                    
                    // MARK: Add custom animation
                    withAnimation(.easeInOut) {
                        shouldShowTitle = value.y < 123.1
                    }
                    
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(navigationTitle)
                        .opacity(shouldShowTitle ? 1 : 0)
                        .transition(.asymmetric(insertion: .scale, removal: .opacity))
                        
                }
                
            }
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarBackground(shouldShowTitle ? .visible : .hidden, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(
                    gradient:
                    Gradient(
                        colors: [startColor, endColor]
                    ), startPoint: .top,
                    endPoint: UnitPoint(
                        x: 0.5,
                        y: gradientEndPoint
                    )
                )
                .ignoresSafeArea()
            )
        }
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            UINavigationBar.appearance().standardAppearance = appearance

            let exposedAppearance = UINavigationBarAppearance()
            exposedAppearance.backgroundEffect = .none
            exposedAppearance.shadowColor = .clear
            UINavigationBar.appearance().scrollEdgeAppearance = exposedAppearance
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

extension Comparable {
    func clamped(to r: ClosedRange<Self>) -> Self {
        let min = r.lowerBound, max = r.upperBound
        return self < min ? min : (max < self ? max : self)
    }
}

#Preview {
    HomeScrollableGradientBackgroundCustomView(heightPercentage: 0.4, maxHeight: 200, minHeight: 0, startColor: Color.red, endColor: Color.clear, navigationTitle: "Test", content: { ForEach(0 ..< 120) { value in Text("Test \(value)") } })
}
