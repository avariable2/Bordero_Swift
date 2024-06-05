//
//  AnalyticsService.swift
//  Bordero
//
//  Created by Grande Variable on 05/06/2024.
//

import Foundation
import FirebaseAnalytics

class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    func track(event: EventName, category: EventCategory, parameters: [String: Any]? = nil) {
        #if !DEBUG
        var allParameters = parameters ?? [:]
        allParameters["category"] = category.rawValue
        Analytics.logEvent(event.rawValue, parameters: allParameters)
        #endif
    }
}
