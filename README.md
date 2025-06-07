# 🎓 TED Insight

**TED Insight** is a Flutter-based mobile application that transforms how users interact with TED Talks, providing guided thematic learning paths, intelligent topic-based search, and a personal favorites section. The backend is fully serverless and built using AWS services.

---

## 🚀 Key Features

### 🔎 Explore by Tag
- Search TED Talks by entering a topic (e.g., `leadership`, `innovation`, etc.).
- Infinite scroll to browse more results.
- Shows real-time key phrases extracted from the talk description using local NLP.
- Add or remove talks from favorites with a heart icon.

### 🔥 Popular Tags
- View the top 10 most popular tags in the dataset.
- Tap on a tag to instantly search for related talks.

### 🧭 Guided Thematic Paths
- Input a topic and set a maximum time available (e.g., 30 minutes).
- The app returns a list of related talks that together stay within the time limit.
- Displays title, speaker, duration, and key phrases.
- You can add any talk to favorites from this section as well.

### ❤️ Favorites Section
- Save any TED Talk from the Explore or Thematic Path screens.
- View all saved talks grouped by common key phrases.
- Accessible via the bottom navigation bar.

---

## 📱 User Interface

- Full support for Light and Dark mode.
- Clean and modern Material Design 3 interface.
- Animated transitions and polished UX.
- Bottom navigation bar for intuitive switching between screens.

---

## ☁️ Backend Architecture (AWS)

- **AWS Lambda**: Serverless functions for business logic (GetTalkByTag, GetPopularTags, GetThematicPath).
- **API Gateway**: Exposes REST APIs to the Flutter frontend.
- **AWS Glue**: Cleans, joins, and aggregates data from CSV files in S3 and uploads them to MongoDB.
- **MongoDB Atlas**: Cloud NoSQL database that stores TED talk metadata.
- **S3**: Storage for dataset CSV files used by AWS Glue.

---

## 🧠 Local NLP

- Uses the `compromise` JavaScript NLP library.
- Extracts nouns and verbs from the TED Talk description.
- Runs locally in Lambda and is saved in the DB to avoid redundant processing.

---

## 🛠 Technologies Used

- Flutter 3.x (Dart)
- AWS Lambda (Node.js)
- AWS Glue (PySpark)
- MongoDB Atlas (NoSQL)
- Amazon S3
- AWS API Gateway
- Compromise NLP
- Postman (for API testing)

---


## ⚙️ Local Setup

1. Install [Flutter](https://flutter.dev/docs/get-started/install) and run `flutter doctor` to verify your setup.
2. Clone this repository:
   ```bash
   git clone https://github.com/mcesari01/TEDInsight.git
   cd ted_insight
   ```
3. Install dependencies:
	```bash
	flutter pub get
	```
4. Run the app:
	```bash
	flutter run
	```
   

---

## 🔮 Future Improvements
	•	Cloud-based user login and favorite synchronization.
	•	Smart push notifications for new relevant talks.
	•	Trend dashboards for institutional use (e.g., universities or companies).
	•	Sharing TED Talks via social media or links.
---

## 👨‍💻 Authors

Matteo Cesari and Davide Girolamo

University of Bergamo

Master’s in Computer Engineering

Cloud & Mobile Technologies ·  2024/2025

---

## 📜 License

This project is licensed under the MIT License.
