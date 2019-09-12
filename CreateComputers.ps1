<#
.SYNOPSIS
    The Script creates test computers to your demo domain based on first and last names from csv. 
.PARAMETER NumComputers
    Integer - number of computers to create, default 10.
.NOTES
    File Name: CreateTestComputers.ps1
    Author   : Sergio Cruzado Muñoz, Edgar Augusto Loyola Torres   
#>
param ([parameter(Mandatory=$false)]
[int]
$NumComputers = "10"
)

#Define variables
$OU = "OU=Support,OU=Domain Computers,DC=prueba,DC=local"
$Names = Import-CSV FirstLastComputer.csv
$firstnames = $Names.Firstname  
$lastnames = $Names.Lastname
$numMachines=$firstnames.count

#Import required module ActiveDirectory
try{
	Import-Module ActiveDirectory -ErrorAction Stop
}
catch{
	throw "Module GroupPolicy not Installed"
}

while ($NumComputers -gt 0){

	#Choose a 'random' Firstname and Lastname from the csv
    $i = Get-Random -Minimum 0 -Maximum $firstnames.count
    $firstname = $FirstNames[$i]
    $i = Get-Random -Minimum 0 -Maximum $lastnames.count
    $lastname = $LastNames[$i]
	$Computers = (Get-ADComputer -Filter "Name -like '$firstname*'").count
	$machinename = $firstname + $lastname
   	
	#Check for duplicates
	try{
		#Check if the machine is already in the domain
		if (!(Get-ADComputer -Identity $machinename)) {

				$machinename = $firstname  + $lastname

		}
		else{
			#Duplicate is found
			#Write-Host "Are you getting in here? $Computers"
			if($Computers -eq $numMachines){

				Write-Host "No quedan más máquinas disponibles en el csv"
				Start-Sleep -s 1.5
				$NumComputers=-1
			}
			
		}
	}

		catch{
			#There are no duplicates
		   if ( $error[0].Exception -match "ADIdentityNotFoundException"){
			   
				$machinename = $firstname  + $lastname
				#Create the computer
			    Write-Host "Creating computer $computer in $ou"
				New-ADComputer –Name $machinename –SamAccountName $machinename -Path $ou
				$NumComputers--
		   }
		}
}
