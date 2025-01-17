Describe 'Lab 3: Bouncer Script' {
  BeforeAll {
    . $PSScriptRoot/Shared.ps1
    Initialize-TestEnvironment -ProjectName 'Lab.3.Bouncer'
  }

  Context 'Get-PEUAge' {
    It 'Generates a random birthday for the subject' {
      $actual = Get-PEUAge -Name 'PSConfEUParticipant'
      $actual.name | Should -Be 'PSConfEUParticipant'
      $actual.birthday | Should -BeOfType [DateTime]
    }
    It 'Generates random birthdays for each name provided via the pipeline' {
      $names = 'PSConfEUParticipant', 'PSConfEUParticipant2', 'PSConfEUParticipant3'

      $actual = $names | Get-PEUAge
      $actual.Count | Should -BeExactly $names.Count
      $names | ForEach-Object {
        $actual.name | Should -Contain $_
      }
      $actual.birthday.count | Should -BeExactly $names.Count
      $actual.birthday | ForEach-Object {
        $PSItem | Should -BeOfType [DateTime]
      }
    }
  }

  Context 'Assert-PEUAge' {
    It 'Passes thru the user object if the user is of age' {
      $user = [PSCustomObject]@{
        Name     = 'PSConfEUParticipant'
        Birthday = (Get-Date).AddYears(-25)
      }

      $actual = $user | Assert-PEUAge -Age 18

      $actual | Should -Be $user
    }
    It 'Throws InvalidOperationException if the specified user is under -Age' {
      $user = [PSCustomObject]@{
        Name     = 'PSConfEUParticipant'
        Birthday = (Get-Date).AddYears(-15)
      }

      $testPeuAgeScript = {
        $user | Assert-PEUAge -Age 18
      }

      $testPeuAgeScript | Should -Throw -ExceptionType [InvalidDataException]
    }
  }
}