#  Lucas Bayol 08/2023 - Extract valid that are not in a specific group
###entrez les creds du tenant au prompt
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All"
### sort une liste des users avec une licence Microsoft 365 Business Premium valide avec le SkuID
$userIds = (get-mguser -all).id
foreach ($userId in $userids) {
    $validLicence = Get-MgUserLicenseDetail -UserId $userId | Where-object SkuID -eq 'cbdc14ab-d96c-4c30-b9f4-6ada7cdc1d46' 
    if ($validLicence) {
        $validUsers += (Get-mguser -UserID $userid).id
        $validUsers += "_"
    }
}
###string manipulation, l'id est ajouté dans une string continue dans l'array
$validUsers = $validusers.split("_")
###créer array qui n'est pas fixed size
[System.Collections.ArrayList]$arrayValidUsers = $validUsers
#id du groupe a comparer
$groupid = "a720c6c1-35e7-42e8-bbf0-3ec33fd506e3"
$groupMembers = get-mggroupmember -groupid $groupid
foreach ($groupMember in $groupMembers) {
    $arrayValidUsers.Remove(($groupMember).Id)
}
foreach ($arrayValidUser in $arrayValidUsers) {
    get-mguser -userid $arrayValidUser | select-object DisplayName, UserPrincipalName
}
