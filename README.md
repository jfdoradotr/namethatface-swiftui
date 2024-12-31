# Name That Face

This project is part of the 100 Days of SwiftUI journey and focuses on building a photo identification app with facial tagging capabilities. It demonstrates how to work with Core Data (using SwiftData), MapKit, and biometric authentication, helping developers enhance their SwiftUI, Core Location, and advanced iOS development skills.

## Key Features

- **Photo Importing and Tagging:**
  - Users can import photos from their photo library and tag them with a name.
  - Supports biometric authentication for unlocking the app.

- **Location Integration with MapKit:**
  - Users can optionally store the location where the photo was added.
  - Displays tagged photos' locations on a map for easy visualization.

- **Data Persistence:**
  - Photos, names, and locations are saved locally using SwiftData.

## Lessons Learned

This project covers several important concepts:

1. **Using PhotosPicker to Import Images:**
   - Leveraging the PhotosPicker API to select and load images from the photo library.

2. **Core Location for Geotagging:**
   - Integrating Core Location to fetch the user's current location.

3. **Data Persistence with SwiftData:**
   - Storing and retrieving photos, metadata, and geolocation data efficiently.

4. **Biometric Authentication:**
   - Adding security to the app with Face ID or Touch ID.

5. **MapKit for Geolocation Visualization:**
   - Displaying photo locations on a map with annotations.

## Challenges and Solutions

1. **Challenge: Handling missing location data for some photos**
   - Solution: Implemented optional handling for latitude and longitude in the data model, ensuring graceful degradation if no location data is available.

2. **Challenge: Biometric authentication for security**
   - Solution: Integrated `LocalAuthentication` to lock the app until the user authenticates successfully.

3. **Challenge: Managing large images efficiently**
   - Solution: Used `UIImage` resizing and external storage attributes for optimized data handling.

## Usage Instructions

1. **Add a Photo:**
   - Tap the "Select an image" button in the toolbar to pick a photo from your library.

2. **Tag and Save:**
   - Enter a name and save the photo. The app will optionally fetch and store your current location.

3. **View Photos:**
   - Browse saved photos in a grid layout. Tap on any photo to view details and its location on a map.

4. **Delete Photos:**
   - Use the delete button in the detail view to remove a photo.

## Code Overview

- **NameThatFaceApp:**
  - The main entry point of the app, initializing the model container for data persistence.

- **Face Model:**
  - Defines the structure for storing photo data, names, and optional location metadata.

- **ContentView:**
  - The main interface, handling authentication, photo importing, and navigation.

- **AddView:**
  - Provides a UI for tagging a photo with a name and optionally geotagging it.

- **DetailView:**
  - Displays a photo's details, including a map showing its location if available.

- **LocationFetcher:**
  - Handles fetching the user’s current location using Core Location.

## Future Improvements

- Add support for sharing tagged photos and their locations.
- Improve the map view with clustering for multiple photos in close proximity.
- Implement advanced search and filtering options for tagged photos.

## Credits

Inspired by Hacking with Swift's 100 Days of SwiftUI. Thank you, Paul Hudson, for providing detailed and engaging tutorials!

---

**Quote for Inspiration:**
“Learning never exhausts the mind.” – Leonardo da Vinci
