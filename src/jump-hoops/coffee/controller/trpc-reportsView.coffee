angular.module 'trPcControllers'
  .controller 'NgPcReportsViewCtrl', [
    '$scope'
    '$filter'
    'NgPcTeamraiserGiftService'
    'NgPcTeamraiserReportsService'
    ($scope, $filter, NgPcTeamraiserGiftService, NgPcTeamraiserReportsService) ->
      $scope.reportPromises = []
      
      $scope.activeReportTab = if $scope.participantRegistration.companyInformation.isCompanyCoordinator is 'true' then 0 else 1
      
      $scope.participantGifts =
        sortColumn: 'date_recorded'
        sortAscending: false
        page: 1
      $scope.getGifts = ->
        pageNumber = $scope.participantGifts.page - 1
        personalGiftsPromise = NgPcTeamraiserGiftService.getGifts 'list_sort_column=' + $scope.participantGifts.sortColumn + '&list_ascending=' + $scope.participantGifts.sortAscending + '&list_page_size=10&list_page_offset=' + pageNumber
          .then (response) ->
            if response.data.errorResponse
              $scope.participantGifts.gifts = []
              $scope.participantGifts.totalNumber = 0
            else
              gifts = response.data.getGiftsResponse.gift
              if not gifts
                $scope.participantGifts.gifts = []
              else
                gifts = [gifts] if not angular.isArray gifts
                participantGifts = []
                angular.forEach gifts, (gift) ->
                  gift.contact =
                    firstName: gift.name.first
                    lastName: gift.name.last
                    email: gift.email
                  gift.giftAmountFormatted = $filter('currency') gift.giftAmount / 100, '$', 0
                  participantGifts.push gift
                $scope.participantGifts.gifts = participantGifts
              $scope.participantGifts.totalNumber = Number response.data.getGiftsResponse?.totalNumberResults or 0
            response
        $scope.reportPromises.push personalGiftsPromise
      $scope.getGifts()
      
      if $scope.participantRegistration.companyInformation.isCompanyCoordinator is 'true'
        $scope.schoolDetailStudents = {}
        schoolDetailReportPromise = NgPcTeamraiserReportsService.getSchoolDetailReport()
          .then (response) ->
            if response.data.errorResponse
              $scope.schoolDetailStudents.students = []
            else
              reportHtml = response.data.getSchoolDetailReport.report
              $reportTable = angular.element('<div>' + reportHtml + '</div>').find 'table'
              if $reportTable.length is 0
                $scope.schoolDetailStudents.students = []
              else
                $reportTableRows = $reportTable.find 'tr'
                if $reportTableRows.length is 0
                  $scope.schoolDetailStudents.students = []
                else
                  schoolDetailStudents = []
                  angular.forEach $reportTableRows, (reportTableRow) ->
                    $reportTableRow = angular.element reportTableRow
                    schoolDetailStudents.push
                      firstName: jQuery.trim $reportTableRow.find('td').eq(8).text()
                      lastName: jQuery.trim $reportTableRow.find('td').eq(9).text()
                      amount: Number jQuery.trim($reportTableRow.find('td').eq(10).text())
                      amountFormatted: $filter('currency') jQuery.trim($reportTableRow.find('td').eq(10).text()), '$', 0
                      ecardsSent: Number jQuery.trim($reportTableRow.find('td').eq(13).text())
                  $scope.schoolDetailStudents.students = schoolDetailStudents
            response
        $scope.reportPromises.push schoolDetailReportPromise
  ]