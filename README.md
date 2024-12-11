# Currency Converter IOS App(Swift)
_This simple currency converter app made with Swift is the first app I created in this language and marks the start of my journey learning ios development._
# NOTE
- I followed a Udemy course, which is this one: https://www.udemy.com/course/ios-15-app-development-with-swiftui-3-and-swift-5/..
- After I finished the first app from the course, I made changes to the project for practice and learning purposes.
- The code structure in this project is not very efficient or perfect, as I just started learning ios development. I've created this repository to track my progress as I work on more projects in the future.
# My Changes
- Removed hard-coded currency values and fetched actual values from the API.
- Added real currency options (PHP, USD, HK).
- Added local storage to cache values and limit fetching to once per day (24-hour expiration).
- Extracted sub views for readability and reusability.
- Added Standardized text. (CCText)
- Added View Models for separation of concerns.
# SETUP
- Add your own API key inside the `ExchangeRateService` file. Create your key here: Link: https://freecurrencyapi.com/
# DEMO
https://github.com/user-attachments/assets/4670efe1-89db-4219-ab2a-1976745fb27e
