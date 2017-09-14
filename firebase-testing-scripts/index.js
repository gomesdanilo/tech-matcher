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


// Total calls = 100*100 = 10000
// Limit per seconds = 50 calls / second
// Total time for 10000 = 200 seconds
// Interval per 1 call = 20 ms


retrieveUserIds().then(function(usersMap){
  var listUsers = _.map(usersMap, function(value, key){ return key })
  
  var intervalPerCall = 20
  for(var i = 0; i < listUsers.length; i++){
      var intervalBlock = listUsers.length * intervalPerCall * i

      for(var j = 0; j < listUsers.length; j++){
        var interval = j * intervalPerCall + intervalBlock
        //console.log("Call at ", interval)
        setTimeout(function(listUsers, i, j){
          iterateLike(listUsers, i, j)
        }, interval, listUsers, i, j);
      }
	}
})

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

function addLike(fromId, toId, like){
	admin.database().ref("/userLikes").child(fromId).child(toId).set(like)
}

function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min)) + min; //The maximum is exclusive and the minimum is inclusive
}
