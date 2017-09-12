var admin = require("firebase-admin");
var serviceAccount = require(require('os').homedir() +"/Documents/private/tech-matcher-firebase-adminsdk-v66qx-e7fcb42d2b.json");


admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://tech-matcher.firebaseio.com"
});


function getRandomInt(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min)) + min; //The maximum is exclusive and the minimum is inclusive
}


var listUsers = []
var database = admin.database()
var likes = {}



function addUsers(){
	console.log("addding users")
	var usersRef = database.ref("/users")
	usersRef.set(null)

	for(var i = 0; i < 100; i++){
		var userEntry = usersRef.push()
		listUsers.push(userEntry.key)
		userEntry.set({
			"fullname" : "fullname" + i,
			"about" : "about" + i,
			"mode" : "Learn",
			"maximumDistance" : i,
			"discoveryEnabled" : true,
			"latitude" : i,
			"longitude" : i
		})
	}
}

function addLike(matchesNode, fromId, toId){
	var match = matchesNode.child(fromId)
	var json = {}
	json[toId] = true
	match.update(json)

	if (likes[fromId] == null) {
		likes[fromId] = {}
	}

	likes[fromId][toId] = true
}

function addDislike(matchesNode, fromId, toId){
	var match = matchesNode.child(fromId)
	var json = {}
	json[toId] = false
	match.update(json)

	if (likes[fromId] == null) {
		likes[fromId] = {}
	}
	likes[fromId][toId] = false
}

function addLikes(){
	console.log("addding likes")
	var matchesRef = database.ref("/likes")
	matchesRef.set(null)

	for(var i = 0; i < 100; i++){
		for(var j = 0; j < 100; j++){

			var fromId = listUsers[i]
			var toId = listUsers[j]
			var randomNumber = getRandomInt(0,3)
			if (fromId == toId) {
				console.log("Same user, ignoring...")
			} else if (randomNumber == 0) {
				// Jump without like/dislike
			} else if (randomNumber == 1) {
				addLike(matchesRef, fromId, toId)
			} else if (randomNumber == 2) {
				addDislike(matchesRef, fromId, toId)
			}
		}
	}
}

// function addMatches(){
// 	console.log("addding matches")
// 	var matchesRef = database.ref("/matches")
// 	matchesRef.set(null)

// 	for(var i = 0; i < 100; i++){
// 		for(var j = 0; j < 100; j++){

// 			var fromId = listUsers[i]
// 			var toId = listUsers[j]

// 			if (fromId == toId){
// 				// Ignore
// 			} else {

// 				var likeFrom = likes[fromId] != null && likes[fromId][toId] != null && likes[fromId][toId] == true
// 				var likeTo = likes[toId] != null && likes[toId][fromId] != null && likes[toId][fromId] == true
// 				if (likeTo && likeFrom) {
// 					// Match
// 					var newMatch = matchesRef.push()
// 					newMatch.child("users").push(likeFrom)
// 					newMatch.child("users").push(likeTo)
// 				}
// 			}
// 		}
// 	}
// }

function main(){
	addUsers()
	addLikes()
	//addMatches()
}


main()