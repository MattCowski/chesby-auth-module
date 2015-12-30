
angular.module 'auth', [
#   'templates',
  'auth-templates',
  'ngRoute',   
  'firebase',  
  'ui.mask',
  'mgcrea.ngStrap.modal', 
]
  
         
    
.controller 'LoginCtrl', ($http, $scope, Auth, $location) ->    
  @authRequestCode = (phone) =>
    console.log phone
    console.log "phoneauth"
    $http.get("http://node-js-100773.nitrousapp.com:8080/api/transloadit/test/").success (data) ->
      console.log data
    $http.post("http://node-js-100773.nitrousapp.com:8080/api/twoauth/request/", angular.toJson({phone:phone})).success (data) ->
      console.log data
#     Requests.$set(phone, {uid: phone, phone: phone})

  @authWithPhone = (phone, code) =>
    $http.get(ENVIROMENT+"api/twilio/fbtoken?phone="+phone+"&code="+code)
    .error (error) ->
      console.log error
    .success (token) ->
      Auth.$authWithCustomToken(token).then (authData) ->
        console.log authData
        Auth.createProfile(authData)
      .catch (error) ->
        console.log error
      

  @createUser = () =>
    Auth.$createUser(@email, @password)
    .then () =>
      @authWithPassword (authData)=>
         Auth.createProfile(authData)
    , (error) =>
      @error = error.toString()

  @authWithPassword = (cb) =>
    Auth.$authWithPassword {email: @email, password: @password}
    .then (authData) =>
      console.log("Logged in as:", authData.uid)
      cb(authData)

    .catch (error)=>
      console.error("Error: ", error)
      if error.code is "INVALID_USER"
        @createUser()
      else
        @error = error.toString()
  return

.factory "Auth", ($modal, $firebase, FIREBASE_URL, $firebaseAuth, $rootScope, $timeout, $location) ->
  ref = new Firebase(FIREBASE_URL)
  auth = $firebaseAuth(ref)
  
  Auth =
    user: null
    unauth: -> 
      console.log "unauth"
      @$unauth()
      @user = null
    $unauth: auth.$unauth
    $onAuth: auth.$onAuth
    $authWithCustomToken: auth.$authWithCustomToken
    $authWithPassword: auth.$authWithPassword
    $createUser: auth.$createUser
    popup: =>
        loginModal = $modal({template: 'auth/modalLogin.html', show: false})
        if !Auth.user
          console.log "opeing"
          loginModal.$promise.then(loginModal.show)
          
        Auth.$onAuth (user) =>
          if user
            console.log "closing"
            loginModal.$promise.then(loginModal.hide)

    createProfile: (user) ->
      profileData =
        md5_hash: user.md5_hash or ''
        roleValue: 10
      
      profileRef = $firebase(ref.child('profile').child(user.uid))  
      angular.extend(profileData, $location.search())
      return profileRef.$update(profileData)
  
  auth.$onAuth (user) ->
    if user
      Auth.user = {}
      angular.copy(user, Auth.user)
      Auth.user.profile = $firebase(ref.child('profile').child(Auth.user.uid)).$asObject()
      $rootScope.user = Auth.user
      # ref.child('profile/'+Auth.user.uid+'/online').set(true)
      # ref.child('profile/'+Auth.user.uid+'/online').onDisconnect().set(Firebase.ServerValue.TIMESTAMP)
      # ref.child('profile/'+Auth.user.uid+'/connections').push(true)
      # ref.child('profile/'+Auth.user.uid+'/connections').onDisconnect().remove()
      # ref.child('profile/'+Auth.user.uid+'/connections/lastDisconnect').onDisconnect().set(Firebase.ServerValue.TIMESTAMP)

    else
      if Auth.user and Auth.user.profile
        Auth.user.profile.$destroy()
      angular.copy({}, Auth.user)
      $rootScope.user = Auth.user



    # ref.child('.info/connected').on 'value', (snap) ->
    #   if snap.val() is true
    #     user = Auth.user.uid or 'unknown'
    #     ref.child('connections').push(user)
    #     ref.child('connections').onDisconnect().remove()

  return Auth

            
