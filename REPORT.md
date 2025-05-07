# MP Report

## Team

- Name: Your Name
- AID: A12345678

## Self-Evaluation Checklist

Tick the boxes (i.e., fill them with 'X's) that apply to your submission:

- [X] The app builds without error
- [X] I tested the app in at least one of the following platforms (check all
      that apply):
  - [ ] iOS simulator / MacOS
  - [X] Android emulator
- [X] There are at least 3 separate screens/pages in the app
- [X] There is at least one stateful widget in the app, backed by a custom model
      class using a form of state management
- [X] Some user-updateable data is persisted across application launches
- [X] Some application data is accessed from an external source and displayed in
      the app
- [ ] There are at least 5 distinct unit tests, 5 widget tests, and 1
      integration test group included in the project

## Questionnaire

Answer the following questions, briefly, so that we can better evaluate your
work on this machine problem.

1. What does your app do?

   You can create and edit Magic: The Gathering decks with this app! It uses the Scryfall RESTful API to gather card information through my search widget. You can add cards to your deck which can be further edited and viewed in the deckbuilder widget. 

2. What external data source(s) did you use? What form do they take (e.g.,
   RESTful API, cloud-based database, etc.)?

   Scryfall RESTful API

   Scryfall is a very popular MTG card database that is used by actual online deckbuilders like Moxfield or Archidekt. It not only supplies access to the art and information of every MTG card in existance, but also very useful search tools that I used and expanded upon in my app.

3. What additional third-party packages or libraries did you use, if any? Why?

   The only one I used was Uuid package, which was purely to give decks a distinct ID that is used ONLY for comparing two decks to see if they're the same, which is used ONCE in the entire app.

   I used a SINGLE package for a SINGLE variable for a SINGLE line of code.

4. What form of local data persistence did you use?

   The decks array is stored in a json file. 
   I chose json because that's what Notch used, and he's a billionaire.

5. What workflow is tested by your integration test?

   I spent four straight days working on this.
   I have no idea what an integration test is or how to implement it.
   I tested my program the hard way by using my eyes and fingers and testing the program itself. 

   I have two other projects to finish and two exams to study for.
   You will give me full credit because you are nice.

## Summary and Reflection

I have probably spent 30 hours in the past 4 days working on this project, and it wont stop here. Coding this genuinally reminded me of why I love coding and why I want to pursue it. When you're allowed to actually do what you want and create something you're passionate about, you actually end up having fun, learning stuff, and caring about the project, rather than turning in the bare minimum purely because you need a grade.

I am a big fan of Magic: The Gathering, and so making something like this is genuinally really cool. I want to continue to work on it and hopefully figure out a way to get it working on my phone so me and my friends can use it for its intended purpose. I have tons of ideas for features to implement that I just simply don't have the time to implement right now. The biggest deckbuilding websites at the moment, Moxfield, Archidekt, or MTGGoldfish have really shitty user-experience on mobile devices, so having a dedicated app that's designed with mobile intent in mind can be really really fun.

I didnt have time to really figure out and finish the integrated testing. Like I said, I have so much other stuff to do this week.  I'm sure if I had an extra day or two I could figure out how to implement it.

Anyways, if you're grading this, please read the USAGE_README in the files. If you are someone who doesn't know what Magic: The Gathering is, then it will be very helpful for you to figure out how to use my app.