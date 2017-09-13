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

  
	for(var i = 0; i < 8; i++){
        var userEntry
        // Add default user
        if (i == 0) {
            userEntry = database.ref("/users/xtzbs091hsMyRuW5Qx1T9CYXoGQ2")
        } else {
            userEntry = usersRef.push()
        }
        
        listUsers.push(userEntry.key)
        userEntry.set({
            "name" : "Sample Name #" + i,
            "about" : "I'm a programmer!" + i,
            "mode" : "Learn",
            "maximumDistance" : i,
            "discoveryEnabled" : true,
            "latitude" : i,
            "longitude" : i
        })
	}
}

function addLike(userLikes, fromId, toId, like){
	userLikes.child(fromId + "/" + toId).set(like)
}

function addLikes(){
	console.log("addding likes")

	var userLikes = database.ref("/userLikes")
	userLikes.set(null)

	for(var i = 0; i < listUsers.length; i++){
		for(var j = 0; j < listUsers.length; j++){

			var fromId = listUsers[i]
			var toId = listUsers[j]
			var randomNumber = getRandomInt(0,3)
			if (fromId == toId) {
				console.log("Same user, ignoring...")
			} else if (randomNumber == 0) {
				// Jump without like/dislike
			} else if (randomNumber == 1) {
				addLike(userLikes, fromId, toId, true)
			} else if (randomNumber == 2) {
				addLike(userLikes, fromId, toId, false)
			}
		}
	}
}

addUsers()
addLikes()