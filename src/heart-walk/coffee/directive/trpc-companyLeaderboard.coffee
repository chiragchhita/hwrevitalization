angular.module 'trPcApp'
  .directive 'companyLeaderboard', [
    'APP_INFO'
    (APP_INFO) ->
      templateUrl: APP_INFO.rootPath + 'dist/heart-walk/html/participant-center/directive/companyLeaderboard.html'
      restrict: 'E'
      replace: true
      scope:
        companies: '='
      controller: [
        '$rootScope'
        '$scope'
        ($rootScope, $scope) ->
          $scope.participantRegistration = $rootScope.participantRegistration
          
          $rootScope.$watch 'participantRegistration', ->
            $scope.participantRegistration = $rootScope.participantRegistration
      ]
  ]