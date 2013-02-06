[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.TeamFoundation.Client")

# invalid uri
[Microsoft.TeamFoundation.Client.LocationService]::GetProject('foo')
# project in Deleting state, string param
[Microsoft.TeamFoundation.Client.LocationService]::GetProject('vstfs:///Classification/TeamProject/c93f487d-4623-42f2-ae68-ef09b4972bf3')
# project in New state, guid param
[Microsoft.TeamFoundation.Client.LocationService]::GetProject([guid]'ccdcade3-3795-46e8-b32b-dcf33c04b5dd')
# project in WellFormed state, uri param
[Microsoft.TeamFoundation.Client.LocationService]::GetProject([uri]'vstfs:///Classification/TeamProject/8e769856-6209-46e0-b9e5-c926d0cab506')
