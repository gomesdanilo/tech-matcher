'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);


function createMatch(key1, key2){
  console.log('Creating match', key1, key2)
  const ref = admin.database().ref('/matches').push()
  var json = {}
  json[key1] = {'seen' : false}
  json[key2] = {'seen' : false}
  ref.set(json)
}

exports.matchTrigger = functions.database.ref('/userLikes/{fromUserId}/{toUserId}').onWrite(event => {
  const fromUserId = event.params.fromUserId;
  const toUserId = event.params.toUserId;
  
  const isLike = event.data.val()

  console.log("We have a "+(isLike ? "LIKE" : "DISLIKE")+" from:", fromUserId, ' to ', toUserId);
  if (!isLike){
    return
  }
  onUserLiked(fromUserId, toUserId)
});


function createMatch(key1, key2){
	console.log('Creating match', key1, key2)
	const match = admin.database().ref('/matches').push()

	var json = {}
	json["/matches/" + match.key + "/" + key1] = true
	json["/matches/" + match.key + "/" + key2] = true
	json["/usersMatches/" + key1 + "/" + key2] = {"matchId": match.key, "seen" : false}
	json["/usersMatches/" + key2 + "/" + key1] = {"matchId": match.key, "seen" : false}

	admin.database().ref('/').update(json)
}

function onUserLiked(fromUserId, toUserId){
	// Like fromUserId > toUserId = true

	// Let's check the reverse.
	const promiseReverseLike = admin.database().ref('/userLikes/' + toUserId +"/" + fromUserId).once('value')
	const promiseMatch = admin.database().ref('/usersMatches/' + fromUserId +"/"+ toUserId).once('value')

	return Promise.all([promiseReverseLike, promiseMatch]).then(results => {
		const reverseLike = results[0]
		const match = results[1]

		if (!reverseLike.exists() || !reverseLike.val()){
			// It's not reciprocous
			return
		}

		// No need to check if match was already registed. 
		// This code will fall here only once.
		// const registered = match.exists()
		createMatch(fromUserId, toUserId)
	})
}