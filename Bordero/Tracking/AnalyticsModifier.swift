//
//  AnalyticsModifier.swift
//  Bordero
//
//  Created by Grande Variable on 05/06/2024.
//

import Foundation
import SwiftUI

struct TrackEventOnAppear: ViewModifier {
    let event: EventName
    let category: EventCategory
    let parameters: [String: Any]?
    
    @Environment(\.analytics) private var analytics
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                analytics.track(event: event, category: category, parameters: parameters)
            }
    }
}

extension View {
    func trackEventOnAppear(event: EventName, category: EventCategory, parameters: [String: Any]? = nil) -> some View {
        self.modifier(TrackEventOnAppear(event: event, category: category, parameters: parameters))
    }
}
