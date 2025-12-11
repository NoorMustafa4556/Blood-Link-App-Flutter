# Blood Link - Blood Donation App 🩸

**Blood Link** is a modern Flutter application designed to bridge the gap between blood donors and recipients. With a seamless user interface and real-time connectivity, it aims to save lives by making the blood donation process efficient and accessible.

## 🚀 Key Features

*   **Role-Based Access**: Specialized dashboards for **Donors** (to view requests) and **Recipients** (to find donors).
*   **Real-Time Search**:
    *   **For Donors**: Advanced search to filter blood requests by Name, City, or Blood Group.
    *   **For Recipients**: Quick search to find donors in specific areas.
*   **Smart Matching**: Recipients can filter donors by City and Blood Group.
*   **Secure Profile Management**:
    *   Update Profile Details (Name, Username).
    *   **Secure Password Change** with re-authentication protections.
*   **Dynamic Theming**:
    *   **Dark Mode** & Light Mode support.
    *   System default theme adaptation.
    *   Persisted user preference using `Provider`.
*   **Modern UI/UX**:
    *   Premium "Lavish Red" color scheme.
    *   Interactive Drawer navigation (Home, Profile, Settings, Logout).
    *   Password visibility toggles for enhanced usability.

## 🛠️ Technology Stack

*   **Frontend**: Flutter (Dart)
*   **Backend**: Firebase (Authentication, Cloud Firestore)
*   **State Management**: Provider
*   **Local Storage**: Shared Preferences (for Theme persistence)
*   **Fonts**: Google Fonts (Poppins)

## 📸 Screenshots

| Login Screen | Donor Dashboard | Recipient Search |
|:---:|:---:|:---:|
| *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* |

## 🏁 Getting Started

### Prerequisites
*   Flutter SDK installed.
*   Firebase Project setup with `google-services.json` (Android) / `GoogleService-Info.plist` (iOS).

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-username/blood-link.git
    ```
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the App**:
    ```bash
    flutter run
    ```

## 🤝 Contribution

Contributions are welcome! Please fork the repository and create a pull request with your improvements.

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
