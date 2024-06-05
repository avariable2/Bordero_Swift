//
//  AnalyticsEnvironmentKey.swift
//  Bordero
//
//  Created by Grande Variable on 05/06/2024.
//

import Foundation
import SwiftUI

struct AnalyticsEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnalyticsService = AnalyticsService.shared
}

extension EnvironmentValues {
    var analytics: AnalyticsService {
        get { self[AnalyticsEnvironmentKey.self] }
        set { self[AnalyticsEnvironmentKey.self] = newValue }
    }
}
