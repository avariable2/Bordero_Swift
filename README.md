# Bordero (iOS)

**Bordero** is a native iOS application built in Swift, crafted to streamline client, quote, and invoice management for professionals on the move. Leveraging Swift’s strong type safety and Core Data, it ensures reliable storage and retrieval of client records, billing documents, and practitioner details.

---

## Key Features

- **Client Management**  
  - Create, search, edit, and delete client profiles.  
  - Validate input and handle duplicates gracefully.
- **Quotes & Invoices**  
  - Generate custom quotes and invoices with service details and pricing.  
  - Preview, share via email, or export to PDF.
- **Event History**  
  - Track billing events and status changes per document.  
  - View detailed timelines for quotes and payments.
- **Practitioner Directory**  
  - Maintain a list of practitioners with contact and specialization info.
- **Offline Support**  
  - Core Data persistence enables offline access; sync when connected.
- **Modern UI**  
  - Built with SwiftUI for smooth animations and adaptive layouts.

---

## Installation & Setup

1. **Clone the repository**  
   ```bash
   git clone https://github.com/avariable2/Bordero_Swift.git
   cd Bordero_Swift

2. **Open in Xcode**

   * Open `Bordero.xcodeproj` or `Bordero.xcworkspace`.
3. **Install Dependencies**

   * Using CocoaPods:

     ```bash
     pod install
     ```
   * Or Swift Package Manager will auto-resolve dependencies on project open.
4. **Run the App**

   * Select a simulator or device, then click ▶️ Run.

---

## Project Structure

```
Bordero_Swift/
├── Bordero.xcodeproj         # Xcode project file
├── Bordero/                  # App target
│   ├── Models/               # Data models (Client, Document, Event, Practitioner)
│   ├── Views/                # SwiftUI views and custom components
│   ├── Controllers/          # UIKit view controllers (if applicable)
│   ├── ViewModels/           # MVVM view models binding UI to data
│   └── Resources/            # Assets, storyboards, and PDFs (e.g., App-psy.pdf)
└── README.md                 # This file
```

---

## Usage

1. **Clients**: Navigate to the **Clients** tab to add or update client details.
2. **Quotes**: In the **Quotes** tab, enter services and prices to generate a quote.
3. **Invoices**: Switch to the **Invoices** tab to create and manage invoice lifecycles.
4. **History**: Tap any document to view its billing event history and status updates.

---

## Screenshots

<p align="center">
  <img src="assets/images/icon.png" alt="App Icon" width="80" />
  <img src="assets/images/iPhone.png" alt="App Screenshot" width="200" />
</p>

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
