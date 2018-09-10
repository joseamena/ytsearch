# YTSearch

This project is a video search app

## Getting Started

1. Get the source code  
git clone https://github.com/joseamena/ytsearch.git

2. cd into ytsearch repo

3. Install dependencies using cocoapods  
pod install

### Prerequisites

-Xcode 9 or higher  
-iOS 11 or higher  
-Cocoapods


## Running the app

Open ytsearch.xcworkspace with Xcode, build and run on simulator or device


### Testing and using the app

The first time using the app, you must login using a google account.

After login, the search screen is displayed, enter a search term in the search bar and hit search.

A maximum of 10 videos will show up.

Do multiple search queries, check for issues in the video thumbnails.

Do a searches as fast as you can to verify app still behaves properly.

Click a video, while it is loading click another one, check that the last video clicked is the one that plays.

Change the query type in the top right corner to: episode, movie or any, look that search results are different in each case.

Use button in top left to logout and try to login again.

Test the app with a slow connection, background fetching and prefetching should make UI still be responsive while loading content, test for crashes

