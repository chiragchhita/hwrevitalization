angular.module 'trPcControllers'
  .controller 'NgPcTeacherResourcesViewCtrl', [
    '$scope'
    'PageBuilderService'
    ($scope, PageBuilderService) ->
      PageBuilderService.getPageContent 'reus_ym_dhc_teacher_resources', ''
        .then (response) ->
          pageContent = response.data
          if pageContent
            $scope.pageContent = pageContent
]
