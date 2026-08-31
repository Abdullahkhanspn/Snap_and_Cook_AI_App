# Snap & Cook — Complete AI Build Prompt (Flutter, Android + iOS)

> Paste this entire prompt into your Android Studio AI agent (or any AI coding agent) to generate the full application.

---

## ROLE

You are an expert Flutter developer. Build a complete, production-ready, cross-platform (Android + iOS) mobile application called **"Snap & Cook"** using Flutter and Firebase. Follow the exact specification below. Generate clean, modular, well-commented, null-safe Dart code using best practices (Provider or Riverpod for state management, proper folder structure, reusable widgets).

---

## 1. PROJECT OVERVIEW

Snap & Cook helps users discover meals they can prepare using ingredients they already have. Users capture or upload a photo of available food items. The app uses AI to:
1. Identify ingredients from the image
2. Recommend suitable recipes
3. Detect allergy risks based on the user's profile
4. Display a **BioGlow health indicator** for every recommended recipe

---

## 2. TECH STACK

- **Framework:** Flutter (latest stable, null-safety)
- **Platforms:** Android & iOS (single codebase)
- **State Management:** Riverpod (or Provider)
- **Backend:** Firebase
    - **Authentication:** Firebase Authentication (Email/Password + Google Sign-In)
    - **Database:** Cloud Firestore
    - **Storage:** Firebase Storage (for uploaded/captured images)
- **AI Integration:** Ingredient Recognition + Recipe Recommendation, using Gemini API (or OpenAI Vision / Google Vision API) via HTTP calls
- **Image Handling:** `image_picker` (camera + gallery), `firebase_storage`
- **Navigation:** `go_router` or Navigator 2.0
- **Local State Persistence:** `shared_preferences` for session/onboarding flags

---

## 3. FOLDER STRUCTURE

```
lib/
 ├── main.dart
 ├── app.dart
 ├── core/
 │    ├── constants/          (colors, text styles, strings)
 │    ├── theme/
 │    ├── utils/
 │    └── services/           (ai_service.dart, firebase_service.dart)
 ├── models/
 │    ├── user_profile_model.dart
 │    ├── recipe_model.dart
 │    └── ingredient_model.dart
 ├── providers/                (Riverpod state providers)
 ├── screens/
 │    ├── splash/
 │    ├── auth/                (login_screen.dart, signup_screen.dart)
 │    ├── profile/             (setup_profile_screen.dart, edit_profile_screen.dart)
 │    ├── dashboard/           (dashboard_screen.dart)
 │    └── result/              (ai_result_screen.dart)
 └── widgets/
      ├── bioglow_badge.dart
      ├── allergy_warning_card.dart
      ├── recipe_card.dart
      └── ingredient_chip.dart
```

---

## 4. APPLICATION FLOW & SCREEN-BY-SCREEN REQUIREMENTS

### 4.1 Splash Screen
- Show app logo + "Snap & Cook" branding, centered, with a subtle fade/scale animation.
- Check Firebase Auth state after ~2 seconds:
    - If logged in AND profile exists → navigate to **Dashboard**
    - If logged in but profile incomplete → navigate to **Profile Setup**
    - If not logged in → navigate to **Login/Signup**

### 4.2 Sign Up / Login
- Email/Password authentication with Firebase Auth.
- Google Sign-In as an optional button.
- Fields & validation:
    - Name (required, min 2 characters)
    - Email (required, valid email regex)
    - Password (required, min 6 characters, show/hide toggle)
- Show inline error messages and loading indicators on submit.
- Link between Login ↔ Signup screens.
- On successful signup, create a Firestore document in `users/{uid}` with basic info, then route to Profile Setup.

### 4.3 User Profile
Store in Firestore under `users/{uid}/profile`:
- Full Name (text)
- Age (optional, numeric)
- Food Allergies (multi-select chips: e.g., Milk, Peanuts, Gluten, Soy, Eggs, Shellfish, Tree Nuts — plus a free-text "Other" field)
- Dietary Preference (single-select): Vegetarian / Vegan / Non-Vegetarian

This profile data must be **read every time recipes are generated or filtered**, and passed into the AI prompt/allergy-check logic. Provide an "Edit Profile" screen accessible from a settings/profile icon on the Dashboard.

### 4.4 Dashboard (Main Screen)
- App bar with app name/logo and a profile/settings icon.
- Two primary actions, prominently displayed:
    - **Camera button** → opens device camera via `image_picker`
    - **Upload from Gallery button** → opens gallery via `image_picker`
- After an image is selected:
    1. Show a loading/processing state (skeleton loader or progress animation with a friendly message like "Identifying your ingredients…")
    2. Upload image to Firebase Storage under `users/{uid}/uploads/{timestamp}.jpg`
    3. Send the image to the AI service for ingredient recognition
    4. Send recognized ingredients + user profile (allergies, diet preference) to the AI recipe recommendation service
    5. Navigate to **AI Result Screen** with the response data

### 4.5 AI Result Screen
Display, in order:

**a) Detected Ingredients**
- Render as a horizontal wrap of chips (e.g., Tomato, Onion, Egg, Bread, Cheese).
- Allow the user to manually remove a misidentified ingredient or add a missed one, then re-run recipe generation.

**b) Recommended Dishes**
- List of recipe cards, each showing:
    - Dish name (e.g., Vegetable Sandwich, Cheese Omelette, Tomato Salad, French Toast)
    - Short text description / ingredients used
    - Allergy Detection result (see below)
    - BioGlow badge (see section 5)
- Recipes must be filtered/adjusted according to the user's Dietary Preference (e.g., a Vegan user never sees egg/dairy/meat-based recipes).

**c) Allergy Detection**
For each recipe, compare the recipe's ingredient list against the user's stored allergy profile:
- If any overlap is found, show a **red "⚠️ Warning" card**: `Contains: Milk, Peanuts` (list only the matched allergens).
- If no overlap, show a **green "✅ Safe to Consume" tag**.
- This check must run automatically for every recipe card — never require the user to trigger it manually.

---

## 5. BIOGLOW HEALTH INDICATOR — DETAILED LOGIC

BioGlow is a **traffic-light health rating** shown as a colored badge/dot + label on every recipe card and on the Result Screen.

### 5.1 Categories
| Color | Label | Meaning |
|---|---|---|
| 🟢 Green | Healthy | Salads, fruits, vegetable soup, grilled vegetables, steamed dishes |
| 🟡 Yellow | Moderate | Pizza, stuffed paratha, pasta, sandwich |
| 🔴 Red | Less Healthy | Burgers, fries, fried chicken, fast food, sugary desserts |

### 5.2 Implementation Requirements
1. **Classification source:** BioGlow rating should be generated by the AI recommendation service as part of the same API response that returns the recipe (i.e., prompt the AI to return a `bioglow` field per recipe: `"green" | "yellow" | "red"`), so it's consistent with the specific recipe suggested — not a separate hardcoded lookup table only.
2. **Fallback keyword logic:** As a safety net (in case the AI doesn't return a rating), implement a local classifier in `core/utils/bioglow_classifier.dart` that checks the dish name/ingredients against keyword lists:
    - Green keywords: salad, soup, steamed, grilled, boiled, fruit, vegetable bowl, sprouts
    - Yellow keywords: pizza, paratha, pasta, sandwich, rice bowl, wrap
    - Red keywords: burger, fries, fried, fast food, dessert, cake, sugary, soda
    - Default to Yellow if no keyword matches (never leave a recipe unrated).
3. **UI representation:**
    - A small colored circular badge (🟢/🟡/🔴) next to the recipe name.
    - A text label ("Healthy" / "Moderate" / "Less Healthy") next to the badge for accessibility.
    - Use consistent theme colors: Green `#2ECC71`, Yellow `#F1C40F`, Red `#E74C3C`.
4. **Widget:** Build a single reusable `BioGlowBadge` widget that accepts a `BioGlowLevel` enum (`green, yellow, red`) and renders the dot + label consistently everywhere it's used.
5. **Model field:** Add `bioGlowLevel` (enum) as a required field in `RecipeModel`.
6. **Optional enhancement (build if time allows):** Show a short one-line tip under Yellow/Red recipes, e.g., "Tip: Pair with a side salad to balance this meal" — generated by the AI or a static tip map keyed by BioGlow level.

---

## 6. DATA MODELS (Dart)

```dart
enum DietaryPreference { vegetarian, vegan, nonVegetarian }
enum BioGlowLevel { green, yellow, red }

class UserProfileModel {
  final String uid;
  final String fullName;
  final int? age;
  final List<String> allergies;
  final DietaryPreference dietaryPreference;
}

class IngredientModel {
  final String name;
  final double? confidence; // from AI recognition
}

class RecipeModel {
  final String name;
  final List<String> ingredientsUsed;
  final List<String> matchedAllergens; // empty = safe
  final BioGlowLevel bioGlowLevel;
  final String? healthTip;
}
```

---

## 7. FIRESTORE STRUCTURE

```
users (collection)
 └── {uid} (doc)
      ├── fullName, email, age, allergies[], dietaryPreference
      └── history (subcollection)
           └── {scanId} (doc)
                ├── imageUrl
                ├── detectedIngredients[]
                ├── recommendedRecipes[] (name, bioGlowLevel, matchedAllergens)
                └── timestamp
```
Save every scan to the `history` subcollection so users can view past results later (build a simple "History" screen if time allows, listing past scans with date + thumbnail).

---

## 8. AI SERVICE INTEGRATION

Create `core/services/ai_service.dart` with two functions:

```dart
Future<List<IngredientModel>> recognizeIngredients(File image);
Future<List<RecipeModel>> getRecipeRecommendations({
  required List<String> ingredients,
  required List<String> userAllergies,
  required DietaryPreference dietPreference,
});
```

- Use the Gemini API (multimodal) to send the image directly and request a structured JSON response containing: detected ingredients, recommended recipes, ingredients per recipe, and a `bioglow` rating per recipe.
- Always instruct the AI (in the system/prompt text) to strictly respect the user's dietary preference and to explicitly list allergens per recipe from a fixed common-allergen list.
- Parse the JSON response into `IngredientModel` / `RecipeModel` objects. Handle malformed responses gracefully with a retry + user-facing error state ("Couldn't process image, please try again").

---

## 9. UI/UX REQUIREMENTS

- Clean, modern, food-app aesthetic: soft rounded cards, warm accent color, plenty of white space.
- Light and dark theme support.
- Loading states for: image upload, AI processing, Firestore reads/writes.
- Empty states: no ingredients detected, no matching recipes found.
- Error states: network failure, AI API failure, permission denied (camera/gallery).
- Smooth navigation transitions between Dashboard → Result Screen.

---

## 10. NON-FUNCTIONAL REQUIREMENTS

- Null-safe, well-commented Dart code.
- Modular file structure as defined in Section 3.
- Add `.env`-based config (via `flutter_dotenv`) for API keys (Gemini/OpenAI key, Firebase config) — do not hardcode secrets.
- Add proper `try/catch` and user-facing error handling on every async call.
- Ensure the app builds and runs cleanly on **both Android and iOS** (no platform-specific code without proper `Platform.isIOS` / `Platform.isAndroid` checks where required, e.g., camera permissions in `Info.plist` and `AndroidManifest.xml`).

---

## 11. DELIVERABLE

Generate the full Flutter project: `pubspec.yaml` with all required dependencies, the complete folder/file structure above, all screens, models, providers, services, and reusable widgets — fully wired end-to-end from Splash → Auth → Profile → Dashboard → AI Result, with the BioGlow indicator working as specified in Section 5.

---

*End of prompt.*
