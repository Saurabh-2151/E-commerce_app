# ShopEasy — E-Commerce Flutter App

**Tagline:** Shop the best deals

A polished, production-quality mini e-commerce app built with Flutter, featuring a clean Material 3 design and integration with the Fake Store API.

---

## Features

### User Experience
- **Splash Screen** with animated logo and 3-second auto-navigation
- **Login Flow** with email/password validation
- **Dashboard** with category cards, promo banner, and pull-to-refresh
- **Product Browsing** with shimmer loading states and rating displays
- **Product Details** with full descriptions, ratings, and add-to-cart functionality
- **Shopping Cart** with quantity controls, undo on delete, and line totals

### Technical Highlights
- **State Management**: Provider with ChangeNotifier pattern
- **Network**: HTTP client with proper error handling and timeouts
- **Images**: Cached network images with placeholders
- **Loading States**: Shimmer skeletons for better UX
- **Error Handling**: Retry buttons and user-friendly error messages
- **Responsive Design**: Works on small (360dp) and large screens
- **Clean Architecture**: Separated concerns (models, services, providers, screens, widgets)

---

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart (3.0 or higher)
- An emulator or physical device

### Installation

1. Clone the repository and navigate to the project folder:
   ```bash
   cd e_commerce_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

4. For release build:
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

---

## API Endpoints

The app integrates with the [Fake Store API](https://fakestoreapi.com):

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/products/categories` | GET | Fetch all product categories |
| `/products/category/{slug}` | GET | Fetch products by category slug |
| `/products/{id}` | GET | Fetch single product details |

**Important Note**: The API returns category slugs in lowercase (e.g., `electronics`, `jewelery`, `men's clothing`, `women's clothing`). The app correctly uses these slugs for API calls while displaying user-friendly names in the UI.

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── theme.dart              # Material 3 theme configuration
│   ├── constants.dart          # App-wide constants
│   ├── validators.dart         # Form validation logic
│   └── category_style.dart     # Category-specific colors/icons
├── models/
│   ├── product.dart            # Product data model
│   ├── category_item.dart      # Category with slug & display name
│   └── cart_item.dart          # Cart item model
├── services/
│   └── api_service.dart        # HTTP client & API integration
├── providers/
│   ├── cart_provider.dart      # Cart state management
│   └── catalog_provider.dart   # Category & product catalog state
├── screens/
│   ├── splash_screen.dart      # Animated splash screen
│   ├── login_screen.dart       # Login form
│   ├── dashboard_screen.dart   # Category grid & promo banner
│   ├── product_list_screen.dart # Products by category
│   ├── product_details_screen.dart # Single product view
│   └── cart_screen.dart        # Shopping cart
└── widgets/
    ├── category_card.dart      # Gradient category tiles
    ├── product_card.dart       # Product grid items
    ├── cart_item_tile.dart     # Cart list items
    ├── state_views.dart        # Loading, error, empty states
    └── cart_icon_button.dart   # Cart badge icon
```

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0               # State management
  http: ^1.1.0                   # API calls
  cached_network_image: ^3.2.3   # Image caching
  shimmer: ^3.0.0                # Skeleton loading
```

---

## Design System

### Colors
- **Primary**: Orange `#FF6D00`
- **Background**: Light gray `#F7F7F9`
- **Surface**: White `#FFFFFF`
- **Text Primary**: Dark `#14142B`
- **Text Secondary**: Gray `#6B6B80`

### Typography
- System default (Roboto on Material)
- Consistent sizing: 11–24px with appropriate weights

### Components
- **Cards**: 16–20px radius, soft shadows
- **Buttons**: Full-width with 16px vertical padding
- **Spacing**: 8/12/16/24px scale

---

## Known Limitations

1. **No Real Authentication**: Login is simulated with a 1-second delay
2. **No Checkout**: Checkout button shows a "Coming soon" message
3. **Local Cart Only**: Cart data is stored in memory (lost on app restart)
4. **No Search**: Search bar is decorative (marked as optional feature)

---

## Code Quality

- Zero `flutter analyze` warnings/errors
- Null-safety enabled
- `const` constructors where possible
- Proper `mounted` checks after async operations
- Clean separation of concerns
- Reusable widget components

---

## License

This is a demonstration project built for educational purposes. The Fake Store API is provided by [fakestoreapi.com](https://fakestoreapi.com).

---

## Credits

**Built with**: Flutter & Dart  
**API**: Fake Store API  
**Design**: Material 3 Design System
