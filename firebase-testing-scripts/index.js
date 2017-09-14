const admin = require("firebase-admin");
const serviceAccount = require(require('os').homedir() +"/Documents/private/tech-matcher-firebase-adminsdk-v66qx-e7fcb42d2b.json");
const faker = require('faker');
const _ = require('lodash');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://tech-matcher.firebaseio.com"
});



function registerUser(index){
  return new Promise(function (resolve, reject){

    var user = {
      email: ("test"+index+"@test"+index+".com"),
      emailVerified: false,
      password: "Test1234",
      displayName: faker.name.findName(),
      disabled: false
    }

    admin.auth().createUser(user)
    .then(function(userRecord) {
      user.uid = userRecord.uid
      resolve(user)
    })
    .catch(function(error) {
      reject(error)
    });
  })
}

function registerDetails(user){
  return new Promise(function (resolve, reject){

    user.about =
      faker.name.jobDescriptor() + ", "
    + faker.company.catchPhrase() + ", "
    + faker.company.bs();
    user.image = null

    var userEntry = admin.database().ref("/users").child(user.uid)

    var newUser = {
        "userId" : user.uid,
        "name" : user.displayName,
        "about" : user.about,
        "image" : user.image
    }

    userEntry.set(newUser)
    resolve(newUser)
  })
}

function processUser(userId){
  return registerUser(userId).then(function(user){
    return registerDetails(user)
  })
}




// This creates 100 users with email and passowrd.
// Also creates the user details.
// var interval = 3000 // 2 seconds
// for(var i = 0; i < 100; i++){
//   setTimeout(function(index){
//     processUser(index)
//   }, i * interval, i);
// }


function retrieveUserIds(){
  return new Promise(function(resolve,reject){
    admin.database().ref("/users").once('value').then(function(snapshot){
      resolve(snapshot.val())
    })
  })
}



var rootData = {}
var matchesRegistered = {}

retrieveUserIds().then(function(usersMap){
  var listUsers = _.map(usersMap, function(value, key){ return key })
  createLikesAndMatches(listUsers)
})

function createLikesAndMatches(listUsers){

  // Creates likes locally.
  for(i = 0; i < listUsers.length; i++){
    for(j = 0; j < listUsers.length; j++){
      iterateLike(listUsers, i, j)
    }
  }

  // Save likes on server
  admin.database().ref('/').update(rootData)

  for(i = 0; i < listUsers.length; i++){
    for(j = 0; j < listUsers.length; j++){
      createMatchOnServer(listUsers[i], listUsers[j])
    }
  }
  
  //console.log("Matches ", Object.keys(matchesRegistered).length / 2)

} 

function getLike(key1, key2){

  if (rootData["userLikes"] == null) {
    return false
  }

  if (rootData["userLikes"][key1] == null) {
    return false
  }

  if (rootData["userLikes"][key1][key2] == null) {
    return false
  }

  return rootData["userLikes"][key1][key2] === true
}

function createMatchOnServer(key1, key2){
  
  if (matchesRegistered[key1+key2] === true){
    // Match already registered.
    return
  }

  if (!getLike(key1, key2) || !getLike(key2, key1)){
    // It's not a match
    return
  }

  var matchKey = admin.database().ref('/matches').push().key

	var json = {}
	json["/matches/" + matchKey + "/" + key1] = true
	json["/matches/" + matchKey + "/" + key2] = true
	json["/usersMatches/" + key1 + "/" + key2] = {"matchId": matchKey, "seen" : false}
	json["/usersMatches/" + key2 + "/" + key1] = {"matchId": matchKey, "seen" : false}
  admin.database().ref('/').update(json)
  
  matchesRegistered[key1+key2] = true
  matchesRegistered[key2+key1] = true
}

function addLike(fromId, toId, like){

  if (rootData["userLikes"] == null) {
    rootData["userLikes"] = {}
  }

  if (rootData["userLikes"][fromId] == null) {
    rootData["userLikes"][fromId] = {}
  }

  rootData["userLikes"][fromId][toId] = like
}





function iterateLike(listUsers, i, j){
  var fromId = listUsers[i]
  var toId = listUsers[j]
  var randomNumber = getRandomInt(0,3)
  if (fromId == toId) {
    console.log("Same user, ignoring...")
  } else if (randomNumber == 0) {
    // Jump without like/dislike
  } else if (randomNumber == 1) {
    addLike(fromId, toId, true)
  } else if (randomNumber == 2) {
    addLike(fromId, toId, false)
  }
}



function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min)) + min; //The maximum is exclusive and the minimum is inclusive
}
