# Tech Matcher
Project Submission for the course NanoDegree - iOS Developer at Udacity

Tech Matcher allows you to find people interested in studying a specific topic related to programming and also allows your to find people willing to help/tech. Tech Matcher is the app that helps students and teacher find eachother.

## Requirements from Udacity:
https://docs.google.com/document/d/1CWsC1jszFEYX5EM3CE9sX88FuIZCim4fMNml-lUPKlo/pub?embedded=true
https://review.udacity.com/#!/projects/3772828931/rubric

## Specs
- XCode 8.3.3
- Swift 3.0
- Firebase used as backend, persistence layer and API.

## Instructions to install appp/test (Udacity)
1. Download zip or run git clone
2. Extract files to a folder and then run the command:
pod install
3. When cocoapods finishes installing the dependencies, open the workspace project.
4. To test the use you can signin with any email (account created automatically), or you can use one of the test accounts.

## Testing Accounts

test0@test0.com
Test1234 

test1@test1.com
Test1234 

test2@test2.com
Test1234 

test3@test3.com
Test1234 

and so on, till 99

## Instructions to install with new firebase account
1. Create your firebase account
2. Download firebase settings plist and replace the one on the app
3. Run server script to install trigger on the server. The trigger will create "Matches" entities when there is a match.

# Features/Specification:
The app has few screens, each one with a specific feature

## Login Screen
This is the first screen, here the user has the chance to login with existing credentials or create a new account using email & password.

![](/Screenshots/01.png) ![](/Screenshots/02.png)

## Settings Screen
You can use this screen to change your name on the app, update about section and upload your picture

![](/Screenshots/04.png)

## Match Screen
This is the main screen, where you can connect to other people. You have the option to connect/like or ignore/skip. If it happens to the other person have already liked you, then you get a match.

![](/Screenshots/03_a.png) ![](/Screenshots/03_b.png)

## Match List
This is screen shows all your previous matches. Then you can select any row to start a conversation.

![](/Screenshots/05.png)

## Chat
Here you can chat with your match. Messages sent by you will appear in blue, messages sent by the match will appear in gray.

![](/Screenshots/06.png)


# Improvement Ideas
- Login using social networks, e.g Facebook, Google, Linkedin, Github
- UI Improvements like animations when you swipe a picture
- Search by GPS coordinates to find people around you
- Option to specify if you are interested in teaching or learning and what topics you want
- Push notifications when you get a match

# TL;DR;
Tinder for Developers
