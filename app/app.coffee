angular.module 'angular', [ 
  'auth',
#   'templates',
  'ngRoute', 
]
  .constant('FIREBASE_URL', "https://chesby.firebaseio.com/")

  .config ($routeProvider, $httpProvider, $locationProvider) ->
    $locationProvider.html5Mode(false)

    $routeProvider
      .when '/',
        templateUrl: "main/main.html"
        controller: "MainCtrl"
      .otherwise
        redirectTo: '/'
        
  .controller "MainCtrl", (Auth, $scope) ->
    $scope.auth = Auth
     
      
      
      
