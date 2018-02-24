
angular.module 'ahaLuminateApp'
  .directive 'validateOnBlur', ->
    restrict: 'A'
    require: 'ngModel'
    scope: {}
    link: (scope, element, attrs, modelCtrl) ->
      element.on 'blur', ->
        console.log element
        modelCtrl.$showValidationMessage = modelCtrl.$dirty
        scope.$apply()
