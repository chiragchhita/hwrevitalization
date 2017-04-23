angular.module 'ahaLuminateControllers'
  .controller 'CompanyPageCtrl', [
    '$scope'
    '$rootScope'
    '$location'
    '$filter'
    '$timeout'
    'TeamraiserCompanyService'
    'TeamraiserTeamService'
    'TeamraiserParticipantService'
    'ZuriService'
    'APP_INFO'
    ($scope, $rootScope, $location, $filter, $timeout, TeamraiserCompanyService, TeamraiserTeamService, TeamraiserParticipantService, ZuriService, APP_INFO) ->
      $scope.companyId = $location.absUrl().split('company_id=')[1].split('&')[0]
      $scope.companyProgress = []
      $rootScope.companyName = ''
      $scope.companyTeams = []
      $scope.eventDate = ''
      $scope.totalTeams = ''
      $scope.teamId = ''
      $scope.studentsPledgedTotal = ''
      $scope.activity1amt = ''
      $scope.activity2amt = ''
      $scope.activity3amt = ''
      
      ZuriService.getZooSchool $scope.companyId,
        error: (response) ->
          $scope.studentsPledgedTotal = 0
          $scope.activity1amt = 0
          $scope.activity2amt = 0
          $scope.activity3amt = 0
        success: (response) ->
          $scope.studentsPledgedTotal = response.data.studentsPledged
          studentsPledgedActivities = response.data.studentsPledgedByActivity
          if studentsPledgedActivities['1']
            $scope.activity1amt = studentsPledgedActivities['1'].count
          else
            $scope.activity1amt = 0
          if studentsPledgedActivities['2']
            $scope.activity2amt = studentsPledgedActivities['2'].count
          else
            $scope.activity2amt = 0
          if studentsPledgedActivities['3']
            $scope.activity3amt = studentsPledgedActivities['3'].count
          else
            $scope.activity3amt = 0

      setCompanyFundraisingProgress = (amountRaised, goal) ->
        $scope.companyProgress.amountRaised = amountRaised
        $scope.companyProgress.amountRaised = Number $scope.companyProgress.amountRaised
        $scope.companyProgress.amountRaisedFormatted = $filter('currency')($scope.companyProgress.amountRaised / 100, '$').replace '.00', ''
        $scope.companyProgress.goal = goal or 0
        $scope.companyProgress.goal = Number $scope.companyProgress.goal
        $scope.companyProgress.goalFormatted = $filter('currency')($scope.companyProgress.goal / 100, '$').replace '.00', ''
        $scope.companyProgress.percent = 2
        $timeout ->
          percent = $scope.companyProgress.percent
          if $scope.companyProgress.goal isnt 0
            percent = Math.ceil(($scope.companyProgress.amountRaised / $scope.companyProgress.goal) * 100)
          if percent < 2
            percent = 2
          if percent > 100
            percent = 100
          $scope.companyProgress.percent = percent
          if not $scope.$$phase
            $scope.$apply()
        , 500
        if not $scope.$$phase
          $scope.$apply()
      
      getCompanyTotals = ->
        TeamraiserCompanyService.getCompanies 'list_page_size=500&company_id=' + $scope.companyId, 
            success: (response) ->
              $scope.participantCount = response.getCompaniesResponse.company.participantCount 
              totalTeams = response.getCompaniesResponse.company.teamCount
              eventId = response.getCompaniesResponse.company.eventId
              amountRaised = response.getCompaniesResponse.company.amountRaised
              goal = response.getCompaniesResponse.company.goal
              name = response.getCompaniesResponse.company.companyName
              coordinatorId = response.getCompaniesResponse.company.coordinatorId
              $rootScope.companyName = name
              setCompanyFundraisingProgress amountRaised, goal
              
              TeamraiserCompanyService.getCoordinatorQuestion coordinatorId, eventId
                .then (response) ->
                  $scope.eventDate = response.data.coordinator.event_date
                  
                  if totalTeams = 1
                    $scope.teamId = response.data.coordinator.team_id
      
      getCompanyTotals()
      
      setCompanyTeams = (teams, totalNumber) ->
        $scope.companyTeams.teams = teams or []
        totalNumber = totalNumber or 0
        $scope.companyTeams.totalNumber = Number totalNumber
        $scope.totalTeams = totalNumber
        if not $scope.$$phase
          $scope.$apply()
      
      getCompanyTeams = ->
        TeamraiserTeamService.getTeams 'team_company_id=' + $scope.companyId,
          success: (response) ->
            companyTeams = response.getTeamSearchByInfoResponse.team
            if companyTeams
              companyTeams = [companyTeams] if not angular.isArray companyTeams
              angular.forEach companyTeams, (companyTeam) ->
                companyTeam.amountRaised = Number companyTeam.amountRaised
                companyTeam.amountRaisedFormatted = $filter('currency')(companyTeam.amountRaised / 100, '$').replace '.00', ''
                joinTeamURL = companyTeam.joinTeamURL
                if joinTeamURL
                  companyTeam.joinTeamURL = joinTeamURL.split('/site/')[1]
              totalNumberTeams = response.getTeamSearchByInfoResponse.totalNumberResults
              setCompanyTeams companyTeams, totalNumberTeams
          error: ->
            setCompanyTeams()
      
      getCompanyTeams()
      
      $scope.companyParticipants = []
      setCompanyParticipants = (participants, totalNumber, totalFundraisers) ->
        $scope.companyParticipants.participants = participants or []
        totalNumber = totalNumber or 0
        $scope.companyParticipants.totalNumber = Number totalNumber
        $scope.companyParticipants.totalFundraisers = Number totalFundraisers
        if not $scope.$$phase
          $scope.$apply()
      
      getCompanyParticipants = ->
        TeamraiserParticipantService.getParticipants 'team_name=' + encodeURIComponent('%%%') + '&first_name=' + encodeURIComponent('%%%') + '&last_name=' + encodeURIComponent('%%%') + '&list_filter_column=team.company_id&list_filter_text=' + $scope.companyId + '&list_sort_column=total&list_ascending=false&list_page_size=50', 
            error: ->
              setCompanyParticipants()
              numCompaniesParticipantRequestComplete++
              if numCompaniesParticipantRequestComplete is numCompanies
                setCompanyNumParticipants numParticipants
            success: (response) ->
              participants = response.getParticipantsResponse?.participant
              companyParticipants = []
              totalFundraisers = ''
              if participants
                participants = [participants] if not angular.isArray participants
                angular.forEach participants, (participant) ->
                  if participant.amountRaised > 1
                    participant.amountRaised = Number participant.amountRaised
                    participant.amountRaisedFormatted = $filter('currency')(participant.amountRaised / 100, '$').replace '.00', ''
                    participant.name.last = participant.name.last.substring(0,1)+'.'
                    companyParticipants.push participant
                    totalFundraisers++
              totalNumberParticipants = response.getParticipantsResponse.totalNumberResults
              setCompanyParticipants companyParticipants, totalNumberParticipants, totalFundraisers

      getCompanyParticipants()

      console.log $scope.companyParticipants
      console.log companyParticipantsString

      angular.element('.ym-school-animation iframe')[0].contentWindow.postMessage(companyParticipantsString, 'http://heartdev.convio.net');
      
  ]