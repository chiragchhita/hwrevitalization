angular.module 'ahaLuminateControllers'
  .controller 'HomeCtrl', [
    '$scope'
    '$timeout'
    'TeamraiserParticipantService'
    '$rootScope'
    '$location'
    '$anchorScroll'
    'ParticipantBadgesService'
    'TeamraiserService'
    ($scope, $timeout, TeamraiserParticipantService, $rootScope, $location, $anchorScroll, ParticipantBadgesService, TeamraiserService) ->
      $dataRoot = angular.element '[data-aha-luminate-root]'
      consId = $dataRoot.data('cons-id') if $dataRoot.data('cons-id') isnt ''
      
      setNoSchoolLink = (noSchoolLink) ->
        $scope.noSchoolLink = noSchoolLink
        if not $scope.$$phase
          $scope.$apply()
      TeamraiserService.getTeamRaisersByInfo 'event_type=' + encodeURIComponent('Jump Hoops') + '&public_event_type=' + encodeURIComponent('School Not Found') + '&name=' + encodeURIComponent('%') + '&list_page_size=1&list_ascending=false&list_sort_column=event_date',
          error: (response) ->
            # TODO
          success: (response) ->
            teamraisers = response.getTeamraisersResponse?.teamraiser
            if not teamraisers
              # TODO
            else
              teamraisers = [teamraisers] if not angular.isArray teamraisers
              teamraiserInfo = teamraisers[0]
              setNoSchoolLink $scope.nonSecureDomain + '/site/TRR?fr_id=' + teamraiserInfo.id + '&pg=tfind&fr_tm_opt=none&s_frTJoin=&s_frCompanyId='
      if consId
        TeamraiserParticipantService.getRegisteredTeamraisers 'cons_id=' + consId + '&event_type=' + encodeURIComponent('Jump Hoops'),
          error: ->
            modalSet = readCookie 'modalSet'
            if modalSet isnt 'true'
              setModal()
          success: (response) ->
            teamraisers = response.getRegisteredTeamraisersResponse.teamraiser
            numberEvents = 0
            if teamraisers
              teamraisers = [teamraisers] if not angular.isArray teamraisers
              numberEvents = teamraisers.length
            if numberEvents is 0
              modalSet = readCookie 'modalSet'
              if modalSet isnt 'true'
                setModal()
      
      readCookie = (name) ->
        nameEQ = name + '='
        ca = document.cookie.split ';'
        i = 0
        while i < ca.length
          c = ca[i]
          while c.charAt(0) is ' '
            c = c.substring 1, c.length
          if c.indexOf(nameEQ) is 0
            return c.substring nameEQ.length, c.length
          i++
        null
      
      setModal = ->
        date = new Date
        expires = 'expires='
        date.setDate date.getDate() + 1
        expires += date.toGMTString()
        
        angular.element('#noRegModal').modal()
        document.cookie = 'modalSet=true; ' + expires + '; path=/'
      
      $scope.closeModal = ->
        angular.element('#noRegModal').modal 'hide'
        document.getElementById('school-search').scrollIntoView()
      
      $scope.totalStudents = ''
      $scope.totalSchools = ''
      $scope.totalChallenges = ''
      $scope.showStats = true
      
      ParticipantBadgesService.getRollupTotals()
        .then (response) ->
          if not response.data.status or response.data.status isnt 'success'
            $scope.showStats = false
          else
            $scope.showStats = true
            totals = response.data.totals          
            
            $scope.totalStudents = totals.total_students
            if $scope.totalStudents.toString().length > 4
              $scope.totalStudents = Math.round($scope.totalStudents/1000)+ 'K'

            $scope.totalSchools = totals.total_schools
            if $scope.totalSchools.toString().length > 4
              $scope.totalSchools = Math.round($scope.totalSchools/1000)+ 'K'

            $scope.totalChallenges = totals.total_challenge_taken_students
            if $scope.totalChallenges.toString().length > 4
              $scope.totalChallenges = Math.round($scope.totalChallengess/1000)+ 'K'
            
        , (response) ->
          $scope.showStats = false
      
      initCarousel = ->
        owl = jQuery '.ym-home-feature .owl-carousel'
        owl.owlCarousel
          items: 1
          nav: true
          loop: true
          center: true
          responsive:
            0:
              stagePadding: 0
            568:
              stagePadding: 75
            768:
              stagePadding: 150
            1050:
              stagePadding: 290
          navText: [
            '<i class="fa fa-chevron-left" hidden aria-hidden="true" />'
            '<i class="fa fa-chevron-right" hidden aria-hidden="true" />'
          ]
      $timeout initCarousel, 1000
      
      initHeroCarousel = ->
        owl = jQuery '.ym-carousel--hero'
        if owl.length
          items = owl.find '> .item'
          if items.length > 1
            owl.owlCarousel
              items: 1
              nav: true
              loop: true
              center: true
              navText: [
                '<i class="fa fa-chevron-left" hidden aria-hidden="true" />'
                '<i class="fa fa-chevron-right" hidden aria-hidden="true" />'
              ]
      $timeout initHeroCarousel, 1000
  ]