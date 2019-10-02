angular.module 'trPcControllers'
  .controller 'NgPcTeacherResourcesViewCtrl', [
    '$scope'
    'PageBuilderService'
    '$sce'
    ($scope, PageBuilderService, $sce) ->
      $scope.SkipValidation = (value) ->
	      return $sce.trustAsHtml(value)
      
      PageBuilderService.getPageContent 'reus_ym_khc_teacher_resources', 'tab=elementary'
        .then (response) ->
          pageContent = response.data
          if pageContent
            $scope.pageContent = pageContent
  ]
