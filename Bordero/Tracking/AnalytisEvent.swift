//
//  AnalytisEvent.swift
//  Bordero
//
//  Created by Grande Variable on 05/06/2024.
//

import Foundation

enum EventCategory: String {
    case userEngagement = "User Engagement"
    case documentManagement = "Document Management"
    case notification = "Notification"
    case paymentManagement = "Payment Management"
    case clientManagement = "Client Management"
    case praticienManagement = "Praticien Management"
}

enum EventName: String {
    // MARK: - Praticien
    case praticienDashboardShowed = "praticien_dashboard_showed"
    
    // MARK: - Documents
    case documentListBrowsed = "document_list_browsed"
    case documentCreated = "document_created"
    case documentEdited = "document_edited"
    case documentSent = "document_sent"
    case documentExported = "document_exported"
    
    // MARK: - Articles
    case articleRead = "article_read"
    
    // MARK: - Notifications
    case notificationInteracted = "notification_interacted"
    
    // MARK: - Payments
    case paymentAdd = "payment_add"
    case paymentListBrowsed = "payment_list_browsed"
    case paymentReminderSent = "payment_reminder_sent"
    
    // MARK: - Clients
    case clientListBrowsed = "client_list_browsed"
    case clientImported = "client_imported"
    case clientCreated = "client_created"
    case clientStatsBrowsed = "client_stats_browsed"
    case clientDetailBrowsed = "client_detail_browsed"
}
