angular.module 'trPcControllers'
  .controller 'NgPcGiftsViewCtrl', [
    '$scope'
    '$rootScope'
    '$location'
    'APP_INFO'
    'BoundlessService'
    'PageContentService'
    '$sce'
    ($scope, $rootScope, $location, APP_INFO, BoundlessService, PageContentService, $sce) ->
      $scope.defaultInstantGifts = [
        {
          "MWB-19":"Heart Heroes Wristband"
          "status":0
        }
        {
          "KSHA-19":"Finn"
          "status":0
        }
        {
          "KPAN-19":"Ruby"
          "status":0
        }
        {
          "3D":"Create Your Own 3D Printed Heart Hero"
          "status":0
        }
      ]
      $scope.defaultStandardGifts = [
        {
          "KUNI-19":"Echo and Hero Clasp"
          "status":0
        }
      ]

      giftLevels = {
        "$0-$14":[
          "KUNI-19"
        ]
        "$15-$19":[
          "KUNI-19"
          "LVL2JR-19"
        ]
        "$20-$49":[
          "KUNI-19"
          "LVL2JR-19"
        ]
        "$50-$19":[
          "KUNI-19"
          "LVL2JR-19"
        ]
      }
      
      $scope.bonusGifts = []
      $scope.instantGifts = []
      $scope.standardGifts = []
      
      BoundlessService.getPrizes $scope.consId
      .then (response) ->
        students = response.data.students
        angular.forEach students, (student) ->
          current_level = student.current_level
          angular.forEach $scope.defaultInstantGifts, (id,gift) ->
            status = 0
            if giftLevels[current_level].includes(id)
              status = 1
            $scope.instantGifts.push
              prize_label: gift
              prize_sku: id
              prize_status: status

          angular.forEach $scope.defaultStandardGifts, (id,gift) ->
            status = 0
            if giftLevels[current_level].includes(id)
              status = 1
            $scope.standardGifts.push
              prize_label: gift
              prize_sku: id
              prize_status: status

      , (response) ->
        # TODO
  ]
