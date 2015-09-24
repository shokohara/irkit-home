angular.module("app")
.config(["$stateProvider", "$locationProvider", ($stateProvider, $locationProvider) ->
  $locationProvider.html5Mode(true)
  $stateProvider
  .state "top",
    url: "/"
    templateUrl: "template/rooms.html"
    controller: "RoomsController"
])
